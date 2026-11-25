import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';

class DownloadDocumentFile {
  const DownloadDocumentFile(this.repository);

  final DocumentSubmissionRepository repository;

  Future<Result<DocumentSubmissionFailure, String>> call(
    String fileUrl, {
    required String fileName,
  }) => repository.downloadFile(fileUrl, fileName: fileName);
}
