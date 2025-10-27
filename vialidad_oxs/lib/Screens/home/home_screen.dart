import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:vialidad_oxs/Controller/device_controller.dart';
import 'package:vialidad_oxs/config/temp/temp_data.dart';
import '../../Models/User.dart';
import 'sections/traffic_section.dart';
import 'sections/reports_section.dart';
import 'sections/settings_section.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    getDeviceInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    deviceData = {};
    tempUser = null;
  }

  void getDeviceInfo() async {
    deviceData = await getDeviceDetail();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.school, color: colorScheme.onPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Vialidad OxSchool',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showUserProfile(context),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: _buildBody(context)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.child_care),
            selectedIcon: Icon(Icons.traffic),
            label: 'Vialidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_filled_outlined),
            selectedIcon: Icon(Icons.report),
            label: 'Visitantes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard(context);
      case 1:
        return const TrafficSection();
      case 2:
        return const ReportsSection();
      case 3:
        return SettingsSection(user: widget.user, onLogout: _logout);
      default:
        return _buildDashboard(context);
    }
  }

  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return CustomScrollView(
      slivers: [
        // Welcome Section
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola! 👋 ',
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.name,
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.user.campus,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.user.isAdmin == 1)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: colorScheme.onSecondary,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acciones Rápidas',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Feature Cards Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              childAspectRatio: isTablet ? 1.2 : 1.0, // Adjusted aspect ratio
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildListDelegate([
              _buildFeatureCard(
                context,
                'Control de alumnos',
                'Gestionar el flujo de alumnos',
                Icons.child_care,
                colorScheme.primary,
                () => _navigateToTraffic(),
              ),
              _buildFeatureCard(
                context,
                'Control de visitantes',
                'Visitantes y accesos',
                Icons.directions_car,
                colorScheme.secondary,
                () => _navigateToReports(),
              ),
              // _buildFeatureCard(
              //   context,
              //   'Incidentes',
              //   'Registrar incidentes',
              //   Icons.warning,
              //   const Color(0xFFFF9800),
              //   () => _navigateToIncidents(),
              // ),
              // _buildFeatureCard(
              //   context,
              //   'Configuración',
              //   'Ajustes del sistema',
              //   Icons.settings,
              //   const Color(0xFF4CAF50),
              //   () => _navigateToSettings(),
              // ),
              if (widget.user.isAdmin == 1) ...[
                _buildFeatureCard(
                  context,
                  'Usuarios',
                  'Gestionar usuarios',
                  Icons.people,
                  const Color(0xFF9C27B0),
                  () => _navigateToUsers(),
                ),
                _buildFeatureCard(
                  context,
                  'Campus',
                  'Gestionar campus',
                  Icons.school,
                  const Color(0xFF607D8B),
                  () => _navigateToCampus(),
                ),
              ],
            ]),
          ),
        ),

        // Recent Activity
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Actividad Reciente',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentActivityCard(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Allow column to shrink
            children: [
              Container(
                width: 40, // Slightly smaller icon container
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22), // Smaller icon
              ),
              const SizedBox(height: 8), // Reduced spacing
              Flexible(
                // Make text flexible
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    // Smaller text style
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                // Make subtitle flexible
                child: Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11, // Smaller font size
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActivityItem(
              context,
              'Control de tráfico actualizado',
              'Hace 2 horas',
              Icons.traffic,
              colorScheme.primary,
            ),
            const Divider(height: 24),
            _buildActivityItem(
              context,
              'Nuevo reporte generado',
              'Hace 4 horas',
              Icons.analytics,
              colorScheme.secondary,
            ),
            const Divider(height: 24),
            _buildActivityItem(
              context,
              'Incidente resuelto',
              'Ayer',
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
            _buildProfileRow('Nombre', widget.user.name),
            _buildProfileRow(
              'Número de Empleado',
              '${widget.user.employeeNumber}',
            ),
            _buildProfileRow('Campus', widget.user.campus),
            _buildProfileRow(
              'Rol',
              widget.user.isAdmin == 1 ? 'Administrador' : 'Usuario',
            ),
            _buildProfileRow(
              'Estado',
              widget.user.isActive ? 'Activo' : 'Inactivo',
            ),
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

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _navigateToTraffic() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _navigateToReports() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _navigateToUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestión de usuarios próximamente')),
    );
  }

  void _navigateToCampus() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestión de campus próximamente')),
    );
  }
}
