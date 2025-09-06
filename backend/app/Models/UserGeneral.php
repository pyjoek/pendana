<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserGeneral extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'dob', 'purpose', 'interests', 'profile_picture', 'bio'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
