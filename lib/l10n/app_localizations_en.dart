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

  @override
  String get driversSearchHint => 'Search route or school…';

  @override
  String get driversSuggestionsNearYou => 'Suggestions near you';

  @override
  String driverExperienceYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get driversEmpty => 'No drivers found.';

  @override
  String get driversLoadError => 'Could not load drivers. Please try again.';

  @override
  String get driversRetryButton => 'Try again';

  @override
  String get navHome => 'Home';

  @override
  String get navVans => 'Vans';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get profilePersonalData => 'Personal data';

  @override
  String get profileAddresses => 'Addresses';

  @override
  String get profilePaymentMethods => 'Payment methods';

  @override
  String get profileDependents => 'Manage dependents';

  @override
  String get profileVans => 'Vans';

  @override
  String get profileContracts => 'Contracts';

  @override
  String get profileProfessionalData => 'Professional data';

  @override
  String get profileAssistantInvite => 'Driver invite';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profilePrivacySecurity => 'Privacy and security';

  @override
  String get profileSignOutTitle => 'Sign out of your account?';

  @override
  String get profileSignOutMessage =>
      'You\'ll be signed out on this device. You can sign in again anytime.';

  @override
  String get profileSignOutCancel => 'Cancel';

  @override
  String get profileFieldName => 'Name';

  @override
  String get profileFieldEmail => 'Email';

  @override
  String get profileFieldPhone => 'Phone';

  @override
  String get profileFieldDocument => 'Document';

  @override
  String get profileFieldBirthDate => 'Date of birth';

  @override
  String get profileFieldGender => 'Gender';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileGenderOther => 'Other';

  @override
  String get profileFieldEmpty => '—';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionServices => 'Services';

  @override
  String get profileSectionPreferences => 'Preferences';
}
