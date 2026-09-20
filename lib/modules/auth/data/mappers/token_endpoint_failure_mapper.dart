import 'package:dio/dio.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/value_objects/google_signup_ticket.dart';

AuthFailure mapTokenEndpointFailure(DioException error) {
  final response = error.response;
  if (response == null) return NetworkAuthFailure(error.message);
  if (response.statusCode == 429) return const TooManyRequestsAuthFailure();

  final errorCode = oauthErrorCodeOf(response.data);
  return switch (errorCode) {
    'invalid_grant' => const InvalidCredentialsAuthFailure(),
    'email_not_verified' => const EmailNotVerifiedAuthFailure(),
    'account_locked' => const AccountLockedAuthFailure(),
    'account_disabled' => const AccountDisabledAuthFailure(),
    'registration_required' =>
      registrationRequiredFailureOf(response.data) ??
          const UnexpectedAuthFailure('registration_required'),
    _ => UnexpectedAuthFailure(errorCode ?? 'http_${response.statusCode}'),
  };
}

String? oauthErrorCodeOf(Object? body) {
  if (body is! Map) return null;
  final errorCode = body['error'];
  return errorCode is String ? errorCode : null;
}

RegistrationRequiredAuthFailure? registrationRequiredFailureOf(Object? body) {
  if (body is! Map) return null;
  final ticket = body['signup_ticket'];
  final email = body['email'];
  final name = body['name'];
  if (ticket is! String || ticket.isEmpty || email is! String) return null;
  return RegistrationRequiredAuthFailure(
    GoogleSignupTicket(
      ticket: ticket,
      email: email,
      name: name is String ? name : '',
    ),
  );
}
