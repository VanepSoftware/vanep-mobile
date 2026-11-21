import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/document_submission_failure_mapping.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';

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

void main() {
  group('saving the data', () {
    DocumentSubmissionFailure map(int? status, [Map<String, Object?>? body]) =>
        dataFailureFrom(answer(status, body));

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
      expect(
        map(409, {'code': 'driver_cnh.registration.duplicate'}),
        const CnhNumberTakenFailure(),
      );
    });

    test('the date codes become field errors', () {
      expect(
        map(400, {'code': 'document.expires_at.past', 'field': 'expiresAt'}),
        const FieldRejectedFailure(
          field: DocumentField.expiresAt,
          error: DocumentFieldError.alreadyExpired,
        ),
      );
      expect(
        map(400, {
          'code': 'document.expires_at.too_far',
          'field': 'validUntil',
        }),
        const FieldRejectedFailure(
          field: DocumentField.expiresAt,
          error: DocumentFieldError.tooFar,
        ),
      );
      expect(
        map(400, {
          'code': 'driver_cnh.issue_date.future',
          'field': 'issueDate',
        }),
        const FieldRejectedFailure(
          field: DocumentField.cnhIssueDate,
          error: DocumentFieldError.inFuture,
        ),
      );
    });

    test('a validation error without a code points at its field', () {
      expect(
        map(400, {
          'detail': 'Número de registro da CNH inválido.',
          'field': 'registrationNumber',
        }),
        const FieldRejectedFailure(
          field: DocumentField.cnhRegistrationNumber,
          error: DocumentFieldError.invalidFormat,
        ),
      );
      expect(
        map(400, {'detail': 'x', 'field': 'category'}),
        const FieldRejectedFailure(
          field: DocumentField.cnhCategory,
          error: DocumentFieldError.invalidFormat,
        ),
      );
    });

    test('anything else keeps the detail of the back', () {
      expect(
        map(400, {'detail': 'Motorista não encontrado.'}),
        const UnexpectedSubmissionFailure(detail: 'Motorista não encontrado.'),
      );
      expect(map(500), const UnexpectedSubmissionFailure());
    });
  });

  group('sending the file', () {
    DocumentSubmissionFailure map(int? status, [Map<String, Object?>? body]) =>
        fileFailureFrom(answer(status, body));

    test('no answer is a network failure', () {
      expect(map(null), const NetworkSubmissionFailure());
    });

    test('413 is a file too large', () {
      expect(map(413), const FileTooLargeFailure());
    });

    test('400 is a file type the back does not take', () {
      expect(
        map(400, {'detail': 'Este tipo de arquivo não é aceito aqui.'}),
        const UnsupportedFileFailure(),
      );
    });

    test('a reviewed submission refuses the file', () {
      expect(
        map(409, {'code': 'document.submission.reviewed'}),
        const AlreadyReviewedFailure(),
      );
    });
  });
}
