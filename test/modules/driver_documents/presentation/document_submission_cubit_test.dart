import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';

import '../../../core/media/document_capture_fixture.dart';
import '../../../core/media/media_mocks.dart';
import '../driver_documents_mocks.dart';

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
    registerFallbackValue(
      const DocumentUpload(
        type: DocumentType.criminalRecord,
        file: testScannedDocument,
      ),
    );
  });

  setUp(() {
    capture = MockDocumentCapture();
    submissions = MockDocumentSubmissionRepository();
  });

  DocumentSubmissionCubit build({String? vehicleToken}) =>
      DocumentSubmissionCubit(
        type: vehicleToken == null
            ? DocumentType.criminalRecord
            : DocumentType.vehicleInspection,
        vehicleToken: vehicleToken,
        documentCapture: capture,
        submitDocument: SubmitDocument(submissions),
      );

  void stubSend(Result<DocumentSubmissionFailure, String> result) {
    when(() => submissions.send(any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[#onProgress] as UploadProgress?;
          onProgress?.call(500, 1000);
          return result;
        });
  }

  group('capture', () {
    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a scan goes straight to the review of the file',
      setUp: () =>
          when(() => capture.capture(DocumentSource.scanner))
              .thenAnswer((_) async => const Ok(testScannedDocument)),
      build: build,
      act: (cubit) => cubit.capture(DocumentSource.scanner),
      expect: () => [
        start.copyWith(isCapturing: true),
        start.copyWith(
          step: SubmissionStep.confirming,
          file: testScannedDocument,
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a gallery photo goes straight to the confirmation',
      setUp: () =>
          when(() => capture.capture(DocumentSource.gallery))
              .thenAnswer((_) async => const Ok(photo)),
      build: build,
      act: (cubit) => cubit.capture(DocumentSource.gallery),
      expect: () => [
        start.copyWith(isCapturing: true),
        start.copyWith(step: SubmissionStep.confirming, file: photo),
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
  });

  group('submit', () {
    final ready = start.copyWith(
      step: SubmissionStep.confirming,
      file: testScannedDocument,
    );
    final sending = ready.copyWith(step: SubmissionStep.sending);
    final halfway = sending.copyWith(sentBytes: 500, totalBytes: 1000);

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'an accepted file ends as sent, with the progress on the way',
      setUp: () => stubSend(const Ok('doc-1')),
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(),
      expect: () => [
        sending,
        halfway,
        halfway.copyWith(step: SubmissionStep.sent),
      ],
      verify: (_) => verify(
        () => submissions.send(
          const DocumentUpload(
            type: DocumentType.criminalRecord,
            file: testScannedDocument,
          ),
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1),
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a new attempt starts the progress from zero',
      setUp: () => stubSend(const Ok('doc-1')),
      build: build,
      seed: () => halfway.copyWith(
        step: SubmissionStep.failed,
        failure: const NetworkSubmissionFailure(),
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        sending,
        halfway,
        halfway.copyWith(step: SubmissionStep.sent),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a van document goes with its van',
      setUp: () => stubSend(const Ok('vdoc-1')),
      build: () => build(vehicleToken: 'sprinter'),
      seed: () => const DocumentSubmissionState(
        type: DocumentType.vehicleInspection,
        vehicleToken: 'sprinter',
        step: SubmissionStep.confirming,
        file: testScannedDocument,
      ),
      act: (cubit) => cubit.submit(),
      verify: (_) => verify(
        () => submissions.send(
          const DocumentUpload(
            type: DocumentType.vehicleInspection,
            vehicleToken: 'sprinter',
            file: testScannedDocument,
          ),
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1),
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'no network offers to try again',
      setUp: () => stubSend(const Err(NetworkSubmissionFailure())),
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(),
      expect: () => [
        sending,
        halfway,
        halfway.copyWith(
          step: SubmissionStep.failed,
          failure: const NetworkSubmissionFailure(),
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'try again sends the same file once more',
      setUp: () => stubSend(const Ok('doc-1')),
      build: build,
      seed: () => ready.copyWith(
        step: SubmissionStep.failed,
        failure: const NetworkSubmissionFailure(),
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        sending,
        halfway,
        halfway.copyWith(step: SubmissionStep.sent),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a file the back refuses goes back to the confirmation with the error',
      setUp: () => stubSend(const Err(UnsupportedFileFailure())),
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(),
      expect: () => [
        sending,
        halfway,
        halfway.copyWith(
          step: SubmissionStep.confirming,
          failure: const UnsupportedFileFailure(),
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a submission already in progress leaves the flow',
      setUp: () => stubSend(const Err(PendingExistsFailure())),
      build: build,
      seed: () => ready,
      act: (cubit) => cubit.submit(),
      expect: () => [
        sending,
        halfway,
        halfway.copyWith(
          step: SubmissionStep.confirming,
          failure: const PendingExistsFailure(),
          leaveFlow: true,
        ),
      ],
    );

    blocTest<DocumentSubmissionCubit, DocumentSubmissionState>(
      'a new file after a failure clears the error',
      setUp: () =>
          when(() => capture.capture(DocumentSource.gallery))
              .thenAnswer((_) async => const Ok(photo)),
      build: build,
      seed: () => ready.copyWith(
        step: SubmissionStep.failed,
        failure: const NetworkSubmissionFailure(),
      ),
      act: (cubit) => cubit.capture(DocumentSource.gallery),
      expect: () => [
        ready.copyWith(
          step: SubmissionStep.failed,
          failure: const NetworkSubmissionFailure(),
          isCapturing: true,
        ),
        ready.copyWith(file: photo),
      ],
    );
  });

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
