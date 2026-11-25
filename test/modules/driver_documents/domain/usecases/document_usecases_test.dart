import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/download_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/load_my_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';

import '../../../../core/media/document_capture_fixture.dart';
import '../../driver_documents_fixture.dart';
import '../../driver_documents_mocks.dart';

const upload = DocumentUpload(
  type: DocumentType.criminalRecord,
  file: testScannedDocument,
);

void main() {
  late MockDocumentSubmissionRepository submissions;

  setUpAll(() => registerFallbackValue(upload));

  setUp(() => submissions = MockDocumentSubmissionRepository());

  group('LoadMyCompliance', () {
    test('passes on the situation of the back', () async {
      final repository = MockDriverComplianceRepository();
      final compliance = TestCompliance();
      when(repository.loadMine).thenAnswer((_) async => Ok(compliance));

      final result = await LoadMyCompliance(repository)();

      expect(result.valueOrNull, same(compliance));
    });

    test('passes on a failure', () async {
      final repository = MockDriverComplianceRepository();
      when(repository.loadMine)
          .thenAnswer((_) async => const Err(ComplianceFailure.network));

      final result = await LoadMyCompliance(repository)();

      expect(result.errorOrNull, ComplianceFailure.network);
    });
  });

  group('SubmitDocument', () {
    test('sends the type and the file in one go', () async {
      when(() => submissions.send(upload, onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => const Ok('doc-1'));

      final result = await SubmitDocument(submissions)(upload);

      expect(result.valueOrNull, 'doc-1');
    });

    test('passes on a refusal', () async {
      when(() => submissions.send(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => const Err(PendingExistsFailure()));

      final result = await SubmitDocument(submissions)(upload);

      expect(result.errorOrNull, const PendingExistsFailure());
    });

    test('the upload progress reaches the caller', () async {
      when(() => submissions.send(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((invocation) async {
            final onProgress =
                invocation.namedArguments[#onProgress] as UploadProgress?;
            onProgress?.call(5, 10);
            return const Ok('doc-1');
          });
      final progress = <double>[];

      await SubmitDocument(submissions)(
        upload,
        onProgress: (sent, total) => progress.add(sent / total),
      );

      expect(progress, [0.5]);
    });
  });

  test('DownloadDocumentFile returns the local copy of the file', () async {
    when(
      () => submissions.downloadFile(
        '/api/driver-cnhs/cnh-1/file',
        fileName: 'cnh.pdf',
      ),
    ).thenAnswer((_) async => const Ok('/tmp/cnh.pdf'));

    final result = await DownloadDocumentFile(submissions)(
      '/api/driver-cnhs/cnh-1/file',
      fileName: 'cnh.pdf',
    );

    expect(result.valueOrNull, '/tmp/cnh.pdf');
  });
}
