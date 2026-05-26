import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/task_model.dart';
import '../viewmodels/task_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class TaskFormScreen extends StatefulWidget {
  /// Si es null, es modo CREAR. Si tiene valor, es modo EDITAR.
  final TaskModel? taskToEdit;
  const TaskFormScreen({super.key, this.taskToEdit});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-llenamos el campo con el título actual
    if (isEditing) {
      Future.microtask(() {
        context.read<TaskViewModel>().titleController.text =
            widget.taskToEdit!.title;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskVm = context.watch<TaskViewModel>();
    final authVm = context.read<AuthViewModel>();
    final theme  = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        title: Text(isEditing ? 'Editar tarea' : 'Nueva tarea'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ilustrativo ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isEditing
                      ? [Colors.blue.shade700, Colors.blue.shade400]
                      : [const Color(0xFF6750A4), const Color(0xFF9C89C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEditing
                          ? Icons.edit_rounded
                          : Icons.add_task_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Editar tarea' : 'Crear nueva tarea',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isEditing
                              ? 'Modifica el título de tu tarea'
                              : 'Agrega una nueva tarea a tu lista',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Formulario ────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Título de la tarea',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo de texto
                    TextField(
                      controller: taskVm.titleController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Revisar documentación de Flutter...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.title_rounded),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),

                    // Error
                    if (taskVm.errorMessage.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade400, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                taskVm.errorMessage,
                                style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Botón guardar
                    taskVm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                      onPressed: () async {
                        bool ok;
                        if (isEditing) {
                          ok = await taskVm.editTask(
                              widget.taskToEdit!);
                        } else {
                          ok = await taskVm.createTask(
                              authVm.currentUser?.id ?? 1);
                        }
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing
                                  ? '✅ Tarea actualizada'
                                  : '✅ Tarea creada'),
                              backgroundColor:
                              const Color(0xFF386A20),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(isEditing
                          ? Icons.save_rounded
                          : Icons.add_rounded),
                      label: Text(
                          isEditing ? 'Guardar cambios' : 'Crear tarea'),
                    ),

                    const SizedBox(height: 12),

                    // Botón cancelar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          taskVm.titleController.clear();
                          taskVm.clearError();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info si estamos editando ───────────────────
            if (isEditing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade600, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Editando tarea #${widget.taskToEdit!.id}',
                        style: TextStyle(
                            color: Colors.blue.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}