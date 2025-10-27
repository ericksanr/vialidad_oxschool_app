import 'package:dio/dio.dart';
import 'package:vialidad_oxs/Controller/login_controller.dart';
import 'package:vialidad_oxs/Services/api_service.dart';
import '../config/app_config.dart';

/// Service for handling traffic control QR code operations
/// This demonstrates how to integrate QR scanner results with your backend
class TrafficQRService {
  final Dio _dio;

  TrafficQRService() : _dio = Dio() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = AppConfig.requestTimeout;
    _dio.options.receiveTimeout = AppConfig.requestTimeout;
  }

  /// Register a vehicle entry using QR code
  Future<Map<String, dynamic>> registerEntry({
    required String student,
    required int userId,
    required String device,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.productionBaseUrl}/school-drop-off/create/',
        data: {'student': student, 'user': userId, 'device': device},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('Error registrando entrada');
      }

      return {
        'success': true,
        'message': 'Entrada registrada exitosamente',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error registrando entrada: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Register a vehicle exit using QR code
  Future<Map<String, dynamic>> registerExit({
    required String qrCode,
    required String campus,
    required int employeeNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/traffic/exit',
        data: {
          'qr_code': qrCode,
          'campus': campus,
          'employee_number': employeeNumber,
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'exit',
        },
      );

      return {
        'success': true,
        'message': 'Salida registrada exitosamente',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error registrando salida: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Validate a QR code against the backend
  Future<Map<String, dynamic>> validateQRCode(String qrCode) async {
    try {
      final response = await _dio.get(
        '/traffic/validate',
        queryParameters: {'qr_code': qrCode},
      );

      return {
        'success': true,
        'isValid': response.data['valid'] ?? false,
        'vehicleInfo': response.data['vehicle_info'],
        'message': response.data['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'isValid': false,
        'message': 'Error validando código QR: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Get traffic history for a specific campus
  Future<Map<String, dynamic>> getTrafficHistory({
    required String campus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/traffic/history',
        queryParameters: {
          'campus': campus,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
        },
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Historial obtenido exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error obteniendo historial: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Get real-time traffic stats for dashboard
  Future<Map<String, dynamic>> getTrafficStats(String campus) async {
    try {
      final response = await _dio.get(
        '/traffic/stats',
        queryParameters: {'campus': campus},
      );

      return {
        'success': true,
        'stats': response.data,
        'message': 'Estadísticas obtenidas exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error obteniendo estadísticas: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }
}
