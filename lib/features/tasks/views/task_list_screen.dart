import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../data/models/task_model.dart';
import 'task_form_screen.dart';
import '../../profile/views/profile_screen.dart';
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
    Future.microtask(() => context.read<TaskViewModel>().loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final taskVm = context.watch<TaskViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final theme  = Theme.of(context);
    final cs     = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,

      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        title: Text('Mis Tareas', style: TextStyle(color: cs.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_rounded, color: cs.onSurface),
            tooltip: 'Mi perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: cs.onSurface),
            tooltip: 'Recargar',
            onPressed: () => taskVm.loadTasks(),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: cs.onSurface),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva tarea'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),

      body: taskVm.isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : taskVm.status == TaskStatus.error
          ? _ErrorWidget(
        message: taskVm.errorMessage,
        onRetry: () => taskVm.loadTasks(),
      )
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _WelcomeBanner(
              userName: authVm.currentUser?.name ?? 'Usuario',
              total:     taskVm.totalTasks,
              completed: taskVm.completedTasks,
              pending:   taskVm.pendingTasks,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                onChanged: taskVm.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Buscar tarea...',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Lista de tareas (${taskVm.tasks.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          taskVm.tasks.isEmpty
              ? SliverToBoxAdapter(child: _EmptyWidget())
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final task = taskVm.tasks[index];
                return _TaskCard(
                  task: task,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(task: task),
                    ),
                  ),
                  onToggle: () => taskVm.toggleTask(task),
                  onDelete: () => _confirmDelete(context, taskVm, task),
                );
              },
              childCount: taskVm.tasks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskViewModel vm, TaskModel task) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Eliminar tarea', style: TextStyle(color: cs.onSurface)),
        content: Text('¿Deseas eliminar "${task.title}"?',
            style: TextStyle(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: cs.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
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

// ── Banner superior ────────────────────────────────────────
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 👈 antes: gradient morado hardcodeado
        gradient: LinearGradient(
          colors: [cs.primary, cs.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
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
              CircleAvatar(
                backgroundColor: cs.onPrimary.withOpacity(0.2),
                child: Icon(Icons.person_rounded, color: cs.onPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola, $userName!',
                        style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text('Aquí están tus tareas',
                        style: TextStyle(
                            color: cs.onPrimary.withOpacity(0.7),
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(label: 'Total',      value: total,     icon: Icons.list_alt_rounded),
              const SizedBox(width: 10),
              _StatChip(label: 'Hechas',     value: completed, icon: Icons.check_circle_rounded),
              const SizedBox(width: 10),
              _StatChip(label: 'Pendientes', value: pending,   icon: Icons.pending_rounded),
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
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cs.onPrimary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.onPrimary, size: 20),
            const SizedBox(height: 4),
            Text('$value',
                style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(label,
                style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de tarea ───────────────────────────────────────
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
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainerLow,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // 👈 antes: Color(0xFF6750A4) / Colors.grey.shade200
              color: task.completed ? cs.primary : cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              task.completed
                  ? Icons.check_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: task.completed ? cs.onPrimary : cs.onSurfaceVariant,
              size: 22,
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            // 👈 antes: Colors.black87 / Colors.grey
            color: task.completed ? cs.onSurfaceVariant : cs.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  // 👈 antes: Colors.green.shade50 / Colors.orange.shade50
                  color: task.completed
                      ? cs.secondaryContainer
                      : cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.completed
                        ? cs.secondary
                        : cs.tertiary,
                  ),
                ),
                child: Text(
                  task.completed ? 'Completada' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 11,
                    // 👈 antes: Colors.green.shade700 / Colors.orange.shade700
                    color: task.completed
                        ? cs.onSecondaryContainer
                        : cs.onTertiaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('#${task.id}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info_outline_rounded, color: cs.primary),
              onPressed: onTap,
              tooltip: 'Ver detalle',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: cs.error),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estado vacío ───────────────────────────────────────────
class _EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text('No hay tareas',
                style: TextStyle(
                    fontSize: 18,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Toca + para crear una nueva',
                style: TextStyle(fontSize: 13, color: cs.outline)),
          ],
        ),
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 70, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
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