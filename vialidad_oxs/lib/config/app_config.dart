class AppConfig {
  // App mode configuration
  static const bool isDemoMode = true; // Set to false for production API calls
  static const bool isDebugMode = true; // Set to false in production builds

  // Demo credentials for testing
  static const String demoPassword = "1234";
  static const int minEmployeeNumber = 1;

  // API endpoints (configure these for your backend)
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String userProfileEndpoint = '/user/profile';

  // App information
  static const String appName = 'Vialidad OxSchool';
  static const String appVersion = '1.0.0';

  // UI Configuration
  static const int loginAnimationDuration = 2000; // milliseconds
  static const int splashScreenDuration = 3000; // milliseconds

  // Error messages
  static const String connectionErrorMessage =
      'Error de conexión. Verifica tu conexión a internet.';
  static const String invalidCredentialsMessage =
      'Credenciales inválidas. Verifica tu número de empleado y contraseña.';
  static const String serverErrorMessage =
      'Error del servidor. Intenta nuevamente más tarde.';
  static const String timeoutErrorMessage =
      'Tiempo de espera agotado. Intenta nuevamente.';

  // Token storage keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String lastLoginKey = 'last_login';

  // Validation rules
  static const int minPasswordLength = 4;
  static const int minEmployeeNumberLength = 3;
  static const int maxEmployeeNumberLength = 10;
}
