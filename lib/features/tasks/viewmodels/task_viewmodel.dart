import 'package:flutter/material.dart';
import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';

/// Estados posibles de las tareas
enum TaskStatus { idle, loading, success, error }

/// ViewModel de tareas — gestiona el CRUD completo.
/// Notifica a la UI cada cambio de estado mediante Provider.
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository;

  TaskViewModel({required TaskRepository taskRepository})
      : _taskRepository = taskRepository;

  // ── Estado interno ────────────────────────────────────────
  TaskStatus _status = TaskStatus.idle;
  List<TaskModel> _tasks = [];
  String _errorMessage = '';
  String _searchQuery = '';

  // Controller para el formulario de crear/editar tarea
  final titleController = TextEditingController();

  // ── Getters públicos ──────────────────────────────────────
  TaskStatus      get status       => _status;
  String          get errorMessage => _errorMessage;
  bool            get isLoading    => _status == TaskStatus.loading;

  /// Lista filtrada según búsqueda
  List<TaskModel> get tasks {
    if (_searchQuery.isEmpty) return _tasks;
    return _tasks
        .where((t) =>
        t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  /// Contadores para el dashboard
  int get totalTasks     => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.completed).length;
  int get pendingTasks   => _tasks.where((t) => !t.completed).length;

  // ── Métodos ───────────────────────────────────────────────

  /// Actualiza el texto de búsqueda
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// GET — carga todas las tareas desde la API
  Future<void> loadTasks() async {
    _status = TaskStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _tasks = await _taskRepository.getTasks();
      _status = TaskStatus.success;
    } catch (e) {
      _errorMessage = 'Error al cargar tareas. Revisa tu conexión.';
      _status = TaskStatus.error;
    }
    notifyListeners();
  }

  /// POST — crea una nueva tarea
  Future<bool> createTask(int userId) async {
    if (titleController.text.trim().isEmpty) {
      _errorMessage = 'El título no puede estar vacío.';
      notifyListeners();
      return false;
    }

    _status = TaskStatus.loading;
    notifyListeners();

    try {
      final newTask = await _taskRepository.createTask(
        titleController.text.trim(),
        userId,
      );

      // Insertamos al inicio de la lista para verla de inmediato
      _tasks.insert(0, newTask.copyWith(id: _tasks.length + 1));
      _status = TaskStatus.success;
      titleController.clear();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear la tarea.';
      _status = TaskStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// PUT — alterna el estado completado/pendiente de una tarea
  Future<void> toggleTask(TaskModel task) async {
    // Actualización optimista: cambia en UI antes de esperar la API
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final updated = task.copyWith(completed: !task.completed);
    _tasks[index] = updated;
    notifyListeners();

    try {
      await _taskRepository.updateTask(updated);
    } catch (e) {
      // Si falla, revertimos el cambio
      _tasks[index] = task;
      _errorMessage = 'Error al actualizar la tarea.';
      notifyListeners();
    }
  }

  /// PUT — edita el título de una tarea
  Future<bool> editTask(TaskModel task) async {
    if (titleController.text.trim().isEmpty) return false;

    _status = TaskStatus.loading;
    notifyListeners();

    try {
      final updated = task.copyWith(title: titleController.text.trim());
      await _taskRepository.updateTask(updated);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) _tasks[index] = updated;

      _status = TaskStatus.success;
      titleController.clear();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al editar la tarea.';
      _status = TaskStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// DELETE — elimina una tarea por ID
  Future<void> deleteTask(int taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al eliminar la tarea.';
      notifyListeners();
    }
  }

  /// Limpia errores
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}