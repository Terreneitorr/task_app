import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/network/http_client.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/util.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/auth/views/login_screen.dart';
import 'features/tasks/data/repositories/task_repository.dart';
import 'features/tasks/viewmodels/task_viewmodel.dart';

/// Punto central de configuración de la app.
/// Maneja tema, providers e inyección de dependencias.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    final textTheme = createTextTheme(context, "Roboto", "Montserrat");
    final theme     = MaterialTheme(textTheme);

    final apiClient      = ApiClient();
    final authRepository = AuthRepository(apiClient: apiClient);
    final taskRepository = TaskRepository(apiClient: apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskViewModel(taskRepository: taskRepository),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme:      theme.light(),
        darkTheme:  theme.dark(),
        themeMode:  ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}