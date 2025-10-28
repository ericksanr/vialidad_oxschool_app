import 'package:flutter/material.dart';
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

  // List to store scanned items history
  final List<Map<String, dynamic>> _scannedItems = [];

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
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          title: _isEntranceActive ? 'Escanear - ENTRADA' : 'Escanear - SALIDA',
          isEntrance: _isEntranceActive,
          onCodeScanned: _handleScannedCode,
        ),
      ),
    );
  }

  void _handleScannedCode(String code) async {
    final mode = _isEntranceActive ? 'ENTRADA' : 'SALIDA';
    final timestamp = DateTime.now();

    // Show initial scanning message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Procesando código QR para $mode: $code'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    if (mode == 'ENTRADA') {
      var response = await TrafficQRService().registerEntry(
        student: code,
        userId: tempUser!.employeeNumber,
        device: deviceData['name'],
        token: tempUser!.token,
      );

      // Create scanned item record
      final scannedItem = {
        'code': code,
        'mode': mode,
        'timestamp': timestamp,
        'response': response,
        'success': response['success'] == true,
        'id': response['id'],
      };

      // Add to list and keep only last 10 items
      if (mounted) {
        setState(() {
          _scannedItems.insert(0, scannedItem); // Insert at beginning
          if (_scannedItems.length > 10) {
            _scannedItems.removeLast(); // Remove oldest item
          }
        });

        // Show response message
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Registro exitoso'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Handle different error types with appropriate colors and durations
          Color backgroundColor = Colors.red;
          Duration duration = const Duration(seconds: 3);

          // Special handling for 409 conflict (record already exists)
          if (response['statusCode'] == 409 ||
              response['error'] == 'RECORD_ALREADY_EXISTS') {
            backgroundColor = Colors.orange;
            duration = const Duration(
              seconds: 5,
            ); // Show longer for important info
          } else if (response['statusCode'] == 401) {
            backgroundColor = Colors.purple;
            duration = const Duration(seconds: 4);
          } else if (response['statusCode'] == 400) {
            backgroundColor = Colors.amber;
            duration = const Duration(seconds: 4);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error en el registro'),
              backgroundColor: backgroundColor,
              duration: duration,
              action: response['statusCode'] == 409
                  ? SnackBarAction(
                      label: 'Entendido',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    )
                  : null,
            ),
          );
        }
      }
    } else if (mode == 'SALIDA') {
      var response = await TrafficQRService().registerExit(
        studentId: code,
        employeeNumber: tempUser!.employeeNumber,
        device: deviceData['name'],
        token: tempUser!.token,
      );

      // Create scanned item record
      final scannedItem = {
        'code': code,
        'mode': mode,
        'timestamp': timestamp,
        'response': response,
        'success': response['success'] == true,
        'id': response['id'],
      };

      // Add to list and keep only last 10 items
      if (mounted) {
        setState(() {
          _scannedItems.insert(0, scannedItem); // Insert at beginning
          if (_scannedItems.length > 10) {
            _scannedItems.removeLast(); // Remove oldest item
          }
        });

        // Show response message
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Registro exitoso'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Handle different error types with appropriate colors and durations
          Color backgroundColor = Colors.red;
          Duration duration = const Duration(seconds: 3);

          // Special handling for 409 conflict (record already exists)
          if (response['statusCode'] == 409 ||
              response['error'] == 'RECORD_ALREADY_EXISTS') {
            backgroundColor = Colors.orange;
            duration = const Duration(
              seconds: 5,
            ); // Show longer for important info
          } else if (response['statusCode'] == 401) {
            backgroundColor = Colors.purple;
            duration = const Duration(seconds: 4);
          } else if (response['statusCode'] == 400) {
            backgroundColor = Colors.amber;
            duration = const Duration(seconds: 4);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error en el registro'),
              backgroundColor: backgroundColor,
              duration: duration,
              action: response['statusCode'] == 409
                  ? SnackBarAction(
                      label: 'Entendido',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    )
                  : null,
            ),
          );
        }
      }
    }
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

  Widget _buildScannedItemsList() {
    if (_scannedItems.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay elementos escaneados',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Los últimos 10 códigos QR escaneados aparecerán aquí',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Últimos Escaneos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_scannedItems.length}/10',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300, // Fixed height for scrollable area
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _scannedItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _scannedItems[index];
                final isSuccess = item['success'] as bool;
                final response = item['response'] as Map<String, dynamic>;

                return _buildScannedItem(
                  code: item['code'] as String,
                  mode: item['mode'] as String,
                  timestamp: item['timestamp'] as DateTime,
                  isSuccess: isSuccess,
                  message:
                      response['message'] ??
                      (isSuccess ? 'Registro exitoso' : 'Error en el registro'),
                  response: response,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildScannedItem({
    required String code,
    required String mode,
    required DateTime timestamp,
    required bool isSuccess,
    required String message,
    required Map<String, dynamic> response,
  }) {
    final theme = Theme.of(context);

    // Determine status color based on success and error type
    Color statusColor;
    IconData statusIcon;

    if (isSuccess) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      // Handle different error types with different colors
      if (response['statusCode'] == 409 ||
          response['error'] == 'RECORD_ALREADY_EXISTS') {
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
      } else if (response['statusCode'] == 401) {
        statusColor = Colors.purple;
        statusIcon = Icons.lock;
      } else if (response['statusCode'] == 400) {
        statusColor = Colors.amber;
        statusIcon = Icons.info;
      } else {
        statusColor = Colors.red;
        statusIcon = Icons.error;
      }
    }

    final modeColor = mode == 'ENTRADA'
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return InkWell(
      onTap: () => _showScannedItemDetails(code, mode, timestamp, response),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: modeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: modeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Código: $code',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Status icon
            Icon(statusIcon, color: statusColor, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _getErrorTypeDescription(Map<String, dynamic> response) {
    if (response['statusCode'] == 409 ||
        response['error'] == 'RECORD_ALREADY_EXISTS') {
      return 'Registro Duplicado';
    } else if (response['statusCode'] == 401) {
      return 'Sin Autorización';
    } else if (response['statusCode'] == 400) {
      return 'Datos Inválidos';
    } else if (response['statusCode'] == 500) {
      return 'Error del Servidor';
    } else {
      return 'Error';
    }
  }

  void _showScannedItemDetails(
    String code,
    String mode,
    DateTime timestamp,
    Map<String, dynamic> response,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Escaneo - $mode'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Código QR:', code),
              _buildDetailRow('Tipo:', mode),
              _buildDetailRow(
                'Fecha:',
                '${timestamp.day}/${timestamp.month}/${timestamp.year}',
              ),
              _buildDetailRow(
                'Hora:',
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
              ),
              _buildDetailRow(
                'Estado:',
                response['success'] == true
                    ? 'Exitoso'
                    : _getErrorTypeDescription(response),
              ),
              _buildDetailRow('Mensaje:', response['message'] ?? 'Sin mensaje'),
              // Show additional info for conflict errors
              if (response['statusCode'] == 409 ||
                  response['error'] == 'RECORD_ALREADY_EXISTS') ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Registro Duplicado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Este código QR ya fue escaneado anteriormente. Para poder escanearlo nuevamente, es necesario que el administrador actualice el estado del registro en el sistema.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
              if (response['data'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Respuesta del servidor:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    response.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
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

          // Scanned Items History Section - Replaces instructions
          _buildScannedItemsList(),

          // Add some bottom padding for better scrolling
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
