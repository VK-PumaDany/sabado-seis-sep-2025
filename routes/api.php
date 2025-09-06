<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ControllerUser;

// 👇 Tu CRUD de usuarios
Route::resource('users', ControllerUser::class);

