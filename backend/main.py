# app.py
import os
import datetime
import random
import smtplib
from email.mime.text import MIMEText

from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from passlib.hash import bcrypt
from flask_jwt_extended import (
    JWTManager, create_access_token, create_refresh_token,
    jwt_required, get_jwt_identity, get_jwt
)
from dotenv import load_dotenv

# ---------- Bootstrap ----------
load_dotenv()  # Load .env if present

app = Flask(__name__)
CORS(app)

# ---------- Config ----------
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret-change-me")
app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", "sqlite:///pendana.db")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# JWT config
app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", "jwt-secret-change-me")
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = datetime.timedelta(minutes=30)
app.config["JWT_REFRESH_TOKEN_EXPIRES"] = datetime.timedelta(days=30)
app.config["JWT_TOKEN_LOCATION"] = ["headers"]  # Bearer tokens

db = SQLAlchemy(app)
jwt = JWTManager(app)

# Basic in-memory token blocklist (restart clears! replace with Redis in prod)
TOKEN_BLOCKLIST = set()

# ---------- Models ----------
class User(db.Model):
    __tablename__ = "users"
    id          = db.Column(db.Integer, primary_key=True)
    name        = db.Column(db.String(120), nullable=False)
    phone       = db.Column(db.String(40), unique=True, index=True)
    email       = db.Column(db.String(255), unique=True, index=True)
    password_h  = db.Column(db.String(255), nullable=False)
    email_verified = db.Column(db.Boolean, default=False)
    phone_verified = db.Column(db.Boolean, default=False)
    created_at  = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def to_safe_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "phone": self.phone,
            "email": self.email,
            "email_verified": self.email_verified,
            "phone_verified": self.phone_verified,
            "created_at": self.created_at.isoformat()
        }

class EmailOTP(db.Model):
    __tablename__ = "email_otps"
    id         = db.Column(db.Integer, primary_key=True)
    email      = db.Column(db.String(255), index=True, nullable=False)
    code       = db.Column(db.String(6), nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    used       = db.Column(db.Boolean, default=False)

# ---------- JWT Blocklist Callbacks ----------
@jwt.token_in_blocklist_loader
def check_if_token_revoked(jwt_header, jwt_payload):
    jti = jwt_payload.get("jti")
    return jti in TOKEN_BLOCKLIST

@jwt.revoked_token_loader
def revoked_response(jwt_header, jwt_payload):
    return jsonify({"error": "token_revoked"}), 401

# ---------- Helpers ----------
def send_email_otp(email: str, code: str) -> None:
    """
    Sends OTP by Gmail SMTP. Use an App Password (not your normal Gmail password).
    Configure in .env: SMTP_EMAIL, SMTP_APP_PASSWORD
    """
    smtp_email = os.getenv("SMTP_EMAIL")
    smtp_pass  = os.getenv("SMTP_APP_PASSWORD")
    if not smtp_email or not smtp_pass:
        app.logger.warning("SMTP_EMAIL/SMTP_APP_PASSWORD not set. Skipping real email send.")
        return

    msg = MIMEText(f"Your Pendana verification code is: {code}")
    msg["Subject"] = "Your Pendana OTP"
    msg["From"] = smtp_email
    msg["To"]   = email

    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(smtp_email, smtp_pass)
        server.sendmail(smtp_email, [email], msg.as_string())

def generate_otp(length=6) -> str:
    return "".join(str(random.randint(0, 9)) for _ in range(length))

def normalize_identifier(s: str) -> str:
    return s.strip().lower()

# ---------- DB init ----------
with app.app_context():
    db.create_all()

# ---------- Routes ----------
@app.get("/health")
def health():
    return {"status": "ok", "time": datetime.datetime.utcnow().isoformat()}

@app.post("/auth/register")
def register():
    data = request.get_json(force=True, silent=True) or {}
    name = data.get("name", "").strip()
    phone = data.get("phone", "").strip()
    email = normalize_identifier(data.get("email", "") or "")
    password = data.get("password", "")

    if not all([name, password]) or (not email and not phone):
        return jsonify({"error": "name, password and either email or phone are required"}), 400

    if email and User.query.filter_by(email=email).first():
        return jsonify({"error": "email_taken"}), 409
    if phone and User.query.filter_by(phone=phone).first():
        return jsonify({"error": "phone_taken"}), 409

    user = User(
        name=name,
        phone=phone or None,
        email=email or None,
        password_h=bcrypt.hash(password),
    )
    db.session.add(user)
    db.session.commit()

    # Optionally auto-send email OTP
    if email:
        code = generate_otp()
        otp = EmailOTP(
            email=email,
            code=code,
            expires_at=datetime.datetime.utcnow() + datetime.timedelta(minutes=10),
        )
        db.session.add(otp)
        db.session.commit()
        try:
            send_email_otp(email, code)
        except Exception as e:
            app.logger.error(f"OTP email send failed: {e}")

    return jsonify({"user": user.to_safe_dict()}), 201

@app.post("/auth/login")
def login():
    data = request.get_json(force=True, silent=True) or {}
    identifier = normalize_identifier(data.get("identifier", ""))  # email or phone
    password   = data.get("password", "")

    if not identifier or not password:
        return jsonify({"error": "identifier_and_password_required"}), 400

    user = User.query.filter(
        (User.email == identifier) | (User.phone == identifier)
    ).first()

    if not user or not bcrypt.verify(password, user.password_h):
        return jsonify({"error": "invalid_credentials"}), 401

    access = create_access_token(identity=user.id, additional_claims={"name": user.name})
    refresh = create_refresh_token(identity=user.id)

    return jsonify({
        "user": user.to_safe_dict(),
        "access_token": access,
        "refresh_token": refresh
    }), 200

@app.post("/auth/refresh")
@jwt_required(refresh=True)
def refresh():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "not_found"}), 404

    access = create_access_token(identity=user.id, additional_claims={"name": user.name})
    return jsonify({"access_token": access})

