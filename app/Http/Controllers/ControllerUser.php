<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ControllerUser extends Controller
{
    // 🔹 Mostrar todos los usuarios
    public function index()
    {
        $users = User::all();
        return response()->json($users);
    }

    // 🔹 Crear un nuevo usuario
    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'age'      => 'required|integer',
            'document' => 'required|string|unique:users',
            'active'   => 'boolean',
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password), // 🔐 importante encriptar
            'age'      => $request->age,
            'document' => $request->document,
            'active'   => $request->active ?? true,
        ]);

        return response()->json($user, 201);
    }

    // 🔹 Mostrar un usuario específico
    public function show($id)
    {
        $user = User::findOrFail($id);
        return response()->json($user);
    }

    // 🔹 Actualizar un usuario
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $request->validate([
            'name'     => 'sometimes|string|max:255',
            'email'    => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'sometimes|string|min:6',
            'age'      => 'sometimes|integer',
            'document' => 'sometimes|string|unique:users,document,' . $user->id,
            'active'   => 'boolean',
        ]);

        $user->update([
            'name'     => $request->name ?? $user->name,
            'email'    => $request->email ?? $user->email,
            'password' => $request->password ? Hash::make($request->password) : $user->password,
            'age'      => $request->age ?? $user->age,
            'document' => $request->document ?? $user->document,
            'active'   => $request->active ?? $user->active,
        ]);

        return response()->json($user);
    }

    // 🔹 Eliminar un usuario
    public function destroy($id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json(['message' => 'Usuario eliminado correctamente']);
    }
}
