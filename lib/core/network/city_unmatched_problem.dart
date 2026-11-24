import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';

const ibgeCityUnmatchedCode = ApiErrorCodes.locationCityUnmatched;

bool isIbgeCityUnmatchedProblem(Object? body) {
  return ApiProblem.fromResponseBody(body).matchesCode(ibgeCityUnmatchedCode);
}
