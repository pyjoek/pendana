# app.py
import os
import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from passlib.hash import bcrypt
from flask_jwt_extended import (
    JWTManager, create_access_token, create_refresh_token,
    jwt_required, get_jwt_identity
)

# --- Setup ---
app = Flask(__name__)
CORS(app)

app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+pymysql://root:@localhost/pendana"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", "joel")
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = datetime.timedelta(minutes=60)
app.config["JWT_REFRESH_TOKEN_EXPIRES"] = datetime.timedelta(days=30)


db = SQLAlchemy(app)
jwt = JWTManager(app)

# --- Models ---
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255), unique=True, index=True, nullable=False)
    name = db.Column(db.String(120), nullable=False)
    password_h = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def to_public(self):
        return {"id": self.id, "email": self.email, "name": self.name}

with app.app_context():
    db.create_all()
    # Seed a test user if not exists (email: test@example.com, pass: 123456)
    if not User.query.filter_by(email="test@example.com").first():
        db.session.add(User(
            email="test@example.com",
            name="Test User",
            password_h=bcrypt.hash("123456")
        ))
        db.session.commit()

class UserInterest(db.Model):
    __tablename__ = "user_interests"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    interest = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    # Relationship back to user
    user = db.relationship("User", backref=db.backref("interests", lazy=True))

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "interest": self.interest,
            "created_at": self.created_at.isoformat()
        }

# --- Routes ---
@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/auth/register")
def register():
    data = request.get_json(force=True, silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    name = (data.get("name") or "").strip()
    password = (data.get("password") or "")

    if not email or not name or not password:
        return jsonify({"error": "name, email, password required"}), 400
    if User.query.filter_by(email=email).first():
        return jsonify({"error": "email_taken"}), 409

    user = User(email=email, name=name, password_h=bcrypt.hash(password))
    db.session.add(user)
    db.session.commit()
    return jsonify({"user": user.to_public()}), 201

# -------users intrest------
@app.route("/user/general", methods=["POST"])
@jwt_required()
def save_general():
    data = request.get_json()
    user_id = get_jwt_identity()
    dob = data.get("dob")
    gender = data.get("gender")
    purpose = data.get("purpose")
    likes = data.get("likes", [])
    other_likes = data.get("other_likes", "")

    # Save DOB, gender, purpose in user table
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    user.dob = dob
    user.gender = gender
    user.purpose = purpose
    db.session.commit()

    # Save interests in relational table
    for interest in likes + ([other_likes] if other_likes else []):
        db.session.add(UserInterest(user_id=user_id, interest=interest))
    db.session.commit()

    return jsonify({"message": "General info saved successfully"}), 200


@app.post("/auth/login")
def login():
    data = request.get_json(force=True, silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    password = (data.get("password") or "")

    if not email or not password:
        return jsonify({"error": "email_and_password_required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user or not bcrypt.verify(password, user.password_h):
        return jsonify({"error": "invalid_credentials"}), 401

    access = create_access_token(identity=user.id, additional_claims={"email": user.email, "name": user.name})
    refresh = create_refresh_token(identity=user.id)
    return jsonify({
        "user": user.to_public(),
        "access_token": access,
        "refresh_token": refresh
    }), 200

@app.post("/auth/refresh")
@jwt_required(refresh=True)
def refresh():
    uid = get_jwt_identity()
    user = User.query.get(uid)
    if not user:
        return jsonify({"error": "not_found"}), 404
    access = create_access_token(identity=user.id, additional_claims={"email": user.email, "name": user.name})
    return jsonify({"access_token": access})

@app.get("/me")
@jwt_required()
def me():
    uid = get_jwt_identity()
    user = User.query.get(uid)
    if not user:
        return jsonify({"error": "not_found"}), 404
    return jsonify({"user": user.to_public()}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)), debug=True)
