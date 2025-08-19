<?php

namespace Database\Seeders;

use App\Models\{User, Subject, Paper, Question};
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::query()->delete();
        Subject::query()->delete();
        Paper::query()->delete();
        Question::query()->delete();

        User::factory()->create([
            'name' => 'Demo User',
            'email' => 'demo@example.com',
            'password' => Hash::make('password'),
        ]);

        $math = Subject::create(['name' => 'Mathematics']);
        $eng = Subject::create(['name' => 'English']);

        foreach ([$math, $eng] as $subject) {
            for ($y = 2022; $y <= 2024; $y++) {
                $paper = Paper::create([
                    'subject_id' => $subject->id,
                    'title' => $subject->name.' Paper '.$y,
                    'year' => $y,
                ]);
                for ($i = 1; $i <= 5; $i++) {
                    Question::create([
                        'paper_id' => $paper->id,
                        'question' => "Question $i for {$paper->title}",
                        'answer' => "Answer $i",
                    ]);
                }
            }
        }
    }
}
