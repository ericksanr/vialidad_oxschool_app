import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Controller for managing QR scanner functionality with proper state management
/// Follows modern Flutter architecture patterns with separation of concerns
class QRScannerController extends ChangeNotifier {
  // Mobile Scanner Controller
  late MobileScannerController _controller;
  MobileScannerController get controller => _controller;

  // State Management
  bool _isScanning = false;
  bool _hasPermission = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String? _errorMessage;
  String? _lastScannedCode;

  // Getters for state
  bool get isScanning => _isScanning;
  bool get hasPermission => _hasPermission;
  bool get isFlashOn => _isFlashOn;
  bool get isFrontCamera => _isFrontCamera;
  String? get errorMessage => _errorMessage;
  String? get lastScannedCode => _lastScannedCode;

  // Callback for when QR code is detected
  Function(String)? onQRCodeDetected;

  QRScannerController({this.onQRCodeDetected}) {
    _initializeController();
  }

  /// Initialize the mobile scanner controller with configuration
  void _initializeController() {
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
      autoStart: false,
    );
  }

  /// Initialize scanner - check permissions and start camera
  Future<void> initialize() async {
    try {
      _clearError();
      await _checkCameraPermission();

      if (_hasPermission) {
        await _controller.start();
        _isScanning = true;
        notifyListeners();
      }
    } catch (e) {
      _setError('Error inicializando escáner: ${e.toString()}');
    }
  }

  /// Check and request camera permissions
  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;

      if (status.isDenied) {
        final result = await Permission.camera.request();
        _hasPermission = result.isGranted;
      } else if (status.isGranted) {
        _hasPermission = true;
      } else if (status.isPermanentlyDenied) {
        _hasPermission = false;
        _setError(
          'Permisos de cámara denegados permanentemente. Ve a Configuración para habilitarlos.',
        );
      }

      notifyListeners();
    } catch (e) {
      _setError('Error verificando permisos: ${e.toString()}');
    }
  }

  /// Handle QR code detection
  void onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _lastScannedCode = barcode.rawValue!;
        _pauseScanning();

        // Call the callback if provided
        onQRCodeDetected?.call(_lastScannedCode!);
        break;
      }
    }
  }

  /// Toggle flashlight
  Future<void> toggleFlash() async {
    try {
      _isFlashOn = !_isFlashOn;
      await _controller.toggleTorch();
      notifyListeners();
    } catch (e) {
      _setError('Error toggling flash: ${e.toString()}');
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    try {
      _isFrontCamera = !_isFrontCamera;
      await _controller.switchCamera();
      notifyListeners();
    } catch (e) {
      _setError('Error switching camera: ${e.toString()}');
    }
  }

  /// Pause scanning (useful after detecting a code)
  void _pauseScanning() {
    _isScanning = false;
    notifyListeners();
  }

  /// Resume scanning
  Future<void> resumeScanning() async {
    try {
      _clearError();
      _lastScannedCode = null;

      if (!_controller.value.isRunning) {
        await _controller.start();
      }

      _isScanning = true;
      notifyListeners();
    } catch (e) {
      _setError('Error resuming scanner: ${e.toString()}');
    }
  }

  /// Stop the scanner
  Future<void> stopScanning() async {
    try {
      _isScanning = false;
      await _controller.stop();
      notifyListeners();
    } catch (e) {
      _setError('Error stopping scanner: ${e.toString()}');
    }
  }

  /// Restart the scanner completely
  Future<void> restartScanner() async {
    try {
      await stopScanning();
      await Future.delayed(const Duration(milliseconds: 100));
      await initialize();
    } catch (e) {
      _setError('Error restarting scanner: ${e.toString()}');
    }
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Open app settings for permission management
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Validate if scanned code is a valid format for traffic control
  bool isValidTrafficCode(String code) {
    // Implement your business logic for validating QR codes
    // This is just an example - adjust according to your requirements
    if (code.isEmpty) return false;

    // Example: Check if code follows a specific pattern
    // You might want to validate against a specific format or API
    return code.length >= 6 && code.isNotEmpty;
  }

  /// Process scanned QR code for traffic control
  Map<String, dynamic> processTrafficQRCode(String code) {
    try {
      // This is where you'd implement your business logic
      // for processing QR codes in the context of traffic control

      return {
        'isValid': isValidTrafficCode(code),
        'code': code,
        'timestamp': DateTime.now().toIso8601String(),
        'type': _determineQRCodeType(code),
      };
    } catch (e) {
      return {
        'isValid': false,
        'error': 'Error processing QR code: ${e.toString()}',
        'code': code,
      };
    }
  }

  /// Determine the type of QR code based on its content
  String _determineQRCodeType(String code) {
    // Implement logic to determine QR code type
    // This could be based on prefixes, patterns, or API validation

    if (code.startsWith('VEH_')) return 'vehicle';
    if (code.startsWith('PER_')) return 'person';
    if (code.startsWith('VIS_')) return 'visitor';

    return 'unknown';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
