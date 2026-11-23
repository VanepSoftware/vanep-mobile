import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/device_document_capture.dart';
import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/media/document_upload_limit.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';

import 'document_capture_fixture.dart';
import 'media_mocks.dart';

void main() {
  late MockDocumentReader scanner;
  late MockDocumentReader gallery;
  late MockDocumentReader pdfFile;
  late DeviceDocumentCapture capture;

  setUp(() {
    scanner = MockDocumentReader();
    gallery = MockDocumentReader();
    pdfFile = MockDocumentReader();
    capture = DeviceDocumentCapture(
      scanner: scanner,
      gallery: gallery,
      pdfFile: pdfFile,
    );
  });

  void stubRead(
    MockDocumentReader reader,
    Result<DocumentCaptureFailure, PickedDocument?> result,
  ) {
    when(reader.read).thenAnswer((_) async => result);
  }

  test('each source uses its own reader', () async {
    stubRead(scanner, const Ok(testScannedDocument));
    stubRead(gallery, const Ok(null));
    stubRead(pdfFile, const Ok(null));

    expect(
      (await capture.capture(DocumentSource.scanner)).valueOrNull,
      testScannedDocument,
    );
    await capture.capture(DocumentSource.gallery);
    await capture.capture(DocumentSource.pdfFile);

    verify(scanner.read).called(1);
    verify(gallery.read).called(1);
    verify(pdfFile.read).called(1);
  });

  test('a file above 10 MB is refused as too large', () async {
    const tooBig = PickedDocument(
      path: '/tmp/big.pdf',
      fileName: 'big.pdf',
      mimeType: 'application/pdf',
      sizeBytes: documentUploadLimitBytes + 1,
    );
    stubRead(pdfFile, const Ok(tooBig));

    final result = await capture.capture(DocumentSource.pdfFile);

    expect(result.errorOrNull, DocumentCaptureFailure.tooLarge);
  });

  test('a cancelled capture stays a cancellation', () async {
    stubRead(gallery, const Ok(null));

    final result = await capture.capture(DocumentSource.gallery);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isNull);
  });

  test('a reader failure is passed on', () async {
    stubRead(scanner, const Err(DocumentCaptureFailure.permissionDenied));

    final result = await capture.capture(DocumentSource.scanner);

    expect(result.errorOrNull, DocumentCaptureFailure.permissionDenied);
  });
}
