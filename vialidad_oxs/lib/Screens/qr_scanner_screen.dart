import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../Controller/qr_scanner_controller.dart';

class QRScannerScreen extends StatefulWidget {
  final String title;
  final Function(String)? onCodeScanned;
  final bool isEntrance; // For traffic control context

  const QRScannerScreen({
    super.key,
    this.title = 'Escanear Código QR',
    this.onCodeScanned,
    this.isEntrance = true,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  late QRScannerController _scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize scanner controller with callback
    _scannerController = QRScannerController(
      onQRCodeDetected: _handleQRCodeDetected,
    );

    // Initialize scanning animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start scanner
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    await _scannerController.initialize();
    if (_scannerController.isScanning) {
      _animationController.repeat(reverse: true);
    }
  }

  void _handleQRCodeDetected(String code) {
    // Haptic feedback
    HapticFeedback.vibrate();

    // Stop animation
    _animationController.stop();

    // Process the QR code
    final result = _scannerController.processTrafficQRCode(code);

    if (result['isValid']) {
      _showSuccessDialog(code, result);
    } else {
      _showErrorDialog(code, result['error'] ?? 'Código QR inválido');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Camera view
          _buildCameraView(),

          // Overlay with scanning area
          _buildScanningOverlay(colorScheme),

          // Control buttons
          _buildControlButtons(colorScheme),

          // Status information
          _buildStatusInfo(colorScheme),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return ListenableBuilder(
      listenable: _scannerController,
      builder: (context, child) {
        if (!_scannerController.hasPermission) {
          return _buildPermissionView();
        }

        if (_scannerController.errorMessage != null) {
          return _buildErrorView();
        }

        return MobileScanner(
          controller: _scannerController.controller,
          onDetect: _scannerController.onDetect,
        );
      },
    );
  }

  Widget _buildScanningOverlay(ColorScheme colorScheme) {
    return CustomPaint(
      painter: QRScannerOverlayPainter(
        animation: _animation,
        isEntrance: widget.isEntrance,
        primaryColor: colorScheme.primary,
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildControlButtons(ColorScheme colorScheme) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: ListenableBuilder(
        listenable: _scannerController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash toggle
              _buildControlButton(
                icon: _scannerController.isFlashOn
                    ? Icons.flash_on
                    : Icons.flash_off,
                label: 'Flash',
                onTap: _scannerController.toggleFlash,
                isActive: _scannerController.isFlashOn,
                colorScheme: colorScheme,
              ),

              // Camera switch
              _buildControlButton(
                icon: Icons.switch_camera,
                label: 'Cambiar',
                onTap: _scannerController.switchCamera,
                colorScheme: colorScheme,
              ),

              // Manual input
              _buildControlButton(
                icon: Icons.keyboard,
                label: 'Manual',
                onTap: _showManualInputDialog,
                colorScheme: colorScheme,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    bool isActive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isActive ? colorScheme.primary : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(ColorScheme colorScheme) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              widget.isEntrance ? Icons.login : Icons.logout,
              color: widget.isEntrance ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              widget.isEntrance ? 'ENTRADA' : 'SALIDA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coloca el código QR dentro del área de escaneo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 24),
          const Text(
            'Permisos de Cámara Requeridos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Esta aplicación necesita acceso a la cámara para escanear códigos QR',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _scannerController.initialize();
            },
            child: const Text('Solicitar Permisos'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _scannerController.openAppSettings,
            child: const Text(
              'Abrir Configuración',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          const Text(
            'Error en el Escáner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _scannerController.errorMessage ?? 'Error desconocido',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _scannerController.restartScanner,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String code, Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Código Escaneado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: $code'),
            const SizedBox(height: 8),
            Text('Tipo: ${result['type'] ?? 'Desconocido'}'),
            const SizedBox(height: 8),
            Text('Hora: ${DateTime.now().toString().substring(0, 19)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _scannerController.resumeScanning();
              _animationController.repeat(reverse: true);
            },
            child: const Text('Escanear Otro'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCodeScanned?.call(code);
              Navigator.of(context).pop(code);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String code, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Código Inválido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: $code'),
            const SizedBox(height: 8),
            Text('Error: $error'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _scannerController.resumeScanning();
              _animationController.repeat(reverse: true);
            },
            child: const Text('Reintentar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingreso Manual'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Código QR',
            hintText: 'Ingresa el código manualmente',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.of(context).pop();
                _handleQRCodeDetected(controller.text);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }
}

/// Custom painter for the QR scanner overlay
class QRScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isEntrance;
  final Color primaryColor;

  QRScannerOverlayPainter({
    required this.animation,
    required this.isEntrance,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;
    final scanAreaRect = Rect.fromLTWH(
      scanAreaLeft,
      scanAreaTop,
      scanAreaSize,
      scanAreaSize,
    );

    // Draw dark overlay with transparent scanning area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(16)),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner decorations
    _drawCorners(canvas, scanAreaRect);

    // Draw scanning line with animation
    _drawScanningLine(canvas, scanAreaRect);
  }

  void _drawCorners(Canvas canvas, Rect scanArea) {
    final cornerPaint = Paint()
      ..color = isEntrance ? Colors.green : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 24.0;

    // Top-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + cornerLength),
      Offset(scanArea.left, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + cornerLength, scanArea.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.top),
      Offset(scanArea.right, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - cornerLength),
      Offset(scanArea.left, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + cornerLength, scanArea.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom - cornerLength),
      cornerPaint,
    );
  }

  void _drawScanningLine(Canvas canvas, Rect scanArea) {
    final linePaint = Paint()
      ..color = (isEntrance ? Colors.green : Colors.red).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final lineY = scanArea.top + (scanArea.height * animation.value);

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        isEntrance ? Colors.green : Colors.red,
        Colors.transparent,
      ],
    );

    final gradientRect = Rect.fromLTWH(
      scanArea.left,
      lineY - 1,
      scanArea.width,
      2,
    );

    final shader = gradient.createShader(gradientRect);
    linePaint.shader = shader;

    canvas.drawRect(gradientRect, linePaint);
  }

  @override
  bool shouldRepaint(covariant QRScannerOverlayPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
}
