import 'package:flutter/material.dart';
import 'package:my_app/features/auth/auth_viewmodel.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/button.dart';
import 'package:my_app/shared/card.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class LoginView extends StackedView<AuthViewModel> {
  const LoginView({Key? key}) : super(key: key);

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                  kSpaceMedium,
                  Text(
                    'MoodPalette',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  kSpaceSmall,
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  kSpaceLarge,

                  // Login form
                  CustomCard(
                    variant: CardVariant.elevated,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: viewModel.emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        kSpaceMedium,
                        TextField(
                          controller: viewModel.passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: viewModel.togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          obscureText: !viewModel.passwordVisible,
                        ),
                        kSpaceSmall,
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: viewModel.navigateToPasswordReset,
                            child: Text(
                              'Forgot password?',
                              style: linkStyle(context),
                            ),
                          ),
                        ),
                        if (viewModel.validationMessage != null) ...[
                          Text(
                            viewModel.validationMessage!,
                            style: errorStyle(context),
                          ),
                          kSpaceSmall,
                        ],
                        CustomButton(
                          text: 'Login',
                          isLoading: viewModel.isBusy,
                          isFullWidth: true,
                          onPressed: viewModel.login,
                        ),
                      ],
                    ),
                  ),
                  kSpaceMedium,

                  // OAuth sign in options
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.5))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or sign in with',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                  kSpaceMedium,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOAuthButton(
                        context,
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onPressed: () => viewModel.signInWithOAuth('google'),
                      ),
                      kHorizontalSpaceMedium,
                      _buildOAuthButton(
                        context,
                        icon: Icons.apple,
                        label: 'Apple',
                        onPressed: () => viewModel.signInWithOAuth('apple'),
                      ),
                      kHorizontalSpaceMedium,
                      _buildOAuthButton(
                        context,
                        icon: Icons.facebook,
                        label: 'Facebook',
                        onPressed: () => viewModel.signInWithOAuth('facebook'),
                      ),
                    ],
                  ),
                  kSpaceMedium,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: viewModel.navigateToRegister,
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOAuthButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();

  @override
  void onViewModelReady(AuthViewModel viewModel) {
    viewModel.setAuthMode(AuthMode.login);
  }
}
