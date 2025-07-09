import 'package:my_app/features/auth/login_view.dart';
import 'package:my_app/features/auth/oauth_wrapper.dart';
import 'package:my_app/features/auth/password_reset_view.dart';
import 'package:my_app/features/auth/register_view.dart';
import 'package:my_app/features/profile/profile_view.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/mood_service.dart';
import 'package:my_app/services/openai_service.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:my_app/shared/info_alert_dialog.dart';
import 'package:my_app/features/home/home_view.dart';
import 'package:my_app/features/startup/startup_view.dart';
import 'package:my_app/features/mood_entry/mood_entry_view.dart';
import 'package:my_app/features/mood_journal/mood_journal_view.dart';
import 'package:my_app/features/mood_timeline/mood_timeline_view.dart';
import 'package:my_app/features/mood_insights/mood_insights_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: MoodEntryView),
    MaterialRoute(page: MoodJournalView),
    MaterialRoute(page: MoodTimelineView),
    MaterialRoute(page: MoodInsightsView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: PasswordResetView),
    MaterialRoute(page: ProfileView),
    MaterialRoute(page: OAuthWrapper),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: MoodService),
    LazySingleton(classType: OpenAIService),
    LazySingleton(classType: SupabaseService),
    InitializableSingleton(classType: AuthService),
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
  ],
)
class App {}