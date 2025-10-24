import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Services/login_service.dart';

class LoginController extends ChangeNotifier {
  final LoginService _loginService = LoginService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController userNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Validate user number
  String? validateUserNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número de empleado es requerido';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Debe contener solo números';
    }
    if (value.length < 3) {
      return 'Debe tener al menos 3 dígitos';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida';
    }
    if (value.length < 4) {
      return 'Debe tener al menos 4 caracteres';
    }
    return null;
  }

  // Login method
  Future<bool> login() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _loginService.login(
        int.parse(userNumberController.text.trim()),
        passwordController.text.trim(),
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Credenciales inválidas';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Intente nuevamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    userNumberController.clear();
    passwordController.clear();
    _errorMessage = null;
    _isPasswordVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    userNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
