import 'package:flutter/material.dart';
import '../Controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController();
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveLayout(context, constraints);
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final isTablet = constraints.maxWidth > 600;
    final isLandscape = constraints.maxWidth > constraints.maxHeight;

    if (isTablet) {
      return _buildTabletLayout(context);
    } else if (isLandscape) {
      return _buildLandscapeLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(context, size: 230),
          const SizedBox(height: 48),
          _buildWelcomeText(context),
          const SizedBox(height: 32),
          _buildLoginForm(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(context, size: 200),
              const SizedBox(height: 48),
              _buildWelcomeText(context),
              const SizedBox(height: 32),
              _buildLoginForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(context, size: 150, isWhite: true),
                const SizedBox(height: 24),
                Text(
                  'Vialidad OxSchool',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWelcomeText(context),
                const SizedBox(height: 32),
                _buildLoginForm(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(
    BuildContext context, {
    required double size,
    bool isWhite = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String imagePath;

    if (isWhite) {
      imagePath = 'assets/images/logoBlancoOx.png';
    } else {
      imagePath = isDark
          ? 'assets/images/logoBlancoOx.png'
          : 'assets/images/1_OS_color.png';
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.business,
              size: size * 0.6,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bienvenido',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return ListenableBuilder(
      listenable: _loginController,
      builder: (context, child) {
        return Form(
          key: _loginController.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserNumberField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              if (_loginController.errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],
              const SizedBox(height: 24),
              _buildLoginButton(),
              // const SizedBox(height: 16),
              // _buildForgotPasswordButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserNumberField() {
    return TextFormField(
      controller: _loginController.userNumberController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Número de empleado',
        hintText: 'Ingresa tu número de empleado',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: _loginController.validateUserNumber,
      onChanged: (_) => _loginController.clearError(),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _loginController.passwordController,
      obscureText: !_loginController.isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Ingresa tu contraseña',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _loginController.isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: _loginController.togglePasswordVisibility,
        ),
      ),
      validator: _loginController.validatePassword,
      onChanged: (_) => _loginController.clearError(),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _loginController.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _loginController.isLoading ? null : _handleLogin,
      child: _loginController.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Iniciar Sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _showForgotPasswordDialog,
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final success = await _loginController.login();

    if (success && mounted) {
      // Navigate to home screen or dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido ${_loginController.currentUser?.name}!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // TODO: Navigate to main app screen
      // Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: const Text(
          'Para recuperar tu contraseña, ponte en contacto con el administrador del sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
