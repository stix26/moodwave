import 'package:my_app/app/app.locator.dart';
import 'package:my_app/app/app.router.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _loadingMessage = 'Initializing your mood palette...';
  String get loadingMessage => _loadingMessage;

  Future<void> runStartupLogic() async {
    // Simulate app initialization tasks
    _isLoading = true;
    await _initializeApp();

    // Check authentication state and navigate appropriately
    if (_authService.isAuthenticated) {
      await _navigationService.replaceWithHomeView();
    } else {
      await _navigationService.replaceWithLoginView();
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Stage 1: App configuration
      _loadingMessage = 'Loading app configuration...';
      rebuildUi();
      await Future.delayed(const Duration(milliseconds: 500));

      // Stage 2: Initialize services
      _loadingMessage = 'Preparing mood palette...';
      rebuildUi();
      await Future.delayed(const Duration(milliseconds: 1000));

      // Stage 3: Load user data
      _loadingMessage = 'Almost ready...';
      rebuildUi();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      setError(e.toString());
    } finally {
      _isLoading = false;
    }
  }
}
