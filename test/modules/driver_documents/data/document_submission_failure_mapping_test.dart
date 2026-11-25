import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/document_submission_failure_mapping.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';

DioException answer(int? status, [Map<String, Object?>? body]) => DioException(
  requestOptions: RequestOptions(),
  response: status == null
      ? null
      : Response<Object?>(
          requestOptions: RequestOptions(),
          statusCode: status,
          data: body,
        ),
);

DocumentSubmissionFailure map(int? status, [Map<String, Object?>? body]) =>
    submissionFailureFrom(answer(status, body));

void main() {
  test('no answer is a network failure', () {
    expect(map(null), const NetworkSubmissionFailure());
  });

  test('the conflicts of the review rules', () {
    expect(
      map(409, {'code': 'document.submission.pending_exists'}),
      const PendingExistsFailure(),
    );
    expect(
      map(409, {'code': 'document.submission.reviewed'}),
      const AlreadyReviewedFailure(),
    );
  });

  test('the file codes of the back', () {
    expect(
      map(413, {'code': 'media.file.too_large'}),
      const FileTooLargeFailure(),
    );
    expect(
      map(400, {'code': 'media.mime.not_allowed'}),
      const UnsupportedFileFailure(),
    );
    expect(
      map(400, {'code': 'media.file.unreadable'}),
      const UnsupportedFileFailure(),
    );
  });

  test('without a code, 413 is too large and 400 a file type refused', () {
    expect(map(413), const FileTooLargeFailure());
    expect(
      map(400, {'detail': 'Este tipo de arquivo não é aceito aqui.'}),
      const UnsupportedFileFailure(),
    );
  });

  test('anything else keeps the detail of the back', () {
    expect(
      map(404, {'detail': 'Motorista não encontrado.'}),
      const UnexpectedSubmissionFailure(detail: 'Motorista não encontrado.'),
    );
    expect(map(500), const UnexpectedSubmissionFailure());
  });
}
