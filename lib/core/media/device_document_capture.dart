import 'package:vanep_mobile/core/media/device_document_readers.dart';
import 'package:vanep_mobile/core/media/document_capture.dart';
import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/media/document_upload_limit.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';

class DeviceDocumentCapture implements DocumentCapture {
  const DeviceDocumentCapture({
    required this.scanner,
    required this.gallery,
    required this.pdfFile,
  });

  final DocumentReader scanner;
  final DocumentReader gallery;
  final DocumentReader pdfFile;

  @override
  Future<Result<DocumentCaptureFailure, PickedDocument?>> capture(
    DocumentSource source,
  ) async {
    final read = await readerFor(source).read();
    return switch (read) {
      Ok(value: final document?)
          when !isWithinDocumentUploadLimit(document.sizeBytes) =>
        const Err(DocumentCaptureFailure.tooLarge),
      _ => read,
    };
  }

  DocumentReader readerFor(DocumentSource source) {
    return switch (source) {
      DocumentSource.scanner => scanner,
      DocumentSource.gallery => gallery,
      DocumentSource.pdfFile => pdfFile,
    };
  }
}
