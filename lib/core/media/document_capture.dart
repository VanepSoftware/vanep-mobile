import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';

abstract class DocumentCapture {
  Future<Result<DocumentCaptureFailure, PickedDocument?>> capture(
    DocumentSource source,
  );
}
