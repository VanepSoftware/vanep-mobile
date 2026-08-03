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
  String driverShiftStartsAt(String time) {
    return 'Your shift starts at $time';
  }

  @override
  String get driverShiftOff => 'Off shift';

  @override
  String get driverShiftOn => 'On shift';

  @override
  String driverStudentsOnRouteToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students on today\'s route',
      one: '1 student on today\'s route',
    );
    return '$_temp0';
  }

  @override
  String get driverStartRoute => 'Start route';

  @override
  String get driverEndRoute => 'End route';

  @override
  String get driverShareLiveLocation => 'Share live location';

  @override
  String get navProposals => 'Proposals';

  @override
  String get navStudents => 'Students';

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

  @override
  String get profileAssistantStatusUnlinked => 'Unlinked';

  @override
  String get profileAssistantStatusPending => 'Pending invite';

  @override
  String get profileAssistantStatusActive => 'Active';

  @override
  String get profileAssistantStatusInactive => 'Inactive';

  @override
  String get profileSave => 'Save';

  @override
  String get profileChange => 'Change';

  @override
  String get profileChangeEmailTitle => 'Change email';

  @override
  String get profileChangeEmailSubmit => 'Change email';

  @override
  String get profileEmailChangeConfirmationTitle => 'Check your email';

  @override
  String profileEmailChangeConfirmationMessage(String email) {
    return 'We sent a confirmation link to $email. Open it to finish changing your email.';
  }

  @override
  String profilePendingEmailBanner(String email) {
    return 'Confirm the new email sent to $email.';
  }

  @override
  String profileCooldownDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get profileEditSaveSuccess => 'Personal data saved.';

  @override
  String profileEditErrorCooldown(String date) {
    return 'You can change this again on $date.';
  }

  @override
  String get profileEditErrorEmailDuplicate => 'This email is already in use.';

  @override
  String get profileEditErrorFieldNull => 'This field is required.';

  @override
  String get profileEditErrorPhoneBlank => 'Enter a valid phone number.';

  @override
  String get profileEditErrorEmailSame => 'That is already your current email.';

  @override
  String get profileEditErrorEmailInvalid => 'Enter a valid email address.';

  @override
  String get profileEditErrorEmailRequired => 'Email is required.';

  @override
  String profileEditErrorNameTooLong(int max) {
    return 'Name must be at most $max characters.';
  }

  @override
  String profileEditErrorPhoneTooLong(int max) {
    return 'Phone number must be at most $max characters.';
  }

  @override
  String profileEditErrorEmailTooLong(int max) {
    return 'Email must be at most $max characters.';
  }

  @override
  String get profileEditErrorNetwork =>
      'Could not update your profile. Check your connection and try again.';

  @override
  String get profileEditErrorUnexpected =>
      'Something went wrong. Please try again.';

  @override
  String get profileEditLoadError =>
      'Could not load your personal data. Pull to try again.';

  @override
  String get profileEditRetry => 'Try again';
}
