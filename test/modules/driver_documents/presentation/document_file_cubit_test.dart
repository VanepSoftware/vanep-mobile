import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/file_opener.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/download_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_file_cubit.dart';

import '../driver_documents_mocks.dart';

class MockFileOpener extends Mock implements FileOpener {}

const pdf = DocumentFile(
  mimeType: 'application/pdf',
  sizeBytes: 1200,
  originalName: 'cnh.pdf',
);

const photo = DocumentFile(mimeType: 'image/jpeg', sizeBytes: 300);

void main() {
  late MockDocumentSubmissionRepository repository;
  late MockFileOpener opener;

  setUp(() {
    repository = MockDocumentSubmissionRepository();
    opener = MockFileOpener();
  });

  DocumentFileCubit build() => DocumentFileCubit(
    downloadDocumentFile: DownloadDocumentFile(repository),
    fileOpener: opener,
  );

  blocTest<DocumentFileCubit, DocumentFileState>(
    'an image opens inside the app from its private route',
    build: build,
    act: (cubit) => cubit.open('/api/driver-documents/doc-1/file', photo),
    expect: () => const [
      DocumentFileState(imageUrl: '/api/driver-documents/doc-1/file'),
    ],
    verify: (_) => verifyNever(
      () => repository.downloadFile(any(), fileName: any(named: 'fileName')),
    ),
  );

  blocTest<DocumentFileCubit, DocumentFileState>(
    'a PDF is downloaded and opened in the system viewer',
    setUp: () {
      when(
        () => repository.downloadFile(
          '/api/driver-cnhs/cnh-1/file',
          fileName: 'cnh.pdf',
        ),
      ).thenAnswer((_) async => const Ok('/tmp/cnh.pdf'));
      when(() => opener.open('/tmp/cnh.pdf')).thenAnswer((_) async => true);
    },
    build: build,
    act: (cubit) => cubit.open('/api/driver-cnhs/cnh-1/file', pdf),
    expect: () => const [
      DocumentFileState(isOpening: true),
      DocumentFileState(),
    ],
  );

  blocTest<DocumentFileCubit, DocumentFileState>(
    'a failed download or viewer tells the driver',
    setUp: () => when(
      () => repository.downloadFile(any(), fileName: any(named: 'fileName')),
    ).thenAnswer((_) async => const Err(NetworkSubmissionFailure())),
    build: build,
    act: (cubit) => cubit.open('/api/driver-cnhs/cnh-1/file', pdf),
    expect: () => const [
      DocumentFileState(isOpening: true),
      DocumentFileState(failed: true),
    ],
  );

  blocTest<DocumentFileCubit, DocumentFileState>(
    'a PDF without a name is saved with the pdf extension',
    setUp: () {
      when(() => repository.downloadFile(any(), fileName: 'documento.pdf'))
          .thenAnswer((_) async => const Ok('/tmp/documento.pdf'));
      when(() => opener.open(any())).thenAnswer((_) async => false);
    },
    build: build,
    act: (cubit) => cubit.open(
      '/x/file',
      const DocumentFile(mimeType: 'application/pdf', sizeBytes: 1),
    ),
    expect: () => const [
      DocumentFileState(isOpening: true),
      DocumentFileState(failed: true),
    ],
  );

  blocTest<DocumentFileCubit, DocumentFileState>(
    'the page clears what it already handled',
    build: build,
    seed: () => const DocumentFileState(imageUrl: '/x', failed: true),
    act: (cubit) => cubit.clear(),
    expect: () => const [DocumentFileState()],
  );
}