@app.post("/auth/logout")
@jwt_required(verify_type=False)  # allow either access or refresh
def logout():
    jti = get_jwt().get("jti")
    TOKEN_BLOCKLIST.add(jti)
    return jsonify({"message": "logged_out"}), 200

@app.get("/users/me")
@jwt_required()
def me():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "not_found"}), 404
    return jsonify({"user": user.to_safe_dict()})

# ---------- Email OTP (verify email) ----------
@app.post("/auth/otp/send")
def send_otp():
    data = request.get_json(force=True, silent=True) or {}
    email = normalize_identifier(data.get("email", ""))

    if not email:
        return jsonify({"error": "email_required"}), 400
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"error": "user_not_found"}), 404

    code = generate_otp()
    otp = EmailOTP(
        email=email,
        code=code,
        expires_at=datetime.datetime.utcnow() + datetime.timedelta(minutes=10),
    )
    db.session.add(otp)
    db.session.commit()

    try:
        send_email_otp(email, code)
    except Exception as e:
        app.logger.error(f"OTP send failed: {e}")
        # Still return success to avoid leaking delivery status
    return jsonify({"message": "otp_sent"}), 200

@app.post("/auth/otp/verify")
def verify_otp():
    data = request.get_json(force=True, silent=True) or {}
    email = normalize_identifier(data.get("email", ""))
    code  = (data.get("code") or "").strip()

    if not email or not code:
        return jsonify({"error": "email_and_code_required"}), 400

    otp = EmailOTP.query.filter_by(email=email, code=code, used=False).order_by(EmailOTP.id.desc()).first()
    if not otp:
        return jsonify({"error": "invalid_code"}), 400

    if datetime.datetime.utcnow() > otp.expires_at:
        return jsonify({"error": "code_expired"}), 400

    otp.used = True
    user = User.query.filter_by(email=email).first()
    if user:
        user.email_verified = True
    db.session.commit()

    return jsonify({"message": "email_verified"}), 200

# ---------- Example protected resource ----------
@app.get("/matches")
@jwt_required()
def matches():
    # placeholder: return some mock matches
    return jsonify({
        "matches": [
            {"id": 101, "name": "Asha", "age": 26, "city": "Dar es Salaam"},
            {"id": 102, "name": "Juma", "age": 29, "city": "Arusha"},
        ]
    })

# ---------- Run ----------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)), debug=True)
