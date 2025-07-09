import 'package:flutter/material.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/app/app.router.dart';
import 'package:my_app/features/auth/auth_viewmodel.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// A wrapper widget for handling OAuth authentication callbacks.
/// This is typically used as a callback URL destination for OAuth providers.
class OAuthWrapper extends StackedView<AuthViewModel> {
  final String? provider;
  final String? token;
  final String? error;

  const OAuthWrapper({
    Key? key,
    this.provider,
    this.token,
    this.error,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AuthViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kcPrimaryColor,
              kcSecondaryColor,
              kcSecondaryColor.withBlue(210),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.palette_outlined,
                      size: 60,
                      color: kcPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (error != null) ...[
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: viewModel.navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Back to Login'),
                  ),
                ] else ...[
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 24),
                  Text(
                    'Processing Authentication...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();

  @override
  void onViewModelReady(AuthViewModel viewModel) {
    if (error != null) return;

    // Process the OAuth callback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = locator<AuthService>();
      final navigationService = locator<NavigationService>();

      try {
        if (provider != null && token != null) {
          // This is a placeholder for actual OAuth token handling
          // In a real app, you would validate the token with your auth service
          // and complete the authentication flow

          // Navigate to home on success
          await navigationService.clearStackAndShow(Routes.homeView);
        } else {
          // Navigate back to login if there's not enough info
          await navigationService.navigateToLoginView();
        }
      } catch (e) {
        // Handle errors by navigating to login with error parameter
        await navigationService.clearStackAndShow(Routes.loginView);
      }
    });
  }
}