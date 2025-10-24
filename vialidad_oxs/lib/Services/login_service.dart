import 'package:dio/dio.dart';
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
      if (AppConfig.isDemoMode) {
        // Demo mode - use mock authentication
        return await _mockLogin(employeeNumber, password);
      } else {
        // Production mode - use real API
        return await _authenticateWithAPI(employeeNumber, password);
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Demo authentication method
  Future<User?> _mockLogin(int employeeNumber, String password) async {
    // Simulate network delay
    await Future.delayed(
      Duration(milliseconds: AppConfig.loginAnimationDuration),
    );

    if (_mockAuthenticate(employeeNumber, password)) {
      return User(
        name: 'Usuario Demo',
        employeeNumber: employeeNumber,
        password: '', // Don't store password in response
        campus: 'Campus Principal',
        isDeactivated: 0,
        isAdmin: 0,
      );
    }
    return null;
  }

  // Real API authentication method using Dio
  Future<User?> _authenticateWithAPI(
    int employeeNumber,
    String password,
  ) async {
    try {
      final response = await _apiService.dio.post(
        AppConfig.loginEndpoint,
        data: {'employeeNumber': employeeNumber, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle different response structures
        if (data['success'] == true && data['user'] != null) {
          // Store authentication token if provided
          if (data['token'] != null) {
            _apiService.setAuthorizationHeader(data['token']);
            // You might want to store this token in secure storage
            // await _storeAuthToken(data['token']);
          }

          return User.fromJson(data['user']);
        } else {
          return null; // Invalid credentials
        }
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null; // Invalid credentials
      }
      rethrow; // Let the calling method handle other errors
    }
  }

  // Mock authentication method for development/demo
  bool _mockAuthenticate(int employeeNumber, String password) {
    return password == AppConfig.demoPassword &&
        employeeNumber >= AppConfig.minEmployeeNumber;
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
