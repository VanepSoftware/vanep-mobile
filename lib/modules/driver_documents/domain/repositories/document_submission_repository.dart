import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

typedef UploadProgress = void Function(int sentBytes, int totalBytes);

abstract interface class DocumentSubmissionRepository {
  Future<Result<DocumentSubmissionFailure, String>> create(DocumentDraft draft);

  Future<Result<DocumentSubmissionFailure, void>> update(
    String token,
    DocumentDraft draft,
  );

  Future<Result<DocumentSubmissionFailure, void>> uploadFile(
    String token,
    DocumentKind kind,
    PickedDocument file, {
    UploadProgress? onProgress,
  });

  Future<Result<DocumentSubmissionFailure, DocumentDraft>> findForResume(
    String token,
    DocumentKind kind,
  );

  Future<Result<DocumentSubmissionFailure, String>> downloadFile(
    String fileUrl, {
    required String fileName,
  });
}
