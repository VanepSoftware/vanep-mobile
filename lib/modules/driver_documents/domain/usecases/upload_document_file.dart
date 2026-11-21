import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

class UploadDocumentFile {
  const UploadDocumentFile(this.repository);

  final DocumentSubmissionRepository repository;

  Future<Result<DocumentSubmissionFailure, void>> call({
    required String token,
    required DocumentKind kind,
    required PickedDocument file,
    UploadProgress? onProgress,
  }) {
    return repository.uploadFile(token, kind, file, onProgress: onProgress);
  }
}
