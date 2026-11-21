import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

class FindSubmissionForResume {
  const FindSubmissionForResume(this.repository);

  final DocumentSubmissionRepository repository;

  Future<Result<DocumentSubmissionFailure, DocumentDraft>> call({
    required String token,
    required DocumentKind kind,
  }) {
    return repository.findForResume(token, kind);
  }
}
