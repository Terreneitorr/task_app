import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

/// Estados posibles de la autenticación
enum AuthStatus { idle, loading, success, error }

/// ViewModel de autenticación — conecta la UI con el repositorio.
/// Extiende ChangeNotifier para notificar cambios a Provider.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ── Estado interno ────────────────────────────────────────
  AuthStatus _status       = AuthStatus.idle;
  UserModel? _currentUser;
  String     _errorMessage = '';
  bool       _obscurePassword = true;

  // ── Usuarios registrados en esta sesión (persisten en memoria) ──
  final List<Map<String, dynamic>> _registeredUsers = [];

  // ── Regex de validación ───────────────────────────────────
  final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

  // ── Getters públicos ──────────────────────────────────────
  AuthStatus get status          => _status;
  UserModel? get currentUser     => _currentUser;
  String     get errorMessage    => _errorMessage;
  bool       get obscurePassword => _obscurePassword;
  bool       get isLoading       => _status == AuthStatus.loading;
  bool       get isLoggedIn      => _currentUser != null;

  // ── Controllers de formulario ─────────────────────────────
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final nameController     = TextEditingController();
  final usernameController = TextEditingController();

  // ── Métodos ───────────────────────────────────────────────

  /// Alterna visibilidad de contraseña
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// LOGIN — valida, busca en registrados locales y luego en API
  Future<bool> login() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    // ── Validaciones ──────────────────────────────────────
    if (email.isEmpty || password.isEmpty) {
      _setError('Por favor completa todos los campos.');
      return false;
    }

    if (!_emailRegex.hasMatch(email)) {
      _setError('Ingresa un correo electrónico válido.');
      return false;
    }

    if (password.length < 6) {
      _setError('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // 1. Busca primero en usuarios registrados localmente
      final localMatch = _registeredUsers.firstWhere(
            (u) => u['email'] == email.toLowerCase(),
        orElse: () => {},
      );

      if (localMatch.isNotEmpty) {
        _currentUser = UserModel(
          id:       localMatch['id'],
          name:     localMatch['name'],
          email:    localMatch['email'],
          username: localMatch['username'],
        );
        _status = AuthStatus.success;
        notifyListeners();
        return true;
      }

      // 2. Si no está local, busca en la API de JSONPlaceholder
      final user = await _authRepository.login(email, password);

      if (user == null) {
        _setError('Correo no encontrado. Intenta con otro email.');
        return false;
      }

      _currentUser = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Error de conexión. Revisa tu internet.');
      return false;
    }
  }

  /// REGISTER — valida y crea un usuario nuevo
  Future<bool> register() async {
    final name     = nameController.text.trim();
    final email    = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // ── Validaciones ──────────────────────────────────────
    if (name.isEmpty || email.isEmpty ||
        username.isEmpty || password.isEmpty) {
      _setError('Por favor completa todos los campos.');
      return false;
    }

    if (name.length < 3) {
      _setError('El nombre debe tener al menos 3 caracteres.');
      return false;
    }

    if (!_emailRegex.hasMatch(email)) {
      _setError('Ingresa un correo electrónico válido.');
      return false;
    }

    if (password.length < 6) {
      _setError('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    if (username.contains(' ')) {
      _setError('El usuario no debe contener espacios.');
      return false;
    }

    if (username.length < 3) {
      _setError('El usuario debe tener al menos 3 caracteres.');
      return false;
    }

    // Verificar si el email ya está registrado localmente
    final existe = _registeredUsers.any(
          (u) => u['email'] == email.toLowerCase(),
    );
    if (existe) {
      _setError('Este correo ya está registrado.');
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _authRepository.register(name, email, username);

      // Guardar en memoria para poder hacer login después
      _registeredUsers.add({
        'email':    email.toLowerCase(),
        'name':     user.name,
        'username': user.username,
        'id':       user.id,
        'password': password,
      });

      _currentUser = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Error al registrar. Intenta de nuevo.');
      return false;
    }
  }

  /// LOGOUT — limpia el estado (pero mantiene _registeredUsers)
  void logout() {
    _currentUser = null;
    _status      = AuthStatus.idle;
    _errorMessage = '';
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    usernameController.clear();
    notifyListeners();
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = '';
    _status = AuthStatus.idle;
    notifyListeners();
  }

  /// Helper privado para setear errores sin repetir código
  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}