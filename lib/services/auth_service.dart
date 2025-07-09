import 'package:flutter/material.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/app/app.router.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked_annotations.dart';

class AuthService
    with ListenableServiceMixin
    implements InitializableDependency {
  final _supabaseService = locator<SupabaseService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  // Authentication state variables
  final ReactiveValue<bool> _isAuthenticated = ReactiveValue<bool>(false);
  final ReactiveValue<bool> _isAuthenticating = ReactiveValue<bool>(false);
  final ReactiveValue<UserProfile?> _currentUser =
      ReactiveValue<UserProfile?>(null);

  AuthService() {
    listenToReactiveValues([
      _isAuthenticated,
      _isAuthenticating,
      _currentUser,
    ]);
  }

  // Public getters
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isAuthenticating => _isAuthenticating.value;
  UserProfile? get currentUser => _currentUser.value;

  @override
  Future<void> init() async {
    // Check if user is already authenticated on startup
    try {
      final user = await _supabaseService.getCurrentUser();
      if (user != null) {
        _isAuthenticated.value = true;
        _currentUser.value = user;
      }
    } catch (e) {
      // If there's an error, we'll assume the user is not authenticated
      _isAuthenticated.value = false;
      _currentUser.value = null;
    }

    // Set up auth state listener
    _supabaseService.onAuthStateChange((user) {
      _isAuthenticated.value = user != null;
      _currentUser.value = user;
    });
  }

  // Email/password sign up
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _isAuthenticating.value = true;

    try {
      final user = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      _isAuthenticated.value = user != null;
      _currentUser.value = user;
      _isAuthenticating.value = false;

      return user != null;
    } catch (e) {
      _isAuthenticating.value = false;
      rethrow;
    }
  }

  // Email/password sign in
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isAuthenticating.value = true;

    try {
      final user = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      _isAuthenticated.value = user != null;
      _currentUser.value = user;
      _isAuthenticating.value = false;

      return user != null;
    } catch (e) {
      _isAuthenticating.value = false;
      rethrow;
    }
  }

  // OAuth sign in (Google, Apple, etc.)
  Future<bool> signInWithOAuth(String provider) async {
    _isAuthenticating.value = true;

    try {
      final user = await _supabaseService.signInWithOAuth(provider);

      _isAuthenticated.value = user != null;
      _currentUser.value = user;
      _isAuthenticating.value = false;

      return user != null;
    } catch (e) {
      _isAuthenticating.value = false;
      rethrow;
    }
  }

  // Password reset request
  Future<bool> requestPasswordReset(String email) async {
    try {
      return await _supabaseService.requestPasswordReset(email);
    } catch (e) {
      rethrow;
    }
  }

  // Confirm password reset
  Future<bool> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      return await _supabaseService.confirmPasswordReset(
        token: token,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      _isAuthenticated.value = false;
      _currentUser.value = null;
      await _navigationService.clearStackAndShow(Routes.loginView);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Sign Out Error',
        description: 'There was a problem signing out. Please try again.',
      );
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updatedUser = await _supabaseService.updateUserProfile(
        name: name,
        avatarUrl: avatarUrl,
      );

      if (updatedUser != null) {
        _currentUser.value = updatedUser;
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return await _supabaseService.emailExists(email);
    } catch (e) {
      rethrow;
    }
  }
}