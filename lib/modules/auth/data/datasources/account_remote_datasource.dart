import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../domain/value_objects/gender.dart';
import '../../domain/value_objects/signup_form.dart';
import '../../domain/value_objects/user_type.dart';

class AccountRemoteDataSource {
  AccountRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  Future<void> signUp(SignupForm form) async {
    await dio.post<void>(
      signupEndpointFor(form.type),
      data: {...credentialsJsonOf(form), ...profileJsonOf(form)},
    );
  }

  Future<void> completeGoogleSignup({
    required String ticket,
    required SignupForm form,
  }) async {
    await dio.post<void>(
      environment.signupCompleteEndpoint,
      data: {
        'signupTicket': ticket,
        'type': UserType.toApi(form.type),
        ...profileJsonOf(form),
      },
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await dio.post<void>(
      environment.emailVerifyEndpoint,
      data: {'email': email, 'code': code},
    );
  }

  Future<void> resendEmailVerification(String email) async {
    await dio.post<void>(
      environment.emailVerifyResendEndpoint,
      data: {'email': email},
    );
  }

  Future<void> requestPasswordReset(String email) async {
    await dio.post<void>(
      environment.passwordForgotEndpoint,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await dio.post<void>(
      environment.passwordResetEndpoint,
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
  }

  String signupEndpointFor(UserType type) {
    return switch (type) {
      UserType.client => environment.signupClientEndpoint,
      UserType.driver => environment.signupDriverEndpoint,
      UserType.assistant => environment.signupAssistantEndpoint,
      UserType.admin => throw ArgumentError.value(type, 'type'),
    };
  }
}

Map<String, Object?> credentialsJsonOf(SignupForm form) {
  return {
    'name': form.name.trim(),
    'email': form.email.trim(),
    'password': form.password,
  };
}

Map<String, Object?> profileJsonOf(SignupForm form) {
  final birthDate = form.birthDate;
  return {
    'document': form.documentDigits,
    if (form.phoneDigits.isNotEmpty) 'phone': form.phoneDigits,
    if (birthDate != null) 'birthDate': formatIsoDate(birthDate),
    if (form.gender != null) 'gender': Gender.toApi(form.gender),
    'acceptTerms': form.acceptTerms,
    if (form.isDriver) ...driverJsonOf(form),
  };
}

Map<String, Object?> driverJsonOf(SignupForm form) {
  return {
    'basePrice': form.basePriceValue,
    if (form.cnpjDigits.isNotEmpty) 'cnpj': form.cnpjDigits,
    if (form.experienceYearsValue != null)
      'experienceYears': form.experienceYearsValue,
  };
}

String formatIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
