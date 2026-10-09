import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/value_objects/password_policy.dart';
import '../../domain/usecases/register_assistant_with_invite.dart';
import '../../domain/usecases/validate_assistant_invite.dart';
import 'assistant_invite_state.dart';

class AssistantInviteCubit extends Cubit<AssistantInviteState> {
  AssistantInviteCubit({
    required this.validateInvite,
    required this.registerWithInvite,
    String? initialCode,
  }) : super(AssistantInviteState(code: initialCode ?? '')) {
    if (initialCode != null && initialCode.trim().isNotEmpty) {
      validateCode(initialCode);
    }
  }

  final ValidateAssistantInvite validateInvite;
  final RegisterAssistantWithInvite registerWithInvite;

  void updateCode(String code) {
    emit(state.copyWith(code: code, clearCodeFailure: true));
  }

  Future<void> validateCode([String? directCodeOrToken]) async {
    final codeToValidate = (directCodeOrToken ?? state.code).trim();
    if (codeToValidate.isEmpty || state.isValidatingCode) return;

    emit(
      state.copyWith(
        code: codeToValidate,
        isValidatingCode: true,
        clearCodeFailure: true,
      ),
    );

    final result = await validateInvite(codeToValidate);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isValidatingCode: false,
            codeFailure: failure,
          ),
        );
      },
      (invite) {
        emit(
          state.copyWith(
            isValidatingCode: false,
            invite: invite,
            step: AssistantInviteStep.signup,
          ),
        );
      },
    );
  }

  void updateName(String value) {
    final errors = Map<AssistantSignupField, AssistantSignupFieldError>.from(
      state.fieldErrors,
    )..remove(AssistantSignupField.name);
    emit(state.copyWith(name: value, fieldErrors: errors, clearSignupFailure: true));
  }

  void updateBirthDate(DateTime value) {
    final errors = Map<AssistantSignupField, AssistantSignupFieldError>.from(
      state.fieldErrors,
    )..remove(AssistantSignupField.birthDate);
    emit(state.copyWith(birthDate: value, fieldErrors: errors, clearSignupFailure: true));
  }

  void updateEmail(String value) {
    final errors = Map<AssistantSignupField, AssistantSignupFieldError>.from(
      state.fieldErrors,
    )..remove(AssistantSignupField.email);
    emit(state.copyWith(email: value, fieldErrors: errors, clearSignupFailure: true));
  }

  void updateCpf(String value) {
    final errors = Map<AssistantSignupField, AssistantSignupFieldError>.from(
      state.fieldErrors,
    )..remove(AssistantSignupField.cpf);
    emit(state.copyWith(cpf: value, fieldErrors: errors, clearSignupFailure: true));
  }

  void updatePassword(String value) {
    final errors = Map<AssistantSignupField, AssistantSignupFieldError>.from(
      state.fieldErrors,
    )..remove(AssistantSignupField.password);
    emit(state.copyWith(password: value, fieldErrors: errors, clearSignupFailure: true));
  }

  void updatePasswordConfirmation(String value) {
    final errors = Map<AssistantSignupField, AssistantSignupFieldError>.from(
      state.fieldErrors,
    )..remove(AssistantSignupField.passwordConfirmation);
    emit(
      state.copyWith(
        passwordConfirmation: value,
        fieldErrors: errors,
        clearSignupFailure: true,
      ),
    );
  }

  void updateAcceptTerms(bool value) {
    final errors = Map<AssistantSignupField, AssistantSignupFieldError>.from(
      state.fieldErrors,
    )..remove(AssistantSignupField.acceptTerms);
    emit(state.copyWith(acceptTerms: value, fieldErrors: errors, clearSignupFailure: true));
  }

  Map<AssistantSignupField, AssistantSignupFieldError> _validateFields() {
    final errors = <AssistantSignupField, AssistantSignupFieldError>{};

    if (state.name.trim().isEmpty) {
      errors[AssistantSignupField.name] = AssistantSignupFieldError.required;
    }

    if (state.birthDate == null) {
      errors[AssistantSignupField.birthDate] =
          AssistantSignupFieldError.required;
    } else if (state.isUnderage) {
      errors[AssistantSignupField.birthDate] =
          AssistantSignupFieldError.underage;
    }

    final email = state.email.trim();
    if (email.isEmpty) {
      errors[AssistantSignupField.email] = AssistantSignupFieldError.required;
    } else if (!email.contains('@') || !email.contains('.')) {
      errors[AssistantSignupField.email] = AssistantSignupFieldError.invalid;
    }

    final cpfDigits = state.cpf.replaceAll(RegExp(r'\D'), '');
    if (cpfDigits.isEmpty) {
      errors[AssistantSignupField.cpf] = AssistantSignupFieldError.required;
    } else if (cpfDigits.length != 11) {
      errors[AssistantSignupField.cpf] = AssistantSignupFieldError.invalid;
    }

    if (state.password.isEmpty) {
      errors[AssistantSignupField.password] =
          AssistantSignupFieldError.required;
    } else if (state.password.length < PasswordPolicy.minLength ||
        !PasswordRequirement.uppercaseLetter.isMetBy(state.password) ||
        !PasswordRequirement.specialCharacter.isMetBy(state.password)) {
      errors[AssistantSignupField.password] = AssistantSignupFieldError.invalid;
    }

    if (state.passwordConfirmation.isEmpty) {
      errors[AssistantSignupField.passwordConfirmation] =
          AssistantSignupFieldError.required;
    } else if (state.passwordConfirmation != state.password) {
      errors[AssistantSignupField.passwordConfirmation] =
          AssistantSignupFieldError.mismatch;
    }

    if (!state.acceptTerms) {
      errors[AssistantSignupField.acceptTerms] =
          AssistantSignupFieldError.required;
    }

    return errors;
  }

  Future<void> submitSignup() async {
    final validationErrors = _validateFields();
    if (validationErrors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: validationErrors));
      return;
    }

    emit(
      state.copyWith(
        isSubmittingSignup: true,
        clearSignupFailure: true,
      ),
    );

    final birthDate = state.birthDate!;
    final year = birthDate.year.toString().padLeft(4, '0');
    final month = birthDate.month.toString().padLeft(2, '0');
    final day = birthDate.day.toString().padLeft(2, '0');
    final formattedBirthDate = '$year-$month-$day';

    final result = await registerWithInvite(
      inviteToken: state.invite?.token ?? state.code.trim(),
      name: state.name.trim(),
      birthDate: formattedBirthDate,
      email: state.email.trim(),
      cpf: state.cpf,
      password: state.password,
      acceptTerms: state.acceptTerms,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSubmittingSignup: false,
            signupFailure: failure,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            isSubmittingSignup: false,
            step: AssistantInviteStep.success,
          ),
        );
      },
    );
  }

  void goToCodeStep() {
    emit(state.copyWith(step: AssistantInviteStep.code));
  }
}
