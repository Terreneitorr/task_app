import '../../../../core/network/http_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Repositorio de autenticación.
/// Simula login/register usando la API pública de JSONPlaceholder.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// LOGIN — busca un usuario por email en la lista de usuarios
  Future<UserModel?> login(String email, String password) async {
    // JSONPlaceholder no tiene auth real, simulamos buscando por email
    final data = await _apiClient.get(AppConstants.usersEndpoint);
    final List users = data as List;

    // Buscamos el usuario cuyo email coincida (simulación)
    final match = users.firstWhere(
          (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
      orElse: () => null,
    );

    if (match == null) return null;
    return UserModel.fromJson(match);
  }

  /// REGISTER — crea un usuario nuevo con POST
  Future<UserModel> register(String name, String email, String username) async {
    final data = await _apiClient.post(
      AppConstants.usersEndpoint,
      {
        'name': name,
        'email': email,
        'username': username,
      },
    );
    return UserModel.fromJson(data);
  }
}