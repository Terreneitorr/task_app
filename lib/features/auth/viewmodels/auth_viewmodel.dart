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
  AuthStatus _status = AuthStatus.idle;
  UserModel? _currentUser;
  String _errorMessage = '';
  bool _obscurePassword = true;

  // ── Getters públicos (la UI solo lee, no escribe directo) ──
  AuthStatus get status        => _status;
  UserModel? get currentUser   => _currentUser;
  String     get errorMessage  => _errorMessage;
  bool       get obscurePassword => _obscurePassword;
  bool       get isLoading     => _status == AuthStatus.loading;
  bool       get isLoggedIn    => _currentUser != null;

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

  /// LOGIN — busca el usuario en la API
  Future<bool> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _errorMessage = 'Por favor completa todos los campos.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user == null) {
        _errorMessage = 'Correo no encontrado. Intenta con otro email.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error de conexión. Revisa tu internet.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// REGISTER — crea un usuario nuevo
  Future<bool> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty) {
      _errorMessage = 'Por favor completa todos los campos.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _authRepository.register(
        nameController.text.trim(),
        emailController.text.trim(),
        usernameController.text.trim(),
      );

      _currentUser = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar. Intenta de nuevo.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// LOGOUT — limpia el estado
  void logout() {
    _currentUser = null;
    _status = AuthStatus.idle;
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}