import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiConfig {
  // Environment configuration
  static const bool isProduction = false; // Set to true for production
  static const bool enableLogging =
      true; // Set to false in production for better performance

  // Base URLs for different environments
  static String productionBaseUrl = "${dotenv.env['BACKEND_URL']}";
  static String developmentBaseUrl = "${dotenv.env['BACKEND_URL']}";
  static String localBaseUrl = "${dotenv.env['BACKEND_URL']}";

  static String get baseUrl {
    if (isProduction) {
      return productionBaseUrl;
    } else {
      return developmentBaseUrl; // or localBaseUrl for local development
    }
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  // Timeout configurations
  static const int _connectTimeout = 15000; // 15 seconds
  static const int _receiveTimeout = 15000; // 15 seconds
  static const int _sendTimeout = 15000; // 15 seconds

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: _connectTimeout),
        receiveTimeout: const Duration(milliseconds: _receiveTimeout),
        sendTimeout: const Duration(milliseconds: _sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _addInterceptors();
  }

  void _addInterceptors() {
    // Pretty logger for debugging (only in debug mode and if enabled)
    if (ApiConfig.enableLogging && !ApiConfig.isProduction) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Custom interceptor for authentication and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authentication token if available
          // final token = getStoredToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Handle successful responses
          handler.next(response);
        },
        onError: (error, handler) {
          // Handle errors globally
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiException(
          'Timeout de conexión. Verifica tu conexión a internet.',
        );
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            throw ApiException('Solicitud inválida.');
          case 401:
            throw ApiException('No autorizado. Verifica tus credenciales.');
          case 403:
            throw ApiException('Acceso prohibido.');
          case 404:
            throw ApiException('Recurso no encontrado.');
          case 500:
            throw ApiException('Error interno del servidor.');
          default:
            throw ApiException(
              'Error del servidor: ${error.response?.statusCode}',
            );
        }
      case DioExceptionType.cancel:
        throw ApiException('Solicitud cancelada.');
      case DioExceptionType.connectionError:
        throw ApiException(
          'Error de conexión. Verifica tu conexión a internet.',
        );
      default:
        throw ApiException('Error inesperado: ${error.message}');
    }
  }

  // Method to update base URL if needed
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Method to add authorization header
  void setAuthorizationHeader(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Method to remove authorization header
  void removeAuthorizationHeader() {
    _dio.options.headers.remove('Authorization');
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
