import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../data/models/task_model.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';
import '../../auth/views/login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Carga las tareas al iniciar la pantalla
    Future.microtask(() =>
        context.read<TaskViewModel>().loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final taskVm = context.watch<TaskViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final theme  = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),

      // ── AppBar ─────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: () => taskVm.loadTasks(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              authVm.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      // ── FAB — nueva tarea ──────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva tarea'),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),

      body: taskVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskVm.status == TaskStatus.error
          ? _ErrorWidget(
        message: taskVm.errorMessage,
        onRetry: () => taskVm.loadTasks(),
      )
          : CustomScrollView(
        slivers: [
          // ── Banner de bienvenida ─────────────────
          SliverToBoxAdapter(
            child: _WelcomeBanner(
              userName: authVm.currentUser?.name ?? 'Usuario',
              total:     taskVm.totalTasks,
              completed: taskVm.completedTasks,
              pending:   taskVm.pendingTasks,
            ),
          ),

          // ── Buscador ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                onChanged: taskVm.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Buscar tarea...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),

          // ── Título sección ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Lista de tareas (${taskVm.tasks.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6750A4),
                ),
              ),
            ),
          ),

          // ── Lista de tareas ───────────────────────
          taskVm.tasks.isEmpty
              ? SliverToBoxAdapter(
            child: _EmptyWidget(),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final task = taskVm.tasks[index];
                return _TaskCard(
                  task: task,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TaskDetailScreen(task: task),
                    ),
                  ),
                  onToggle: () => taskVm.toggleTask(task),
                  onDelete: () => _confirmDelete(
                      context, taskVm, task),
                );
              },
              childCount: taskVm.tasks.length,
            ),
          ),

          // Espacio para el FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 90),
          ),
        ],
      ),
    );
  }

  /// Diálogo de confirmación antes de eliminar
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
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Widget: Banner superior con estadísticas ───────────────
class _WelcomeBanner extends StatelessWidget {
  final String userName;
  final int total, completed, pending;
  const _WelcomeBanner({
    required this.userName,
    required this.total,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6750A4), Color(0xFF9C89C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6750A4).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola, $userName!',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Text('Aquí están tus tareas',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Estadísticas en fila
          Row(
            children: [
              _StatChip(label: 'Total',     value: total,     icon: Icons.list_alt_rounded),
              const SizedBox(width: 10),
              _StatChip(label: 'Hechas',    value: completed, icon: Icons.check_circle_rounded),
              const SizedBox(width: 10),
              _StatChip(label: 'Pendientes',value: pending,   icon: Icons.pending_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text('$value',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Tarjeta de tarea ───────────────────────────────
class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: task.completed
                  ? const Color(0xFF6750A4)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              task.completed
                  ? Icons.check_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: task.completed ? Colors.white : Colors.grey,
              size: 22,
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration:
            task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: task.completed
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.completed
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Text(
                  task.completed ? 'Completada' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 11,
                    color: task.completed
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('#${task.id}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF6750A4)),
              onPressed: onTap,
              tooltip: 'Ver detalle',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Estado vacío ───────────────────────────────────
class _EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No hay tareas',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Toca + para crear una nueva',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Error ──────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 70, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}