import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

///  Pantalla de perfil usando Row, Column y Stack.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user  = context.watch<AuthViewModel>().currentUser;
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {},
            tooltip: 'Ajustes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ── 1. Foto + nombre centrado ──────────────────
            Column(
              children: [
                // CircleAvatar con borde
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: 52,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Nombre
                Text(
                  user?.name ?? 'Usuario',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),

                // Username / descripción
                Text(
                  '@${user?.username ?? 'username'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),

                // Row con ícono y ubicación
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Chiapas, México',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── 2. Tres stats con Row ──────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(value: '128',  label: 'Posts'),
                  // Divider vertical
                  Container(
                    height: 40,
                    width: 1,
                    color: cs.outlineVariant,
                  ),
                  _StatItem(value: '12.5k', label: 'Seguidores'),
                  Container(
                    height: 40,
                    width: 1,
                    color: cs.outlineVariant,
                  ),
                  _StatItem(value: '943',  label: 'Seguidos'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 3. Banner con Badge usando Stack ──────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner principal
                Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flutter_dash_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 40),
                      const SizedBox(width: 12),
                      Text(
                        'Flutter\nDev',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge superpuesto con Positioned
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: cs.error.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'DESTACADO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Info del usuario de la API ─────────────────
            Card(
              child: ListTile(
                leading: Icon(Icons.email_outlined, color: cs.primary),
                title: const Text('Correo'),
                subtitle: Text(user?.email ?? '—'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.badge_outlined, color: cs.primary),
                title: const Text('ID de usuario'),
                subtitle: Text('#${user?.id ?? '—'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget auxiliar para estadísticas ─────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}