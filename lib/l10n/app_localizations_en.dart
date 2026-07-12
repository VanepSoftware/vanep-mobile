// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vanep';

  @override
  String get welcomeTagline => 'School transport, simplified.';

  @override
  String get continueButton => 'Continue';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginCancelled => 'Sign-in was cancelled.';

  @override
  String get loginFailed => 'Could not sign in. Please try again.';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String homeSignedInAs(String email) {
    return 'You are signed in as $email.';
  }

  @override
  String get signOutButton => 'Sign out';
}
