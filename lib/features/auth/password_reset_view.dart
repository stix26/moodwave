import 'package:flutter/material.dart';
import 'package:my_app/features/auth/auth_viewmodel.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/button.dart';
import 'package:my_app/shared/card.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class PasswordResetView extends StackedView<AuthViewModel> {
  final String? token;

  const PasswordResetView({Key? key, this.token}) : super(key: key);

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
                    token == null ? 'Reset Password' : 'Create New Password',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  kSpaceLarge,

                  // Reset password form
                  CustomCard(
                    variant: CardVariant.elevated,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (token == null) ...[
                          // Request password reset form
                          Text(
                            'Enter your email address',
                            style: heading3Style(context),
                          ),
                          kSpaceSmall,
                          Text(
                            'We\'ll send you a link to reset your password.',
                            style: bodyStyle(context).copyWith(
                              color: kcSecondaryTextColor,
                            ),
                          ),
                          kSpaceMedium,
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
                          if (viewModel.validationMessage != null) ...[
                            kSpaceSmall,
                            Text(
                              viewModel.validationMessage!,
                              style: errorStyle(context),
                            ),
                          ],
                          kSpaceMedium,
                          CustomButton(
                            text: 'Send Reset Link',
                            isLoading: viewModel.isBusy,
                            isFullWidth: true,
                            onPressed: viewModel.requestPasswordReset,
                          ),
                        ] else ...[
                          // Set new password form
                          Text(
                            'Create a new password',
                            style: heading3Style(context),
                          ),
                          kSpaceSmall,
                          Text(
                            'Your new password must be different from your previous password.',
                            style: bodyStyle(context).copyWith(
                              color: kcSecondaryTextColor,
                            ),
                          ),
                          kSpaceMedium,
                          TextField(
                            controller: viewModel.passwordController,
                            decoration: InputDecoration(
                              labelText: 'New Password',
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
                          kSpaceMedium,
                          TextField(
                            controller: viewModel.confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
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
                          if (viewModel.validationMessage != null) ...[
                            kSpaceSmall,
                            Text(
                              viewModel.validationMessage!,
                              style: errorStyle(context),
                            ),
                          ],
                          kSpaceMedium,
                          CustomButton(
                            text: 'Reset Password',
                            isLoading: viewModel.isBusy,
                            isFullWidth: true,
                            onPressed: () => viewModel.resetPassword(token!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  kSpaceMedium,
                  TextButton(
                    onPressed: viewModel.navigateToLogin,
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
    viewModel.setResetPasswordMode(token != null);
  }
}
