import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/device_document_readers.dart';
import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_file_store.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/result/result.dart';

import 'document_capture_fixture.dart';
import 'media_mocks.dart';

void main() {
  late Directory base;
  late DocumentFileStore store;
  var tick = 0;

  setUpAll(() {
    registerFallbackValue(ScannerSource.camera);
    registerFallbackValue(ScanOutput.imagesAndPdf);
    registerFallbackValue(AndroidScannerMode.full);
    registerFallbackValue(PhotoSource.gallery);
  });

  setUp(() async {
    base = await createTestDirectory();
    tick = 0;
    store = DocumentFileStore(
      baseDirectory: () async => base,
      clock: () => DateTime.fromMicrosecondsSinceEpoch(++tick),
    );
  });

  tearDown(() => base.delete(recursive: true));

  group('scanner', () {
    late MockCunningDocumentScannerPlatform scanner;
    late ScannerDocumentReader reader;

    setUp(() {
      scanner = MockCunningDocumentScannerPlatform();
      reader = ScannerDocumentReader(store: store, scanner: scanner);
      when(scanner.cleanCache).thenAnswer((_) async {});
    });

    void stubScan(Future<ScanResult?> Function() answer) {
      when(
        () => scanner.scanDocuments(
          noOfPages: any(named: 'noOfPages'),
          scannerSource: any(named: 'scannerSource'),
          output: any(named: 'output'),
          androidScannerMode: any(named: 'androidScannerMode'),
          iosScannerOptions: any(named: 'iosScannerOptions'),
        ),
      ).thenAnswer((_) => answer());
    }

    test('asks the camera for the pages and a PDF', () async {
      stubScan(() async => null);

      await reader.read();

      verify(
        () => scanner.scanDocuments(
          noOfPages: maxScannedPages,
          scannerSource: ScannerSource.camera,
          output: ScanOutput.imagesAndPdf,
          androidScannerMode: AndroidScannerMode.full,
        ),
      ).called(1);
    });

    test(
      'keeps the PDF and the page previews out of the plugin cache',
      () async {
        final pdf = writeTestFile(base, 'scan.pdf', sizeBytes: 20);
        final page1 = writeTestFile(base, 'page-1.jpg');
        final page2 = writeTestFile(base, 'page-2.jpg');
        stubScan(
          () async =>
              ScanResult(images: [page1.path, page2.path], pdf: pdf.path),
        );

        final document = (await reader.read()).valueOrNull!;
        pdf.deleteSync();

        expect(document.mimeType, 'application/pdf');
        expect(document.sizeBytes, 20);
        expect(document.pageCount, 2);
        expect(document.fileName, 'scan.pdf');
        expect(File(document.path).existsSync(), isTrue);
        expect(document.pagePreviewPaths, hasLength(2));
        expect(
          document.pagePreviewPaths.every(
            (preview) => preview.startsWith('${base.path}/vanep_documents/'),
          ),
          isTrue,
        );
        verify(scanner.cleanCache).called(1);
      },
    );

    test('a cancelled scan picks nothing', () async {
      stubScan(() async => null);

      final result = await reader.read();

      expect(result, const Ok<DocumentCaptureFailure, PickedDocument?>(null));
    });

    test('a denied camera is a permission failure', () async {
      stubScan(
        () async =>
            throw const CunningDocumentScannerException.permissionDenied(),
      );

      final result = await reader.read();

      expect(result.errorOrNull, DocumentCaptureFailure.permissionDenied);
    });

    test('any other scanner error is unexpected', () async {
      stubScan(
        () async => throw const CunningDocumentScannerException(
          'boom',
          code: 'scan_failed',
        ),
      );

      final result = await reader.read();

      expect(result.errorOrNull, DocumentCaptureFailure.unexpected);
    });
  });

  group('gallery', () {
    late MockPhotoPicker photoPicker;
    late GalleryDocumentReader reader;

    setUp(() {
      photoPicker = MockPhotoPicker();
      reader = GalleryDocumentReader(store: store, photoPicker: photoPicker);
    });

    test('keeps the chosen photo as a JPEG document', () async {
      final photo = writeTestFile(base, 'cnh.jpg', sizeBytes: 30);
      when(() => photoPicker.pick(PhotoSource.gallery)).thenAnswer(
        (_) async => Ok(PickedPhoto(path: photo.path, fileName: 'cnh.jpg')),
      );

      final document = (await reader.read()).valueOrNull!;

      expect(document.fileName, 'cnh.jpg');
      expect(document.mimeType, 'image/jpeg');
      expect(document.sizeBytes, 30);
      expect(document.pageCount, isNull);
      expect(document.pagePreviewPaths, [document.path]);
      expect(document.path, startsWith('${base.path}/vanep_documents/'));
    });

    test('a PNG keeps its own type', () async {
      final photo = writeTestFile(base, 'print.png');
      when(() => photoPicker.pick(PhotoSource.gallery)).thenAnswer(
        (_) async => Ok(PickedPhoto(path: photo.path, fileName: 'print.png')),
      );

      final document = (await reader.read()).valueOrNull!;

      expect(document.mimeType, 'image/png');
    });

    test('a cancelled gallery picks nothing', () async {
      when(() => photoPicker.pick(PhotoSource.gallery))
          .thenAnswer((_) async => const Ok(null));

      final result = await reader.read();

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('a denied gallery is a permission failure', () async {
      when(() => photoPicker.pick(PhotoSource.gallery))
          .thenAnswer((_) async => const Err(PhotoFailure.permissionDenied));

      final result = await reader.read();

      expect(result.errorOrNull, DocumentCaptureFailure.permissionDenied);
    });
  });

  group('PDF file', () {
    test('asks only for PDFs and keeps the chosen file', () async {
      final pdf = writeTestFile(base, 'crlv.pdf', sizeBytes: 50);
      FileType? requestedType;
      List<String>? requestedExtensions;
      final reader = PdfFileDocumentReader(
        store: store,
        pickFile: (type, extensions) async {
          requestedType = type;
          requestedExtensions = extensions;
          return FakePlatformFile(name: 'crlv.pdf', filePath: pdf.path);
        },
      );

      final document = (await reader.read()).valueOrNull!;

      expect(requestedType, FileType.custom);
      expect(requestedExtensions, ['pdf']);
      expect(document.fileName, 'crlv.pdf');
      expect(document.mimeType, 'application/pdf');
      expect(document.sizeBytes, 50);
      expect(document.pagePreviewPaths, isEmpty);
      expect(document.path, startsWith('${base.path}/vanep_documents/'));
    });

    test('a file without a path is kept from its bytes', () async {
      final reader = PdfFileDocumentReader(
        store: store,
        pickFile: (_, _) async => FakePlatformFile(
          name: 'cnh.pdf',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      );

      final document = (await reader.read()).valueOrNull!;

      expect(File(document.path).readAsBytesSync(), [1, 2, 3]);
      expect(document.sizeBytes, 3);
    });

    test('a cancelled picker picks nothing', () async {
      final reader = PdfFileDocumentReader(
        store: store,
        pickFile: (_, _) async => null,
      );

      final result = await reader.read();

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('a picker error is unexpected', () async {
      final reader = PdfFileDocumentReader(
        store: store,
        pickFile: (_, _) async => throw PlatformException(code: 'boom'),
      );

      final result = await reader.read();

      expect(result.errorOrNull, DocumentCaptureFailure.unexpected);
    });
  });
}
