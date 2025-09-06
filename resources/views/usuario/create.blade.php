@extends('plantilla.app')
@section('contenido')
    <div class="app-content">
        <!--begin::Container-->
        <div class="container-fluid">
            <!--begin::Row-->
            <div class="row">
                <div class="col-md-12">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h3 class="card-title">Crear Usuario</h3>
                        </div>
                        <!-- /.card-header -->
                        <div class="card-body">
                            <form id="formRegistroUsuario">
                                @csrf
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="name" class="form-label">Nombre</label>
                                        <input type="text" class="form-control" id="name" name="name" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="email" class="form-label">Email</label>
                                        <input type="email" class="form-control" id="email" name="email" required>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="password" class="form-label">Password</label>
                                        <input type="password" class="form-control" id="password" name="password" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="active" class="form-label">Estado</label>
                                        <select class="form-select" name="active" id="active">
                                            <option value="1">Activo</option>
                                            <option value="0">Inactivo</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <button type="button" class="btn btn-secondary me-md-2"
                                        onclick="window.location.href='/app'">Cancelar</button>
                                    <button type="button" class="btn btn-primary" id="btnGuardarUsuario">Guardar</button>
                                </div>
                            </form>
                        </div>
                        <!-- /.card-body -->
                        <div class="card-footer clearfix">

                        </div>
                    </div>
                    <!-- /.card -->
                </div>
                <!-- /.col -->
            </div>
            <!--end::Row-->
        </div>
        <!--end::Container-->
    </div>
@endsection

@push('scripts')
    <script>
        // document.getElementById('menuSeguridad').classList.add('menu-open');
        // document.getElementById('itemUsuario').classList.add('active');

        const savedBtn = document.getElementById('btnGuardarUsuario')
        console.log(savedBtn);
        savedBtn.addEventListener('click', async function() {
            const form = document.getElementById('formRegistroUsuario');
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);
            console.log(data);
            try {
                const response = await fetch('http://127.0.0.1:8000/api/users', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({
                        ...data,
                        active: data.active === '1'
                    })
                });

                if (!response.ok) throw new Error('Error al crear usuario');

                const result = await response.json();
                alert('✅ Usuario creado: ' + result.name);

                window.location.href = '/app';
            } catch (error) {
                alert('❌ ' + error.message);
            }
        });


        // const form = document.getElementById('formRegistroUsuario');

        // form.addEventListener('submit', async function(e) {
        //     e.preventDefault();

        //     const formData = new FormData(this);
        //     const data = Object.fromEntries(formData);

        //     try {
        //         const response = await fetch('http://127.0.0.1:8000/api/users', {
        //             method: 'POST',
        //             headers: {
        //                 'Content-Type': 'application/json',
        //                 'Accept': 'application/json',
        //                 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute(
        //                     'content')
        //             },
        //             body: JSON.stringify({
        //                 ...data,
        //                 active: data.active === '1'
        //             })
        //         });

        //         if (!response.ok) {
        //             throw new Error('Error al crear usuario');
        //         }

        //         const result = await response.json();
        //         alert('✅ Usuario creado: ' + result.name);

        //         // Redirigir a la lista de usuarios después de guardar
        //         window.location.href = '/app';
        //     } catch (error) {
        //         alert('❌ ' + error.message);
        //     }
        // });
    </script>
@endpush
