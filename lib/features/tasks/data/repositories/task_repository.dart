import '../../../../core/network/http_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/task_model.dart';

/// Repositorio de tareas.
/// Implementa el CRUD completo usando JSONPlaceholder.
class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET — obtiene las primeras 20 tareas del usuario
  Future<List<TaskModel>> getTasks() async {
    final data = await _apiClient.get(
      '${AppConstants.todosEndpoint}?_limit=20',
    );
    final List list = data as List;
    return list.map((json) => TaskModel.fromJson(json)).toList();
  }

  /// GET por ID — obtiene una tarea específica
  Future<TaskModel> getTaskById(int id) async {
    final data = await _apiClient.get(
      '${AppConstants.todosEndpoint}/$id',
    );
    return TaskModel.fromJson(data);
  }

  /// POST — crea una tarea nueva
  Future<TaskModel> createTask(String title, int userId) async {
    final data = await _apiClient.post(
      AppConstants.todosEndpoint,
      {
        'title': title,
        'userId': userId,
        'completed': false,
      },
    );
    return TaskModel.fromJson(data);
  }

  /// PUT — actualiza una tarea completa
  Future<TaskModel> updateTask(TaskModel task) async {
    final data = await _apiClient.put(
      '${AppConstants.todosEndpoint}/${task.id}',
      task.toJson(),
    );
    return TaskModel.fromJson(data);
  }

  /// DELETE — elimina una tarea por ID
  Future<void> deleteTask(int id) async {
    await _apiClient.delete('${AppConstants.todosEndpoint}/$id');
  }
}