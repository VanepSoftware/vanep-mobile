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
  String emailCodeEnterFor(String email) {
    return 'Enter the 6-digit code that was sent to $email. If it expired or never arrived, ask for a new one below.';
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
  String get emailVerifiedSignIn => 'Email confirmed! Sign in to continue.';

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
  String get passwordResetNewPasswordHint => 'Enter the new password';

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
  String get comingSoon => 'Coming soon';

  @override
  String get navContracts => 'Contracts';

  @override
  String get navDependents => 'Dependents';

  @override
  String get navProposals => 'Proposals';

  @override
  String get navProposalsAndContracts => 'Proposals & contracts';

  @override
  String get clientHomeNoLinkedVanTitle => 'No linked van';

  @override
  String get clientHomeNoLinkedVanMessage =>
      'You don\'t have a van yet. Find one that serves your area.';

  @override
  String get clientHomeFindVanButton => 'Find a van';

  @override
  String get driverVansMyVans => 'My vans';

  @override
  String get homeMenuTooltip => 'Open menu';

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
  String get navStudents => 'Students';

  @override
  String get profilePersonalData => 'Personal data';

  @override
  String get personalDataSubtitle =>
      'Review and update your account details and your home address.';

  @override
  String get profilePaymentMethods => 'Payment methods';

  @override
  String get profileDependents => 'Manage dependents';

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
  String get dependentsSubtitle =>
      'Add and manage the people who ride the van.';

  @override
  String get dependentsEmpty => 'You have not added any dependents yet.';

  @override
  String get dependentsAdd => 'Add dependent';

  @override
  String get dependentsRetry => 'Try again';

  @override
  String get dependentsLoadError => 'Could not load your dependents.';

  @override
  String get dependentsDefaultBadge => 'Default';

  @override
  String get dependentsSetDefault => 'Set as default';

  @override
  String get dependentsDefaultUpdated => 'Default dependent updated.';

  @override
  String dependentsAgeYears(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString years',
      one: '1 year',
      zero: 'under 1 year',
    );
    return '$_temp0';
  }

  @override
  String get dependentFormNewTitle => 'New dependent';

  @override
  String get dependentFormEditTitle => 'Edit dependent';

  @override
  String get dependentFormSave => 'Save';

  @override
  String get dependentFormSaved => 'Dependent saved.';

  @override
  String get dependentFieldName => 'Name';

  @override
  String get dependentFieldBirthDate => 'Date of birth';

  @override
  String get dependentFieldBirthDateEmpty => 'Pick a date';

  @override
  String get dependentFieldBirthDateClear => 'Clear date';

  @override
  String get dependentFieldGender => 'Gender';

  @override
  String get dependentErrorNameRequired => 'Enter the dependent\'s name.';

  @override
  String get dependentErrorBirthDateFuture =>
      'The date of birth cannot be in the future.';

  @override
  String get dependentErrorBirthDateInvalid => 'Invalid date of birth.';

  @override
  String get dependentFailureValidation =>
      'Could not save. Review the data and try again.';

  @override
  String get dependentFailureNotFound => 'This dependent no longer exists.';

  @override
  String get dependentFailureNetwork =>
      'No connection to the server. Please try again.';

  @override
  String get dependentFailureUnexpected =>
      'Something went wrong. Please try again.';

  @override
  String get dependentFormSubtitle =>
      'Enter the details of who rides the van. Only the name is required.';

  @override
  String get dependentFailureCityNotFound =>
      'We could not find that city. Choose the municipality again.';

  @override
  String get dependentFieldAddress => 'Address';

  @override
  String get dependentFieldAddressEmpty => 'No address set.';

  @override
  String get dependentFieldAddressRemove => 'Remove address';

  @override
  String get profileGenderUnspecified => 'Prefer not to say';

  @override
  String get personalAddressCardTitle => 'Address';

  @override
  String get personalAddressEmpty => 'No home address registered yet.';

  @override
  String get postalAddressFieldNumber => 'Number';

  @override
  String get postalAddressFieldComplement => 'Complement';

  @override
  String get postalAddressFieldStreet => 'Street';

  @override
  String get postalAddressFieldNeighborhood => 'Neighborhood';

  @override
  String get postalAddressFieldZip => 'ZIP code';

  @override
  String get postalAddressFieldUf => 'State';

  @override
  String get postalAddressFieldMunicipality => 'City';

  @override
  String get postalAddressCitySearchHint => 'Search city';

  @override
  String get personalAddressClearAction => 'Clear address';

  @override
  String get personalAddressClearTitle => 'Clear address?';

  @override
  String get personalAddressClearMessage =>
      'The home address will be removed from the account.';

  @override
  String get personalAddressClearConfirm => 'Clear';

  @override
  String get personalAddressClearSuccess => 'Address removed.';

  @override
  String get personalAddressFailureCityNotFound =>
      'City not found in the catalog.';

  @override
  String get personalAddressFailureValidation =>
      'Please review the address fields and try again.';

  @override
  String get personalAddressFailureNetwork =>
      'No connection to the server. Please try again.';

  @override
  String get personalAddressFailureUnexpected =>
      'Something went wrong. Please try again.';

  @override
  String get personalAddressRegisterAction => 'Add address';

  @override
  String get personalAddressCardMenuTooltip => 'More options';

  @override
  String get personalAddressEditAction => 'Edit address';

  @override
  String get postalAddressHintUf => 'UF';

  @override
  String get personalAddressFormTitleNew => 'Add address';

  @override
  String get personalAddressFormTitleEdit => 'Edit address';

  @override
  String get personalAddressFormSubtitle =>
      'Enter your ZIP code and complete the address details.';

  @override
  String get personalAddressSaveAction => 'Save address';

  @override
  String get postalAddressHintZip => '00000-000';

  @override
  String get postalAddressHintStreet => 'Street or avenue name';

  @override
  String get postalAddressHintNumber => 'No.';

  @override
  String get postalAddressHintComplement => 'Apt, block, landmark';

  @override
  String get postalAddressHintNeighborhood => 'e.g. Downtown';

  @override
  String get postalAddressHintCity => 'Select the city';

  @override
  String get postalAddressFieldRequiredError => 'Required field.';

  @override
  String get postalAddressChooseUfFirst => 'Select the state first';

  @override
  String get postalAddressLookingUpCep => 'Looking up ZIP code';

  @override
  String get postalAddressCityPickerTitle => 'Select city';

  @override
  String get postalAddressNoCitiesFound => 'No cities found.';

  @override
  String get cepFailureInvalidFormat => 'ZIP code must have 8 digits.';

  @override
  String get cepFailureNotFound => 'ZIP code not found.';

  @override
  String get cepFailureCityNotInCatalog =>
      'This ZIP code city is not in the catalog.';

  @override
  String get cepFailureRateLimited =>
      'Too many ZIP lookups. Please wait a moment.';

  @override
  String get cepFailureUnavailable =>
      'ZIP lookup is unavailable. Please fill in the address.';

  @override
  String get cepFailureNetwork =>
      'No connection to the server. Please try again.';

  @override
  String get cepFailureUnexpected => 'Something went wrong. Please try again.';

  @override
  String get ibgeLocationsFailureUfMissing => 'Please choose a state.';

  @override
  String get ibgeLocationsFailureUfNotFound => 'State not found.';

  @override
  String get ibgeLocationsFailureNetwork =>
      'No connection to the server. Please try again.';

  @override
  String get ibgeLocationsFailureUnexpected =>
      'Something went wrong. Please try again.';

  @override
  String get placesCityUnmatched =>
      'This city does not match the catalog. Please choose another suggestion.';
}
