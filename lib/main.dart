import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/http_client.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/auth/views/login_screen.dart';

import 'features/tasks/data/repositories/task_repository.dart';
import 'features/tasks/viewmodels/task_viewmodel.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {

    // ── Inyección de dependencias manual ──────────────────
    // Creamos una sola instancia del cliente HTTP
    final apiClient = ApiClient();

    // Creamos los repositorios inyectando el cliente
    final authRepository = AuthRepository(apiClient: apiClient);
    final taskRepository = TaskRepository(apiClient: apiClient);

    return MultiProvider(
      providers: [
        // AuthViewModel — gestiona login y registro
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        // TaskViewModel — gestiona el CRUD de tareas
        ChangeNotifierProvider(
          create: (_) => TaskViewModel(taskRepository: taskRepository),
        ),
      ],
      child: MaterialApp(
        // ── Configuración general ────────────────────────
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // ── Material Theme 3 ─────────────────────────────
        theme: AppTheme.lightTheme,

        // ── Pantalla inicial ─────────────────────────────
        // Navegación 1.0 con MaterialPageRoute
        home: const LoginScreen(),
      ),
    );
  }
}