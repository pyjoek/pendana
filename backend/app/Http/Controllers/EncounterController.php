<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Encounter;

class EncounterController extends Controller
{
    // Get list of users to swipe on
    public function index($currentUserId)
    {        // Exclude self + people already swiped on
        $swipedIds = Encounter::where('user_id', $currentUserId)->pluck('target_id')->toArray();

        $users = User::where('id', '!=', $currentUserId)
            ->whereNotIn('id', $swipedIds)
            ->select('id', 'name')
            ->get();

        return response()->json($users);
    }

    // Record like/dislike
    public function action(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer',
            'target_id' => 'required|integer',
            'action' => 'required|in:like,dislike',
        ]);
        
        $encounter = Encounter::updateOrCreate(
            ['user_id' => $request->user_id, 'target_id' => $request->target_id],
            ['action' => $request->action]
        );

        return response()->json(['success' => true, 'data' => $encounter]);
    }

    // List of people I liked
    public function likes($userId)
    {
        $likes = Encounter::with('target')
            ->where('user_id', $userId)
            ->where('action', 'like')
            ->get()
            ->pluck('target');

        return response()->json($likes);
    }

    public function likedMe($userId)
    {
        $users = Encounter::where('target_id', $userId)
            ->where('action', 'like')
            ->with('user') // eager load the liker user relationship
            ->get()
            ->map(function($encounter) {
                return [
                    'id' => $encounter->user->id,
                    'name' => $encounter->user->name,
                    'gender' => $encounter->user->gender,
                    'age' => $encounter->user->age,
                    'photo' => $encounter->user->photo,
                ];
            });

        return response()->json($users);
    }

}
