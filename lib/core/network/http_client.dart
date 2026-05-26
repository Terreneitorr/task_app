import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Cliente HTTP centralizado para todas las peticiones de la app.
/// Encapsula los métodos GET, POST, PUT y DELETE.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Cabeceras comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// GET — obtiene recursos
  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// POST — crea un recurso
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// PUT — actualiza un recurso completo
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// DELETE — elimina un recurso
  Future<void> delete(String endpoint) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar: ${response.statusCode}');
    }
  }

  /// Maneja la respuesta y lanza excepción si hay error
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }
}