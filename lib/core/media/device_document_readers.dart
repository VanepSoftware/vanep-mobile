import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';

import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_file_store.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_picker.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/result/result.dart';

const int maxScannedPages = 10;

const String pdfMimeType = 'application/pdf';

typedef PdfFilePick = Future<PlatformFile?> Function(
  FileType type,
  List<String> extensions,
);

abstract class DocumentReader {
  Future<Result<DocumentCaptureFailure, PickedDocument?>> read();
}

class ScannerDocumentReader implements DocumentReader {
  ScannerDocumentReader({
    required this.store,
    CunningDocumentScannerPlatform? scanner,
  }) : scanner = scanner ?? CunningDocumentScannerPlatform.instance;

  final DocumentFileStore store;
  final CunningDocumentScannerPlatform scanner;

  @override
  Future<Result<DocumentCaptureFailure, PickedDocument?>> read() async {
    try {
      final scan = await scanner.scanDocuments(
        noOfPages: maxScannedPages,
        scannerSource: ScannerSource.camera,
        output: ScanOutput.imagesAndPdf,
        androidScannerMode: AndroidScannerMode.full,
      );
      final pdf = scan?.pdf;
      if (scan == null || pdf == null) return const Ok(null);
      final document = await keepScan(store, pdf: pdf, pages: scan.images);
      await scanner.cleanCache();
      return Ok(document);
    } on CunningDocumentScannerException catch (error) {
      return Err(scannerFailureFrom(error));
    } on FileSystemException {
      return const Err(DocumentCaptureFailure.unexpected);
    }
  }
}

Future<PickedDocument> keepScan(
  DocumentFileStore store, {
  required String pdf,
  required List<String> pages,
}) async {
  final keptPdf = await store.keep(pdf);
  final keptPages = [for (final page in pages) await store.keep(page)];
  return PickedDocument(
    path: keptPdf,
    fileName: fileNameOf(pdf),
    mimeType: pdfMimeType,
    sizeBytes: await File(keptPdf).length(),
    pageCount: pages.length,
    pagePreviewPaths: keptPages,
  );
}

DocumentCaptureFailure scannerFailureFrom(
  CunningDocumentScannerException error,
) {
  return error.code == 'permission_denied'
      ? DocumentCaptureFailure.permissionDenied
      : DocumentCaptureFailure.unexpected;
}

class GalleryDocumentReader implements DocumentReader {
  GalleryDocumentReader({required this.store, required this.photoPicker});

  final DocumentFileStore store;
  final PhotoPicker photoPicker;

  @override
  Future<Result<DocumentCaptureFailure, PickedDocument?>> read() async {
    final picked = await photoPicker.pick(PhotoSource.gallery);
    return switch (picked) {
      Err(:final error) => Err(galleryFailureFrom(error)),
      Ok(value: null) => const Ok(null),
      Ok(:final value?) => Ok(await keepPhoto(store, value)),
    };
  }
}

Future<PickedDocument> keepPhoto(
  DocumentFileStore store,
  PickedPhoto photo,
) async {
  final kept = await store.keep(photo.path);
  return PickedDocument(
    path: kept,
    fileName: photo.fileName,
    mimeType: imageMimeTypeFor(photo.fileName),
    sizeBytes: await File(kept).length(),
    pagePreviewPaths: [kept],
  );
}

DocumentCaptureFailure galleryFailureFrom(PhotoFailure failure) {
  return failure == PhotoFailure.permissionDenied
      ? DocumentCaptureFailure.permissionDenied
      : DocumentCaptureFailure.unexpected;
}

String imageMimeTypeFor(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  return switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}

class PdfFileDocumentReader implements DocumentReader {
  PdfFileDocumentReader({required this.store, PdfFilePick? pickFile})
    : pickFile = pickFile ?? pickPdfFromDevice;

  final DocumentFileStore store;
  final PdfFilePick pickFile;

  @override
  Future<Result<DocumentCaptureFailure, PickedDocument?>> read() async {
    try {
      final file = await pickFile(FileType.custom, const ['pdf']);
      if (file == null) return const Ok(null);
      return Ok(await keepPdfFile(store, file));
    } on Exception {
      return const Err(DocumentCaptureFailure.unexpected);
    }
  }
}

Future<PlatformFile?> pickPdfFromDevice(
  FileType type,
  List<String> extensions,
) {
  return FilePicker.pickFile(type: type, allowedExtensions: extensions);
}

Future<PickedDocument> keepPdfFile(
  DocumentFileStore store,
  PlatformFile file,
) async {
  final sourcePath = file.path;
  final kept = sourcePath == null
      ? await store.keepBytes(file.name, await file.readAsBytes())
      : await store.keep(sourcePath);
  return PickedDocument(
    path: kept,
    fileName: file.name,
    mimeType: pdfMimeType,
    sizeBytes: await File(kept).length(),
  );
}
