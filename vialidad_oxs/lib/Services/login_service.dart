import 'package:dio/dio.dart';
import 'package:vialidad_oxs/Controller/login_controller.dart';
import '../Models/User.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class LoginService {
  final ApiService _apiService = ApiService();

  // Initialize the API service
  LoginService() {
    _apiService.initialize();
  }

  Future<User?> login(int employeeNumber, String password) async {
    try {
      // Production mode - use real API
      return await _authenticateWithAPI(employeeNumber, password);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Real API authentication method using Dio
  Future<User?> _authenticateWithAPI(
    int employeeNumber,
    String password,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '${ApiConfig.productionBaseUrl}/auth/drop-off/login',
        data: {'employeeNumber': employeeNumber, 'password': password},
        options: Options(
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;

        return User.fromJson(data);
      } else {
        throw ApiException(
          response.data['message'] ?? 'Error de autenticación',
        );
      }
    } on DioException catch (e) {
      return null; // This line will never be reached
    }
  }

  // Method to logout and clear authentication
  Future<void> logout() async {
    try {
      if (!AppConfig.isDemoMode) {
        // Call logout API endpoint if available in production mode
        await _apiService.dio.post(AppConfig.logoutEndpoint);
      }
    } catch (e) {
      // Handle logout errors if needed
      if (AppConfig.isDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      // Always clear local authentication data
      _apiService.removeAuthorizationHeader();
      // Clear stored token
      // await _clearAuthToken();
    }
  }

  // Method to refresh authentication token
  Future<bool> refreshToken() async {
    if (AppConfig.isDemoMode) {
      return true; // Always successful in demo mode
    }

    try {
      final response = await _apiService.dio.post(
        AppConfig.refreshTokenEndpoint,
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        _apiService.setAuthorizationHeader(response.data['token']);
        // Store new token
        // await _storeAuthToken(response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Method to check if user is authenticated
  bool isAuthenticated() {
    // Check if authorization header is set
    return _apiService.dio.options.headers.containsKey('Authorization');
  }

  // Methods for token storage (implement with secure storage)
  /*
  Future<void> _storeAuthToken(String token) async {
    // Implement with flutter_secure_storage or similar
    // final storage = FlutterSecureStorage();
    // await storage.write(key: 'auth_token', value: token);
  }

  Future<String?> _getStoredToken() async {
    // Implement with flutter_secure_storage or similar
    // final storage = FlutterSecureStorage();
    // return await storage.read(key: 'auth_token');
  }

  Future<void> _clearAuthToken() async {
    // Implement with flutter_secure_storage or similar
    // final storage = FlutterSecureStorage();
    // await storage.delete(key: 'auth_token');
  }
  */
}
