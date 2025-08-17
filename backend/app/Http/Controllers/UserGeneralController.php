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

        $data = $request->all();

            // $data['user_id'] = auth()->id(); // safer than $request->user()

            // Convert array to JSON before saving if column type = string/text
            // return response()->json(['debug' => "here"]);
            $data['interests'] = json_encode($data['interests']);

        $userGeneral = UserGeneral::create($data);

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
