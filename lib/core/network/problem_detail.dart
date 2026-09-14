String readProblemDetail(Object? body) {
  if (body is! Map) return '';
  final detail = body['detail'] ?? body['message'];
  return detail is String ? detail : '';
}

String readProblemField(Object? body) {
  if (body is! Map) return '';
  final field = body['field'];
  return field is String ? field : '';
}
