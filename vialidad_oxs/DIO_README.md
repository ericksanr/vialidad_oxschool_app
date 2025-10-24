# Dio Implementation for REST API

This project now uses **Dio** for making HTTP requests, providing better error handling, interceptors, and a more robust networking layer.

## Features Implemented

### 🔧 Core Components

1. **ApiService** (`lib/Services/api_service.dart`)
   - Singleton pattern for consistent API configuration
   - Configurable base URLs for different environments
   - Request/Response interceptors
   - Global error handling
   - Authentication token management

2. **LoginService** (`lib/Services/login_service.dart`)
   - Demo mode and Production mode support
   - Dio-based authentication
   - Token management
   - Comprehensive error handling

3. **AppConfig** (`lib/config/app_config.dart`)
   - Centralized configuration
   - Easy switching between demo and production modes
   - Configurable timeouts, endpoints, and validation rules

### 🚀 Getting Started

#### Demo Mode (Default)
The app currently runs in demo mode. To test:
- Use any employee number (e.g., `12345`)
- Use password: `1234`

#### Production Mode
To enable production API calls:

1. Update `lib/config/app_config.dart`:
```dart
static const bool isDemoMode = false; // Set to false
```

2. Update your API endpoints in `lib/Services/api_service.dart`:
```dart
static const String productionBaseUrl = 'https://your-production-api.com/api';
```

### 📡 API Configuration

#### Environment Setup
Configure different environments in `ApiService`:

```dart
// Development
static const String developmentBaseUrl = 'https://your-dev-api.com/api';

// Production
static const String productionBaseUrl = 'https://your-production-api.com/api';

// Local development
static const String localBaseUrl = 'http://localhost:3000/api';
```

#### Expected API Response Format
Your backend should return responses in this format:

```json
{
  "success": true,
  "token": "your-jwt-token-here",
  "user": {
    "name": "John Doe",
    "employeeNumber": 12345,
    "campus": "Main Campus",
    "isDeactivated": 0,
    "isAdmin": 0
  }
}
```

### 🔒 Authentication Flow

1. **Login**: POST to `/auth/login`
   ```json
   {
     "employeeNumber": 12345,
     "password": "userpassword"
   }
   ```

2. **Token Storage**: JWT token is automatically stored and added to subsequent requests

3. **Auto-refresh**: Implement token refresh logic in your backend

4. **Logout**: POST to `/auth/logout` (clears local tokens)

### 🛠️ Error Handling

The implementation includes comprehensive error handling:

- **Connection timeouts**: 15-second timeout for all requests
- **Network errors**: Automatic detection and user-friendly messages
- **HTTP status codes**: Proper handling of 400, 401, 403, 404, 500 errors
- **Custom exceptions**: `ApiException` for consistent error messaging

### 📦 Dependencies Added

```yaml
dependencies:
  dio: ^5.4.0                 # HTTP client
  pretty_dio_logger: ^1.3.1   # Request/response logging
```

### 🔧 Interceptors

1. **Pretty Logger**: Logs all requests and responses (debug mode only)
2. **Authentication**: Automatically adds Bearer tokens to requests
3. **Error Handler**: Converts HTTP errors to user-friendly messages

### 🔄 Switching Between Modes

#### Demo Mode (Testing)
```dart
// lib/config/app_config.dart
static const bool isDemoMode = true;
```

#### Production Mode (Live API)
```dart
// lib/config/app_config.dart
static const bool isDemoMode = false;
```

### 📋 Integration Checklist

When implementing with your real backend:

- [ ] Update `productionBaseUrl` in `ApiService`
- [ ] Set `isDemoMode = false` in `AppConfig`
- [ ] Implement secure token storage (consider `flutter_secure_storage`)
- [ ] Update API endpoints in `AppConfig`
- [ ] Test authentication flow
- [ ] Configure proper error messages
- [ ] Set `enableLogging = false` for production builds

### 🔐 Security Considerations

1. **Token Storage**: Consider using `flutter_secure_storage` for production
2. **HTTPS Only**: Ensure all API calls use HTTPS in production
3. **Token Expiry**: Implement proper token refresh logic
4. **Certificate Pinning**: Consider implementing for enhanced security

### 🧪 Testing

The app includes mock authentication for testing:
- Employee Number: Any number ≥ 1
- Password: `1234`
- Response: Demo user with employee number

### 📝 Next Steps

1. Replace mock endpoints with your actual API URLs
2. Implement secure token storage
3. Add proper error handling for your specific use cases
4. Configure certificate pinning if needed
5. Add unit tests for the API service

## Support

For questions about the Dio implementation, refer to:
- [Dio Documentation](https://pub.dev/packages/dio)
- [Pretty Dio Logger](https://pub.dev/packages/pretty_dio_logger)