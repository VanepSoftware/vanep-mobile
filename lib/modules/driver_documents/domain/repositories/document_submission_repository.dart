import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';

typedef UploadProgress = void Function(int sentBytes, int totalBytes);

abstract interface class DocumentSubmissionRepository {
  Future<Result<DocumentSubmissionFailure, String>> send(
    DocumentUpload upload, {
    UploadProgress? onProgress,
  });

  Future<Result<DocumentSubmissionFailure, String>> downloadFile(
    String fileUrl,
  );
}
