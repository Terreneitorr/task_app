import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/task_model.dart';
import '../viewmodels/task_viewmodel.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskVm = context.watch<TaskViewModel>();
    final theme  = Theme.of(context);

    // Buscamos la tarea actualizada en la lista (puede haber cambiado)
    final current = taskVm.tasks.firstWhere(
          (t) => t.id == task.id,
      orElse: () => task,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        title: const Text('Detalle de tarea'),
        actions: [
          // Botón editar
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskFormScreen(taskToEdit: current),
              ),
            ),
          ),
          // Botón eliminar
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Eliminar',
            onPressed: () => _confirmDelete(context, taskVm, current),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Hero card con estado ───────────────────────
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: current.completed
                          ? [const Color(0xFF386A20), const Color(0xFF6AAF45)]
                          : [const Color(0xFF6750A4), const Color(0xFF9C89C4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (current.completed
                            ? Colors.green
                            : const Color(0xFF6750A4))
                            .withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              current.completed
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              current.completed ? 'Completada' : 'Pendiente',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        current.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Icono decorativo en esquina
                Positioned(
                  right: 16,
                  top: 16,
                  child: Icon(
                    current.completed
                        ? Icons.task_alt_rounded
                        : Icons.assignment_rounded,
                    color: Colors.white.withOpacity(0.2),
                    size: 60,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Información en grid ────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _InfoCard(
                  icon: Icons.tag_rounded,
                  label: 'ID de tarea',
                  value: '#${current.id}',
                  color: const Color(0xFF6750A4),
                ),
                _InfoCard(
                  icon: Icons.person_outline_rounded,
                  label: 'Usuario ID',
                  value: 'Usuario ${current.userId}',
                  color: const Color(0xFF625B71),
                ),
                _InfoCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'Estado',
                  value: current.completed ? 'Finalizada' : 'En progreso',
                  color: current.completed
                      ? const Color(0xFF386A20)
                      : Colors.orange.shade700,
                ),
                _InfoCard(
                  icon: Icons.category_rounded,
                  label: 'Categoría',
                  value: 'General',
                  color: Colors.blue.shade700,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Acciones ──────────────────────────────────
            Text(
              'Acciones rápidas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6750A4),
              ),
            ),
            const SizedBox(height: 12),

            // Toggle completado
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: current.completed
                        ? Colors.green.shade50
                        : const Color(0xFF6750A4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    current.completed
                        ? Icons.unpublished_rounded
                        : Icons.check_circle_outline_rounded,
                    color: current.completed
                        ? Colors.green.shade600
                        : const Color(0xFF6750A4),
                  ),
                ),
                title: Text(
                  current.completed
                      ? 'Marcar como pendiente'
                      : 'Marcar como completada',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  taskVm.toggleTask(current);
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 8),

            // Editar
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit_rounded,
                      color: Colors.blue.shade600),
                ),
                title: const Text('Editar tarea',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskFormScreen(taskToEdit: current),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Eliminar
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete_rounded,
                      color: Colors.red.shade600),
                ),
                title: const Text('Eliminar tarea',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _confirmDelete(context, taskVm, current),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TaskViewModel vm, TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar tarea'),
        content: Text('¿Deseas eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400),
            onPressed: () {
              vm.deleteTask(task.id);
              Navigator.pop(context); // cierra dialog
              Navigator.pop(context); // regresa a la lista
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Widget: Tarjeta de información ────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}