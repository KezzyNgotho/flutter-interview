<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Question extends Model
{
    use HasFactory;

    protected $fillable = ['paper_id', 'question', 'answer'];

    public function paper()
    {
        return $this->belongsTo(Paper::class);
    }

    public function answers()
    {
        return $this->hasMany(Answer::class);
    }
}
