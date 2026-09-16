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
  String get loginHeading => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in with your email and password to continue';

  @override
  String get loginEmailHint => 'you@email.com';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginOrDivider => 'or';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginFailed => 'Could not sign in. Please try again.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get loginErrorEmailNotVerified => 'Confirm your email to sign in.';

  @override
  String get loginErrorAccountLocked =>
      'Too many failed attempts. Try again in a few minutes.';

  @override
  String get loginErrorAccountDisabled => 'This account has been deactivated.';

  @override
  String get authErrorTooManyRequests =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginErrorGoogle => 'Could not sign in with Google. Try again.';

  @override
  String get signupGoogleRegisteredSignIn =>
      'Sign-up complete! Sign in with Google to continue.';

  @override
  String get signupCreateAccount => 'Create account';

  @override
  String get signupChooseTypeTitle => 'How do you want to use Vanep?';

  @override
  String get signupTypeClient => 'I\'m a client (guardian)';

  @override
  String get signupTypeDriver => 'I\'m a driver';

  @override
  String get signupTypeAssistant => 'I\'m an assistant';

  @override
  String get signupChooseTypeSubtitle => 'Pick the account type that fits you.';

  @override
  String get signupTypeClientDescription =>
      'Find and hire school transport for your dependents.';

  @override
  String get signupTypeDriverDescription =>
      'Offer school transport with your van.';

  @override
  String get signupTypeAssistantDescription =>
      'Look after the students on a driver\'s routes.';

  @override
  String get signupAlreadyHaveAccount => 'Already have an account?';

  @override
  String get signupSectionAccess => 'Sign-in details';

  @override
  String get signupSectionPersonal => 'Personal details';

  @override
  String get signupSectionProfessional => 'Professional details';

  @override
  String get signupContinue => 'Continue';

  @override
  String signupStepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get signupStepAccessSubtitle =>
      'You will use this email and password to sign in.';

  @override
  String get signupStepPersonalSubtitle =>
      'We need these details to identify your account.';

  @override
  String get signupStepProfessionalSubtitle =>
      'Tell us a little about your transport service.';

  @override
  String get signupStepConfirmationTitle => 'Review and confirm';

  @override
  String get signupStepConfirmationSubtitle =>
      'Check your account details and accept the terms to finish.';

  @override
  String get signupNameHint => 'Your full name';

  @override
  String get signupPasswordHint => 'Create a password';

  @override
  String get signupFieldPasswordConfirmation => 'Confirm password';

  @override
  String get signupPasswordConfirmationHint => 'Repeat the password';

  @override
  String passwordRequirementMinLength(int min) {
    return 'At least $min characters';
  }

  @override
  String get passwordRequirementUppercase => 'One uppercase letter';

  @override
  String get passwordRequirementSpecial =>
      'One special character (e.g. ! @ # \$)';

  @override
  String get accountIssuePasswordWeak =>
      'The password does not meet every requirement.';

  @override
  String get accountIssuePasswordMismatch => 'The passwords do not match.';

  @override
  String get signupDocumentHint => '000.000.000-00';

  @override
  String get signupPhoneHint => '(00) 00000-0000';

  @override
  String get signupBirthDateHint => 'mm/dd/yyyy';

  @override
  String get signupBasePriceHint => '0.00';

  @override
  String get signupExperienceYearsHint => '0';

  @override
  String get signupCnpjHint => '00.000.000/0000-00';

  @override
  String get signupTitleClient => 'Client sign-up';

  @override
  String get signupTitleDriver => 'Driver sign-up';

  @override
  String get signupTitleAssistant => 'Assistant sign-up';

  @override
  String get signupFieldName => 'Name';

  @override
  String get signupFieldDocument => 'CPF';

  @override
  String get signupFieldPhone => 'Phone';

  @override
  String get signupFieldBirthDate => 'Birth date';

  @override
  String get signupFieldGender => 'Sex';

  @override
  String get signupFieldCnpj => 'CNPJ (yours or your company\'s)';

  @override
  String get signupFieldExperienceYears => 'Years of experience';

  @override
  String get signupFieldBasePrice => 'Base price (R\$)';

  @override
  String get signupAcceptTerms => 'I accept the terms of use';

  @override
  String emailCodeSentTo(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String get emailVerificationTitle => 'Confirm your email';

  @override
  String get verificationCodeLabel => 'Code';

  @override
  String get verificationCodeHint => '000000';

  @override
  String get emailVerificationSubmit => 'Confirm';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get codeResent => 'We sent a new code.';

  @override
  String get emailVerifiedSignIn =>
      'Email confirmed! Sign in with your password.';

  @override
  String get accountIssueCodeInvalid => 'Enter the 6 digits of the code.';

  @override
  String get loginForgotPassword => 'Forgot my password';

  @override
  String get passwordResetTitle => 'Recover password';

  @override
  String get passwordResetEmailHint =>
      'Enter your account email. If it exists, we will send a code so you can create a new password.';

  @override
  String get passwordResetSendCode => 'Send code';

  @override
  String passwordResetCodeSentTo(String email) {
    return 'If there is an account for $email, we sent a 6-digit code.';
  }

  @override
  String get passwordResetCodeTitle => 'Create a new password';

  @override
  String get passwordResetNewPasswordHint => 'At least 8 characters';

  @override
  String get passwordResetNewPasswordLabel => 'New password';

  @override
  String get passwordResetSubmit => 'Reset password';

  @override
  String get passwordResetDone =>
      'Password reset! Sign in with your new password.';

  @override
  String get accountIssueRequired => 'Fill in this field.';

  @override
  String get accountIssueEmailInvalid => 'Invalid email.';

  @override
  String get accountIssueDocumentInvalid =>
      'Invalid CPF. Check the numbers entered.';

  @override
  String get accountIssueNumberInvalid => 'Enter a valid number.';

  @override
  String accountIssuePasswordTooShort(int min) {
    return 'The password must be at least $min characters long.';
  }

  @override
  String get accountIssueTermsNotAccepted =>
      'You must accept the terms of use.';

  @override
  String get accountIssueBasePriceNotPositive =>
      'The base price must be greater than zero.';

  @override
  String get accountIssueEmailDuplicate =>
      'An account with this email already exists.';

  @override
  String get accountIssueDocumentDuplicate =>
      'An account with this CPF already exists.';

  @override
  String get accountIssueRejected => 'Check this field.';

  @override
  String get accountErrorCheckFields => 'Check the highlighted fields.';

  @override
  String get accountErrorInvalidCode => 'Invalid or expired code.';

  @override
  String get accountErrorInvalidSignupTicket =>
      'Your Google sign-up expired. Sign in with Google again.';

  @override
  String get accountErrorNetwork => 'Could not reach the server. Try again.';

  @override
  String get accountErrorUnexpected => 'Something went wrong. Try again.';

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
  String get profilePendingEmailMenuSubtitle => 'Confirm your new email';

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

  @override
  String get serviceAreasTitle => 'Where you operate';

  @override
  String get serviceAreasSubtitle =>
      'Register up to 10 regions. The more specific, the easier a client finds you.';

  @override
  String get serviceAreasSearchHint =>
      'Search a neighbourhood, block or region';

  @override
  String get serviceAreasEmpty => 'No region registered yet.';

  @override
  String get serviceAreasMaxReached => 'You reached the maximum of 10 regions.';

  @override
  String get serviceAreasSave => 'Save regions';

  @override
  String get serviceAreasSaved => 'Regions saved.';

  @override
  String get serviceAreasRemove => 'Remove region';

  @override
  String get serviceAreasCityWideHint => 'Whole city — not very specific';

  @override
  String get serviceAreasOnboardingTitle => 'Tell us where you operate';

  @override
  String get serviceAreasOnboardingBody =>
      'Without it, no client finds you in search. It takes less than a minute.';

  @override
  String get serviceAreasOnboardingStart => 'Set it up now';

  @override
  String get serviceAreasOnboardingSkip => 'Later';

  @override
  String get serviceAreaFailureDistrictRequired =>
      'This city requires choosing a neighbourhood or region, not the whole city.';

  @override
  String get serviceAreaFailureTooMany =>
      'You can register at most 10 regions.';

  @override
  String get serviceAreaFailurePlaceNotResolved =>
      'This place could not be interpreted. Please choose another suggestion.';

  @override
  String get serviceAreaFailureRateLimited =>
      'Too many lookups. Please wait a moment and try again.';

  @override
  String get serviceAreaFailureNetwork =>
      'No connection to the server. Please try again.';

  @override
  String get serviceAreaFailureUnexpected =>
      'Something went wrong. Please try again.';

  @override
  String get placeAutocompleteNoResults => 'No place found.';

  @override
  String get placeAutocompleteNetworkError =>
      'Could not search places. Please try again.';

  @override
  String get placeAutocompleteKeyError =>
      'Place search is unavailable right now.';

  @override
  String get placeAutocompleteRetry => 'Try again';

  @override
  String get driverSearchTitle => 'Find a driver';

  @override
  String get driverSearchHint => 'Address or school';

  @override
  String get driverSearchEmpty => 'No driver covers this place yet.';

  @override
  String get driverSearchPlaceNotResolved =>
      'This place could not be interpreted. Please choose another suggestion.';

  @override
  String get driverSearchRateLimited =>
      'Too many searches. Please wait a moment and try again.';

  @override
  String get driverSearchNetworkError =>
      'No connection to the server. Please try again.';

  @override
  String get driverSearchUnexpectedError =>
      'Something went wrong. Please try again.';

  @override
  String get driverSearchCoversWholeCity => 'Covers the whole city';

  @override
  String get profileServiceAreas => 'Where you operate';
}
