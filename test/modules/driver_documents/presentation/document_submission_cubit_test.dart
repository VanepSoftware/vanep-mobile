import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/find_submission_for_resume.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/upload_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_target.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';

import '../../../core/media/document_capture_fixture.dart';
import '../../../core/media/media_mocks.dart';
import '../driver_documents_mocks.dart';

const draft = PersonalDocumentDraft(
  type: DocumentType.criminalRecord,
  documentNumber: 'CERT-1',
);

const photo = PickedDocument(
  path: '/tmp/vanep_documents/1-cnh.jpg',
  fileName: 'cnh.jpg',
  mimeType: 'image/jpeg',
  sizeBytes: 300000,
  pagePreviewPaths: ['/tmp/vanep_documents/1-cnh.jpg'],
);

const start = DocumentSubmissionState(type: DocumentType.criminalRecord);

void main() {
  late MockDocumentCapture capture;
  late MockDocumentSubmissionRepository submissions;

  setUpAll(() {
    registerFallbackValue(DocumentSource.scanner);
    registerFallbackValue(draft);
    registerFallbackValue(testScannedDocument);
    registerFallbackValue(DocumentKind.driverDocument);
  });

  setUp(() {
    capture = MockDocumentCapture();
    submissions = MockDocumentSubmissionRepository();
  });

  DocumentSubmissionCubit build() => DocumentSubmissionCubit(
    type: DocumentType.criminalRecord,
    documentCapture: capture,
    submitDocument: SubmitDocument(submissions),
    uploadDocumentFile: UploadDocumentFile(submissions),
    findSubmissionForResume: FindSubmissionForResume(submissions),
  );

  void stubCreate(Result<DocumentSubmissionFailure, String> result) {
    when(() => submissions.create(any())).thenAnswer((_) async => result);
  }

  void stubUpload(Result<DocumentSubmissionFailure, void> result) {
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
      onProgress?.call(500, 1000);
      return result;
    });
  }

  group('capture', () {
    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a scan goes to the check of the pages',
      setUp: () =>
          when(() => capture.capture(DocumentSource.scanner))
              .thenAnswer((_) async => const Ok(testScannedDocument)),
      build: build,
      act: (cubit) => cubit.capture(DocumentSource.scanner),
      expect: () => [
        start.copyWith(isCapturing: true),
        start.copyWith(
          step: SubmissionStep.reviewingScan,
          file: testScannedDocument,
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a gallery photo goes straight to the data',
      setUp: () =>
          when(() => capture.capture(DocumentSource.gallery))
              .thenAnswer((_) async => const Ok(photo)),
      build: build,
      act: (cubit) => cubit.capture(DocumentSource.gallery),
      expect: () => [
        start.copyWith(isCapturing: true),
        start.copyWith(step: SubmissionStep.fillingData, file: photo),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a cancelled capture stays on the choice, without error',
      setUp: () =>
          when(() => capture.capture(any()))
              .thenAnswer((_) async => const Ok(null)),
      build: build,
      act: (cubit) => cubit.capture(DocumentSource.pdfFile),
      expect: () => [start.copyWith(isCapturing: true), start],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a file too large is told on the choice',
      setUp: () => when(() => capture.capture(any()))
          .thenAnswer((_) async => const Err(DocumentCaptureFailure.tooLarge)),
      build: build,
      act: (cubit) => cubit.capture(DocumentSource.pdfFile),
      expect: () => [
        start.copyWith(isCapturing: true),
        start.copyWith(captureFailure: DocumentCaptureFailure.tooLarge),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'continue leaves the check of the pages for the data',
      build: build,
      seed: () => start.copyWith(
        step: SubmissionStep.reviewingScan,
        file: testScannedDocument,
      ),
      act: (cubit) => cubit.continueToData(),
      expect: () => [
        start.copyWith(
          step: SubmissionStep.fillingData,
          file: testScannedDocument,
        ),
      ],
    );
  });

  group('submit', () {
    final ready = start.copyWith(
      step: SubmissionStep.fillingData,
      file: testScannedDocument,
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'data and file accepted end as sent, with the progress on the way',
      setUp: () {
        stubCreate(const Ok('doc-1'));
        stubUpload(const Ok(null));
      },
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(draft),
      expect: () => [
        ready.copyWith(step: SubmissionStep.sending, draft: draft),
        ready.copyWith(
          step: SubmissionStep.sending,
          draft: draft,
          sentBytes: 500,
          totalBytes: 1000,
        ),
        ready.copyWith(
          step: SubmissionStep.sent,
          draft: draft,
          target: const ExistingSubmission('doc-1'),
          sentBytes: 500,
          totalBytes: 1000,
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a failed file keeps the saved document to try again',
      setUp: () {
        stubCreate(const Ok('doc-1'));
        stubUpload(const Err(NetworkSubmissionFailure()));
      },
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(draft),
      skip: 2,
      expect: () => [
        ready.copyWith(
          step: SubmissionStep.failed,
          draft: draft,
          target: const ExistingSubmission('doc-1'),
          failure: const NetworkSubmissionFailure(),
          sentBytes: 500,
          totalBytes: 1000,
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'try again after a failed file sends only the file',
      setUp: () => stubUpload(const Ok(null)),
      build: build,
      seed: () => ready.copyWith(
        step: SubmissionStep.failed,
        draft: draft,
        target: const ExistingSubmission('doc-1'),
        failure: const NetworkSubmissionFailure(),
      ),
      act: (cubit) => cubit.retry(),
      verify: (cubit) {
        expect(cubit.state.step, SubmissionStep.sent);
        verifyNever(() => submissions.create(any()));
        verifyNever(() => submissions.update(any(), any()));
        verify(
          () => submissions.uploadFile(
            'doc-1',
            DocumentKind.driverDocument,
            testScannedDocument,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'no network on the data offers to try the whole submission again',
      setUp: () => stubCreate(const Err(NetworkSubmissionFailure())),
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(draft),
      skip: 1,
      expect: () => [
        ready.copyWith(
          step: SubmissionStep.failed,
          draft: draft,
          failure: const NetworkSubmissionFailure(),
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a field refused by the back goes back to the data with the error',
      setUp: () => stubCreate(
        const Err(
          FieldRejectedFailure(
            field: DocumentField.expiresAt,
            error: DocumentFieldError.tooFar,
          ),
        ),
      ),
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(draft),
      skip: 1,
      expect: () => [
        ready.copyWith(
          draft: draft,
          failure: const FieldRejectedFailure(
            field: DocumentField.expiresAt,
            error: DocumentFieldError.tooFar,
          ),
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a submission already in progress leaves the flow',
      setUp: () => stubCreate(const Err(PendingExistsFailure())),
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(draft),
      skip: 1,
      expect: () => [
        ready.copyWith(
          draft: draft,
          failure: const PendingExistsFailure(),
          leaveFlow: true,
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'review data keeps the saved document as the target',
      build: build,
      seed: () => ready.copyWith(
        step: SubmissionStep.failed,
        target: const ExistingSubmission('doc-1'),
        failure: const NetworkSubmissionFailure(),
      ),
      act: (cubit) => cubit.reviewData(),
      expect: () => [ready.copyWith(target: const ExistingSubmission('doc-1'))],
    );
  });

  blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
    'finishing an incomplete upload loads its saved data',
    setUp: () => when(
      () => submissions.findForResume('doc-9', DocumentKind.driverDocument),
    ).thenAnswer((_) async => const Ok(draft)),
    build: build,
    act: (cubit) => cubit.resume('doc-9'),
    expect: () => [
      start.copyWith(
        isLoadingResume: true,
        target: const ExistingSubmission('doc-9'),
      ),
      start.copyWith(draft: draft, target: const ExistingSubmission('doc-9')),
    ],
  );

  blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
    'the page clears what it already showed',
    build: build,
    seed: () => start.copyWith(
      captureFailure: DocumentCaptureFailure.tooLarge,
      failure: const PendingExistsFailure(),
      leaveFlow: true,
    ),
    act: (cubit) => cubit.clearMessages(),
    expect: () => [start],
  );
}
