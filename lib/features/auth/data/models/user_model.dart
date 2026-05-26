/// Modelo de usuario que mapea la respuesta de JSONPlaceholder
class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
  });

  /// Convierte JSON a UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
    );
  }

  /// Convierte UserModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
    };
  }
}