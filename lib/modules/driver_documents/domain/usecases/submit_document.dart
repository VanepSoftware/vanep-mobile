import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';

class SubmitDocument {
  const SubmitDocument(this.repository);

  final DocumentSubmissionRepository repository;

  Future<Result<DocumentSubmissionFailure, String>> call(
    DocumentUpload upload, {
    UploadProgress? onProgress,
  }) {
    return repository.send(upload, onProgress: onProgress);
  }
}
