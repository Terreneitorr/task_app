/// Modelo de tarea que mapea el endpoint /todos de JSONPlaceholder
class TaskModel {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  /// Convierte JSON a TaskModel
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 1,
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  /// Convierte TaskModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed,
    };
  }

  /// Crea una copia con campos modificados (útil para actualizar)
  TaskModel copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}