<?php

namespace App\Http\Controllers;
use App\Models\User;
use App\Models\UserGeneral;
use App\Models\UserOtp;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;
use App\Mail\OtpMail;

use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function register(Request $request) 
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'gender' => $request->gender,
        ]);

        $users = User::where('email', $request->email)->first()->id;

        return response()->json(['user' => $user, 'userId' => $users], 201);
    }

    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
        ]);

        $otp = rand(100000, 999999); // 6 digit random number
        $user = User::where('email', $request->email)->first()->id;

        UserOtp::create([
            'user_id' => $user,
            'otp' => $otp,
            'expires_at' => Carbon::now()->addMinutes(5),
        ]);

        // send OTP
        // Mail::to($user->email)->send(new OtpMail($otp));

        // Send OTP via email
        Mail::raw("Your OTP code is: $otp", function ($message) use ($request) {
            $message->to($request->email)
                ->subject('Your OTP Verification Code');
        });

        return response()->json(['message' => 'OTP sent successfully', 'user' => $user, 'otp' => $otp]);
    }

    public function verifyOtp(Request $request) {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        $userOtp = UserOtp::where('user_id', $user->id)
            ->where('otp', $request->otp)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if (!$userOtp) {
            return response()->json(['error' => 'Invalid or expired OTP'], 400);
        }

        $user->update(['verified' => true]);
        $userOtp->delete();

        return response()->json(['message' => 'Email verified successfully']);
    }


    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);
        
        $user = User::where('email', $request->email)->first();
        $userGeneral = UserGeneral::where('user_id', $user->id)->first();
        
        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }
        
        $token = $user->createToken('pendana_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'user' => $user,
            'userId' => $user->id,
            'userGeneral' => $userGeneral
        ]);
    }

    public function profile() {
        return response()->json(auth()->user());
    }

    public function logout(Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully']);
    }

    public function listOtherUsers($id)
    {
        return User::where('id', '!=', $id)->get(['id','name']);
    }
}
