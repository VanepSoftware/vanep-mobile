import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/download_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/find_submission_for_resume.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/load_my_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/upload_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_target.dart';

import '../../../../core/media/document_capture_fixture.dart';
import '../../driver_documents_fixture.dart';
import '../../driver_documents_mocks.dart';

const criminalRecordDraft = PersonalDocumentDraft(
  type: DocumentType.criminalRecord,
  documentNumber: 'CERT-2026-1',
);

void main() {
  late MockDocumentSubmissionRepository submissions;

  setUpAll(() {
    registerFallbackValue(criminalRecordDraft);
    registerFallbackValue(testScannedDocument);
    registerFallbackValue(DocumentKind.driverDocument);
  });

  setUp(() => submissions = MockDocumentSubmissionRepository());

  void stubUpload(Result<DocumentSubmissionFailure, void> result) {
    when(
      () => submissions.uploadFile(
        any(),
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => result);
  }

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
    test('a new submission creates the data and then sends the file', () async {
      when(() => submissions.create(criminalRecordDraft))
          .thenAnswer((_) async => const Ok('doc-1'));
      stubUpload(const Ok(null));

      final result = await SubmitDocument(submissions)(
        target: const NewSubmission(),
        draft: criminalRecordDraft,
        file: testScannedDocument,
      );

      expect(result.valueOrNull, 'doc-1');
      verifyInOrder([
        () => submissions.create(criminalRecordDraft),
        () => submissions.uploadFile(
          'doc-1',
          DocumentKind.driverDocument,
          testScannedDocument,
          onProgress: any(named: 'onProgress'),
        ),
      ]);
    });

    test('an existing submission is updated, never created again', () async {
      when(() => submissions.update('doc-1', criminalRecordDraft))
          .thenAnswer((_) async => const Ok(null));
      stubUpload(const Ok(null));

      final result = await SubmitDocument(submissions)(
        target: const ExistingSubmission('doc-1'),
        draft: criminalRecordDraft,
        file: testScannedDocument,
      );

      expect(result.valueOrNull, 'doc-1');
      verifyNever(() => submissions.create(any()));
    });

    test('a failure on the file keeps the token to try again', () async {
      when(() => submissions.create(criminalRecordDraft))
          .thenAnswer((_) async => const Ok('doc-1'));
      stubUpload(const Err(NetworkSubmissionFailure()));

      final result = await SubmitDocument(submissions)(
        target: const NewSubmission(),
        draft: criminalRecordDraft,
        file: testScannedDocument,
      );

      expect(
        result.errorOrNull,
        const FileNotSent(token: 'doc-1', cause: NetworkSubmissionFailure()),
      );
    });

    test('a failure on the data does not send the file', () async {
      when(() => submissions.create(criminalRecordDraft))
          .thenAnswer((_) async => const Err(PendingExistsFailure()));

      final result = await SubmitDocument(submissions)(
        target: const NewSubmission(),
        draft: criminalRecordDraft,
        file: testScannedDocument,
      );

      expect(result.errorOrNull, const DataNotSaved(PendingExistsFailure()));
      verifyNever(
        () => submissions.uploadFile(
          any(),
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      );
    });

    test('the upload progress reaches the caller', () async {
      when(() => submissions.create(criminalRecordDraft))
          .thenAnswer((_) async => const Ok('doc-1'));
      when(
        () => submissions.uploadFile(
          any(),
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onProgress =
            invocation.namedArguments[#onProgress] as UploadProgress?;
        onProgress?.call(5, 10);
        return const Ok(null);
      });
      final progress = <double>[];

      await SubmitDocument(submissions)(
        target: const NewSubmission(),
        draft: criminalRecordDraft,
        file: testScannedDocument,
        onProgress: (sent, total) => progress.add(sent / total),
      );

      expect(progress, [0.5]);
    });
  });

  test('UploadDocumentFile sends only the file of the given token', () async {
    stubUpload(const Ok(null));

    final result = await UploadDocumentFile(submissions)(
      token: 'doc-1',
      kind: DocumentKind.vehicleDocument,
      file: testScannedDocument,
    );

    expect(result.isOk, isTrue);
    verify(
      () => submissions.uploadFile(
        'doc-1',
        DocumentKind.vehicleDocument,
        testScannedDocument,
        onProgress: any(named: 'onProgress'),
      ),
    ).called(1);
  });

  test(
    'FindSubmissionForResume reads the saved data of the submission',
    () async {
      const saved = VehicleDocumentDraft(
        vehicleToken: 'sprinter',
        type: DocumentType.vehicleInspection,
        expiresAt: null,
      );
      when(
        () => submissions.findForResume('doc-1', DocumentKind.vehicleDocument),
      ).thenAnswer((_) async => const Ok(saved));

      final result = await FindSubmissionForResume(submissions)(
        token: 'doc-1',
        kind: DocumentKind.vehicleDocument,
      );

      expect(result.valueOrNull, saved);
    },
  );

  test('DownloadDocumentFile returns the local copy of the file', () async {
    when(() => submissions.downloadFile('/api/driver-cnhs/cnh-1/file'))
        .thenAnswer((_) async => const Ok('/tmp/cnh.pdf'));

    final result = await DownloadDocumentFile(submissions)(
      '/api/driver-cnhs/cnh-1/file',
    );

    expect(result.valueOrNull, '/tmp/cnh.pdf');
  });
}
