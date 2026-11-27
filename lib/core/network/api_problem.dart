import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

const Set<String> _standardProblemKeys = {
  'type',
  'title',
  'status',
  'detail',
  'message',
  'instance',
  'code',
  'field',
  'errors',
};

/// Um erro de campo dentro de `ProblemDetail.errors` (RFC 9457 estendido).
class ApiProblemFieldError extends Equatable {
  const ApiProblemFieldError({this.field, this.code, this.message});

  final String? field;
  final String? code;
  final String? message;

  static ApiProblemFieldError? fromDynamic(Object? raw) {
    if (raw is! Map) return null;
    return ApiProblemFieldError(
      field: _readNonEmptyString(raw['field']),
      code: _readNonEmptyString(raw['code']),
      message: _readNonEmptyString(raw['message']),
    );
  }

  @override
  List<Object?> get props => [field, code, message];
}

/// Representação unificada de respostas de erro da API (`ProblemDetail` RFC 9457
/// com `code`, `field`, `errors` e `extras`), tolerante a corpo ausente ou
/// envelopes legados de `auth`/`profile`.
class ApiProblem extends Equatable {
  const ApiProblem({
    this.status,
    this.code,
    this.detail,
    this.field,
    this.title,
    this.errors = const [],
    this.extras = const {},
  });

  final int? status;
  final String? code;
  final String? detail;
  final String? field;
  final String? title;
  final List<ApiProblemFieldError> errors;
  final Map<String, Object?> extras;

  bool get isNetworkFailure => status == null;

  String get detailText => detail ?? '';

  bool hasCode(String target) => code == target;

  bool hasErrorCode(String target) =>
      errors.any((error) => error.code == target);

  bool matchesCode(String target) => hasCode(target) || hasErrorCode(target);

  bool matchesAnyCode(Iterable<String> targets) => targets.any(matchesCode);

  DateTime? readDateTimeExtra(String key) {
    final value = extras[key];
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  factory ApiProblem.fromDioException(DioException exception) {
    final response = exception.response;
    if (response == null) return const ApiProblem();
    return ApiProblem.fromResponseBody(
      response.data,
      statusCode: response.statusCode,
    );
  }

  factory ApiProblem.fromResponseBody(Object? body, {int? statusCode}) {
    if (body is! Map) {
      return ApiProblem(status: statusCode);
    }

    final parsedStatus =
        statusCode ??
        (body['status'] is num ? (body['status'] as num).toInt() : null);
    final code = _readNonEmptyString(body['code']);
    final detail = _readString(body['detail']) ?? _readString(body['message']);
    final field = _readNonEmptyString(body['field']);
    final title = _readString(body['title']);
    final errors = _parseFieldErrors(body['errors']);
    final extras = <String, Object?>{};
    for (final entry in body.entries) {
      final key = entry.key;
      if (key is String && !_standardProblemKeys.contains(key)) {
        extras[key] = entry.value;
      }
    }

    return ApiProblem(
      status: parsedStatus,
      code: code,
      detail: detail,
      field: field,
      title: title,
      errors: errors,
      extras: extras,
    );
  }

  @override
  List<Object?> get props => [
    status,
    code,
    detail,
    field,
    title,
    errors,
    extras,
  ];
}

String? _readNonEmptyString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _readString(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return value;
}

List<ApiProblemFieldError> _parseFieldErrors(Object? raw) {
  if (raw is! List) return const [];
  final parsed = <ApiProblemFieldError>[];
  for (final item in raw) {
    final error = ApiProblemFieldError.fromDynamic(item);
    if (error != null) {
      parsed.add(error);
    }
  }
  return List.unmodifiable(parsed);
}
