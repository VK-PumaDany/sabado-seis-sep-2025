<?php

use Illuminate\Support\Facades\Route;
use App\Models\User;

Route::get('/', function () {
    return view('welcome');
});



// Route::get('/app', function () {
//     return view('plantilla.app');
// });

Route::get('/app', function () {
    $usuarios = User::all();
    return view('usuario.index', ['usuarios' => $usuarios]);
});

Route::get('/action', function () {
    return view('usuario.action');
});
