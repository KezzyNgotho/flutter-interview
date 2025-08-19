<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\Subject;
use App\Models\Paper;
use App\Models\Question;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

Route::post('/login', function (Request $request) {
    $validated = $request->validate([
        'email' => 'required|email',
        'password' => 'required',
    ]);

    $user = User::where('email', $validated['email'])->first();
    if (!$user || !Hash::check($validated['password'], $user->password)) {
        return response()->json(['message' => 'Invalid credentials'], 401);
    }
    $token = $user->createToken('api')->plainTextToken;
    return ['token' => $token];
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/subjects', function () {
        return Subject::select('id', 'name')->orderBy('name')->get();
    });

    Route::get('/papers', function (Request $request) {
        $query = Paper::with('subject')->select('id', 'subject_id', 'title', 'year');
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->integer('subject_id'));
        }
        if ($request->filled('year')) {
            $query->where('year', $request->integer('year'));
        }
        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where('title', 'like', "%{$q}%");
        }
        return $query->orderByDesc('year')->paginate(50);
    });

    Route::get('/papers/{paper}', function (Paper $paper) {
        $paper->load(['subject:id,name', 'questions:id,paper_id,question,answer']);
        return $paper;
    });
});


