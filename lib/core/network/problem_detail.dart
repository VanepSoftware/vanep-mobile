import 'package:vanep_mobile/core/network/api_problem.dart';

String readProblemDetail(Object? body) {
  return ApiProblem.fromResponseBody(body).detailText;
}

String readProblemField(Object? body) {
  return ApiProblem.fromResponseBody(body).field ?? '';
}

String readProblemCode(Object? body) {
  return ApiProblem.fromResponseBody(body).code ?? '';
}
