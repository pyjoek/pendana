<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MessageController extends Controller
{
    // Send a message
    public function store(Request $request)
    {
        $request->validate([
            'receiver_id' => 'required|exists:users,id',
            'message' => 'required|string',
        ]);

        $message = Message::create([
            'sender_id' => $request->sender_id, // logged-in user
            'receiver_id' => $request->receiver_id,
            'message' => $request->message,
        ]);

        return response()->json($message, 201);
    }

    // Get conversation between two users
    public function conversation($receiverId)
    {
        $messages = Message::where(function($q) use ($receiverId) {
                $q->where('sender_id', Auth::id())
                  ->where('receiver_id', $receiverId);
            })
            ->orWhere(function($q) use ($receiverId) {
                $q->where('sender_id', $receiverId)
                  ->where('receiver_id', Auth::id());
            })
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json($messages);
    }

    public function chats($userId)
    {
        // get all unique user IDs this person has chatted with
        $chats = Message::where('sender_id', $userId)
            ->orWhere('receiver_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get()
            ->groupBy(function ($msg) use ($userId) {
                // group by the *other user id*
                return $msg->sender_id == $userId ? $msg->receiver_id : $msg->sender_id;
            });

        $result = [];

        foreach ($chats as $otherUserId => $messages) {
            $lastMessage = $messages->sortByDesc('created_at')->first();

            $result[] = [
                'other_user_id' => $otherUserId,
                'other_user_name' => User::find($otherUserId)?->name ?? "Unknown",
                'messages' => $messages->map(function ($m) {
                    return [
                        'id' => $m->id,
                        'sender_id' => $m->sender_id,
                        'receiver_id' => $m->receiver_id,
                        'message' => $m->message,
                        'created_at' => $m->created_at,
                    ];
                })->values(),
                'last_message' => $lastMessage->message,
                'last_message_time' => $lastMessage->created_at,
            ];
        }

        return response()->json($result);
    }
}
