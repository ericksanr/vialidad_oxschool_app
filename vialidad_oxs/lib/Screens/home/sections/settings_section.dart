import 'package:flutter/material.dart';
import '../../../Models/User.dart';

class SettingsSection extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const SettingsSection({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Configuración',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),

        // Profile Section
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              user.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('Empleado #${user.employeeNumber}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUserProfile(context),
          ),
        ),

        const SizedBox(height: 16),

        // Settings Options
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.primary,
                ),
                title: const Text('Notificaciones'),
                subtitle: const Text('Configurar alertas y notificaciones'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.security_outlined,
                  color: colorScheme.primary,
                ),
                title: const Text('Seguridad'),
                subtitle: const Text('Cambiar contraseña y configuraciones'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.help_outline, color: colorScheme.primary),
                title: const Text('Ayuda y Soporte'),
                subtitle: const Text('FAQ y contacto de soporte'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
          ),
        ),
      ],
    );
  }

  void _showUserProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perfil de Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Nombre', user.name),
            _buildProfileRow('Número de Empleado', '${user.employeeNumber}'),
            _buildProfileRow('Campus', user.campus),
            _buildProfileRow(
              'Rol',
              user.isAdmin == 1 ? 'Administrador' : 'Usuario',
            ),
            _buildProfileRow('Estado', user.isActive ? 'Activo' : 'Inactivo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
