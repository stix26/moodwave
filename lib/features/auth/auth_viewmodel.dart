import 'package:flutter/material.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/app/app.router.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

enum AuthMode { login, register, passwordReset }

class AuthViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form state
  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  String? _validationMessage;
  String? get validationMessage => _validationMessage;

  AuthMode _authMode = AuthMode.login;
  AuthMode get authMode => _authMode;

  bool _isResetPasswordMode = false;
  bool get isResetPasswordMode => _isResetPasswordMode;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void setAuthMode(AuthMode mode) {
    _authMode = mode;
    _clearValidationMessage();
  }

  void setResetPasswordMode(bool isReset) {
    _isResetPasswordMode = isReset;
    _clearValidationMessage();
  }

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void _clearValidationMessage() {
    _validationMessage = null;
    notifyListeners();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 8;
  }

  // Login with email and password
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _validationMessage = 'Email and password are required';
      notifyListeners();
      return;
    }

    if (!_validateEmail(emailController.text)) {
      _validationMessage = 'Please enter a valid email address';
      notifyListeners();
      return;
    }

    _clearValidationMessage();
    setBusy(true);

    try {
      final success = await _authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        await _navigationService.clearStackAndShow(Routes.homeView);
      } else {
        _validationMessage = 'Invalid email or password';
        notifyListeners();
      }
    } catch (e) {
      _validationMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // Register with email and password
  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _validationMessage = 'All fields are required';
      notifyListeners();
      return;
    }

    if (!_validateEmail(emailController.text)) {
      _validationMessage = 'Please enter a valid email address';
      notifyListeners();
      return;
    }

    if (!_validatePassword(passwordController.text)) {
      _validationMessage = 'Password must be at least 8 characters long';
      notifyListeners();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _validationMessage = 'Passwords do not match';
      notifyListeners();
      return;
    }

    _clearValidationMessage();
    setBusy(true);

    try {
      // Check if email already exists
      final emailExists =
          await _authService.emailExists(emailController.text.trim());
      if (emailExists) {
        _validationMessage = 'This email is already registered';
        notifyListeners();
        setBusy(false);
        return;
      }

      final success = await _authService.signUpWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        await _dialogService.showDialog(
          title: 'Registration Successful',
          description: 'Your account has been created.',
        );
        await _navigationService.clearStackAndShow(Routes.homeView);
      } else {
        _validationMessage = 'Failed to create account';
        notifyListeners();
      }
    } catch (e) {
      _validationMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // OAuth sign in
  Future<void> signInWithOAuth(String provider) async {
    _clearValidationMessage();
    setBusy(true);

    try {
      final success = await _authService.signInWithOAuth(provider);

      if (success) {
        await _navigationService.clearStackAndShow(Routes.homeView);
      } else {
        _validationMessage = 'Failed to sign in with $provider';
        notifyListeners();
      }
    } catch (e) {
      _validationMessage = 'Sign in failed: ${e.toString()}';
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // Request password reset
  Future<void> requestPasswordReset() async {
    if (emailController.text.isEmpty) {
      _validationMessage = 'Email is required';
      notifyListeners();
      return;
    }

    if (!_validateEmail(emailController.text)) {
      _validationMessage = 'Please enter a valid email address';
      notifyListeners();
      return;
    }

    _clearValidationMessage();
    setBusy(true);

    try {
      final success = await _authService.requestPasswordReset(
        emailController.text.trim(),
      );

      if (success) {
        await _dialogService.showDialog(
          title: 'Reset Link Sent',
          description:
              'Check your email for instructions to reset your password.',
        );
        await _navigationService.navigateToLoginView();
      } else {
        _validationMessage = 'Failed to send reset link';
        notifyListeners();
      }
    } catch (e) {
      _validationMessage = 'Request failed: ${e.toString()}';
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // Reset password with token
  Future<void> resetPassword(String token) async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _validationMessage = 'Please enter your new password';
      notifyListeners();
      return;
    }

    if (!_validatePassword(passwordController.text)) {
      _validationMessage = 'Password must be at least 8 characters long';
      notifyListeners();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _validationMessage = 'Passwords do not match';
      notifyListeners();
      return;
    }

    _clearValidationMessage();
    setBusy(true);

    try {
      final success = await _authService.confirmPasswordReset(
        token: token,
        newPassword: passwordController.text,
      );

      if (success) {
        await _dialogService.showDialog(
          title: 'Password Reset',
          description: 'Your password has been successfully reset.',
        );
        await _navigationService.navigateToLoginView();
      } else {
        _validationMessage = 'Failed to reset password';
        notifyListeners();
      }
    } catch (e) {
      _validationMessage = 'Reset failed: ${e.toString()}';
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // Navigation methods
  void navigateToLogin() {
    _navigationService.navigateToLoginView();
  }

  void navigateToRegister() {
    _navigationService.navigateToRegisterView();
  }

  void navigateToPasswordReset() {
    _navigationService.navigateToPasswordResetView();
  }
}
