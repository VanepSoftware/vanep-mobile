import 'package:dio/dio.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/environment/environment.dart';
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
