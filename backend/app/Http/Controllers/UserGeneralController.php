<?php

namespace App\Http\Controllers;

use App\Models\UserGeneral;
use Illuminate\Http\Request;

class UserGeneralController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'dob' => 'required|date',
            'purpose' => 'required|string',
            'bio' => 'nullable|string',
            'profile_picture' => 'image|mimes:jpg,jpeg,png',
        ]);

        $path = null;
        if ($request->hasFile('profile_picture')) {
            $path = $request->file('profile_picture')->store('profiles', 'public');
        }

        $userGeneral = UserGeneral::create([
            'user_id' => $request->user_id,
            'dob' => $request->dob,
            'purpose' => $request->purpose,
            'interests' => json_encode($request->interests),
            'bio' => $request->bio,
            'profile_picture' => $path,
        ]);

        return response()->json([
            'message' => 'User general information stored successfully',
            'data' => $userGeneral
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(UserGeneral $userGeneral)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(UserGeneral $userGeneral)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, UserGeneral $userGeneral)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(UserGeneral $userGeneral)
    {
        //
    }
}
