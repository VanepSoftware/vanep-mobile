import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/problem_detail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

NegotiationFailure negotiationFailureFrom(DioException exception) {
  final status = exception.response?.statusCode;
  final detail = readProblemDetail(exception.response?.data);
  return switch (status) {
    null => const NegotiationNetworkFailure(),
    404 => const NegotiationNotFoundFailure(),
    409 => NegotiationConflictFailure(detail: detail),
    422 => NegotiationRejectedFailure(detail: detail),
    400 => const NegotiationInvalidFailure(),
    _ => const NegotiationUnexpectedFailure(),
  };
}

Future<Result<NegotiationFailure, T>> guardNegotiationCall<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(negotiationFailureFrom(exception));
  } on FormatException {
    return const Err(NegotiationUnexpectedFailure());
  }
}
