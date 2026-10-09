import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

enum AssistantInviteStep {
  code,
  signup,
  success,
}

enum AssistantSignupField {
  name,
  birthDate,
  email,
  cpf,
  password,
  passwordConfirmation,
  acceptTerms,
}

enum AssistantSignupFieldError {
  required,
  invalid,
  underage,
  mismatch,
}

class AssistantInviteState extends Equatable {
  const AssistantInviteState({
    this.step = AssistantInviteStep.code,
    this.code = '',
    this.isValidatingCode = false,
    this.invite,
    this.codeFailure,
    this.name = '',
    this.birthDate,
    this.email = '',
    this.cpf = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.acceptTerms = false,
    this.fieldErrors = const {},
    this.isSubmittingSignup = false,
    this.signupFailure,
  });

  final AssistantInviteStep step;
  final String code;
  final bool isValidatingCode;
  final AssistantInvite? invite;
  final AssistantFailure? codeFailure;

  final String name;
  final DateTime? birthDate;
  final String email;
  final String cpf;
  final String password;
  final String passwordConfirmation;
  final bool acceptTerms;
  final Map<AssistantSignupField, AssistantSignupFieldError> fieldErrors;
  final bool isSubmittingSignup;
  final AssistantFailure? signupFailure;

  bool get canValidateCode => code.trim().isNotEmpty && !isValidatingCode;

  bool get isUnderage {
    final date = birthDate;
    if (date == null) return false;
    final now = DateTime.now();
    var age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    return age < 18;
  }

  bool get canSubmitSignup =>
      name.trim().isNotEmpty &&
      birthDate != null &&
      !isUnderage &&
      email.trim().isNotEmpty &&
      cpf.replaceAll(RegExp(r'\D'), '').length == 11 &&
      password.isNotEmpty &&
      passwordConfirmation == password &&
      acceptTerms &&
      !isSubmittingSignup;

  AssistantInviteState copyWith({
    AssistantInviteStep? step,
    String? code,
    bool? isValidatingCode,
    AssistantInvite? invite,
    AssistantFailure? codeFailure,
    bool clearCodeFailure = false,
    String? name,
    DateTime? birthDate,
    String? email,
    String? cpf,
    String? password,
    String? passwordConfirmation,
    bool? acceptTerms,
    Map<AssistantSignupField, AssistantSignupFieldError>? fieldErrors,
    bool? isSubmittingSignup,
    AssistantFailure? signupFailure,
    bool clearSignupFailure = false,
  }) {
    return AssistantInviteState(
      step: step ?? this.step,
      code: code ?? this.code,
      isValidatingCode: isValidatingCode ?? this.isValidatingCode,
      invite: invite ?? this.invite,
      codeFailure: clearCodeFailure ? null : (codeFailure ?? this.codeFailure),
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      password: password ?? this.password,
      passwordConfirmation:
          passwordConfirmation ?? this.passwordConfirmation,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmittingSignup: isSubmittingSignup ?? this.isSubmittingSignup,
      signupFailure:
          clearSignupFailure ? null : (signupFailure ?? this.signupFailure),
    );
  }

  @override
  List<Object?> get props => [
        step,
        code,
        isValidatingCode,
        invite,
        codeFailure,
        name,
        birthDate,
        email,
        cpf,
        password,
        passwordConfirmation,
        acceptTerms,
        fieldErrors,
        isSubmittingSignup,
        signupFailure,
      ];
}
