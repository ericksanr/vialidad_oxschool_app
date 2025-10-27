import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:vialidad_oxs/Controller/login_controller.dart';
import 'package:vialidad_oxs/Services/login_service.dart';
import 'package:vialidad_oxs/Services/traffic_qr_service.dart';
import 'package:vialidad_oxs/config/temp/temp_data.dart';
import '../../qr_scanner_screen.dart';

class TrafficSection extends StatefulWidget {
  const TrafficSection({super.key});

  @override
  State<TrafficSection> createState() => _TrafficSectionState();
}

class _TrafficSectionState extends State<TrafficSection> {
  // Traffic control states - only one can be active at a time
  bool _isEntranceActive = false;
  bool _isExitActive = false;
  var deviceInfo;

  void _toggleEntrance() {
    setState(() {
      _isEntranceActive = !_isEntranceActive;
      if (_isEntranceActive) {
        _isExitActive = false; // Disable exit when entrance is active
      }
    });
  }

  void _toggleExit() {
    setState(() {
      _isExitActive = !_isExitActive;
      if (_isExitActive) {
        _isEntranceActive = false; // Disable entrance when exit is active
      }
    });
  }

  void _openQRScanner() async {
    // Check if a mode is active
    if (!_isEntranceActive && !_isExitActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona primero un modo: ENTRADA o SALIDA'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to QR scanner with context
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          title: _isEntranceActive ? 'Escanear - ENTRADA' : 'Escanear - SALIDA',
          isEntrance: _isEntranceActive,
          onCodeScanned: _handleScannedCode,
        ),
      ),
    );

    if (result != null) {
      _handleScannedCode(result);
    }
  }

  void _handleScannedCode(String code) {
    final mode = _isEntranceActive ? 'ENTRADA' : 'SALIDA';

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código QR escaneado para $mode: $code'),
        backgroundColor: _isEntranceActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            _showCodeDetails(code, mode);
          },
        ),
      ),
    );

    TrafficQRService().registerEntry(
      student: code,
      userId: tempUser!.employeeNumber,
      device: deviceData['name'],
      token: tempUser!.token,
    );
  }

  void _showCodeDetails(String code, String mode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Código Registrado - $mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: $code'),
            const SizedBox(height: 8),
            Text('Tipo: $mode'),
            const SizedBox(height: 8),
            Text('Hora: ${DateTime.now().toString().substring(0, 19)}'),
            const SizedBox(height: 8),
            Text('Campus: Usuario Campus'), // You'd get this from user context
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Color _getCurrentStatusColor() {
    if (_isEntranceActive) {
      return Theme.of(context).colorScheme.primary;
    } else if (_isExitActive) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _getCurrentStatusText() {
    if (_isEntranceActive) {
      return 'Modo ENTRADA activo';
    } else if (_isExitActive) {
      return 'Modo SALIDA activo';
    } else {
      return 'Sin modo activo';
    }
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Control de Vialidad',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Traffic Control Switches
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control de Flujo',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Entrance Control Switch
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleEntrance,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _isEntranceActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isEntranceActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withOpacity(
                                        0.3,
                                      ),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login,
                                  color: _isEntranceActive
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ENTRADA',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: _isEntranceActive
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Exit Control Switch
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleExit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _isExitActive
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isExitActive
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.outline.withOpacity(
                                        0.3,
                                      ),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: _isExitActive
                                      ? theme.colorScheme.onSecondary
                                      : theme.colorScheme.onSurface,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SALIDA',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: _isExitActive
                                        ? theme.colorScheme.onSecondary
                                        : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Status indicator
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getCurrentStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getCurrentStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getCurrentStatusText(),
                          style: textTheme.bodySmall?.copyWith(
                            color: _getCurrentStatusColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // QR Scanner Section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escáner de Vehículos',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Escanea el código QR del vehículo para registrar entrada o salida',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openQRScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Abrir Escáner QR'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Additional info section - Removed Expanded widget
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Instrucciones',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    '1. Selecciona el tipo de control: ENTRADA o SALIDA',
                  ),
                  _buildInstructionItem(
                    '2. Usa el escáner QR para registrar vehículos',
                  ),
                  _buildInstructionItem(
                    '3. Solo un modo puede estar activo a la vez',
                  ),
                  _buildInstructionItem(
                    '4. El estado se mostrará en tiempo real',
                  ),
                ],
              ),
            ),
          ),

          // Add some bottom padding for better scrolling
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
