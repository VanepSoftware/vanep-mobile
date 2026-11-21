import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_target.dart';

sealed class SubmitDocumentFailure extends Equatable {
  const SubmitDocumentFailure();

  DocumentSubmissionFailure get cause;
}

final class DataNotSaved extends SubmitDocumentFailure {
  const DataNotSaved(this.cause);

  @override
  final DocumentSubmissionFailure cause;

  @override
  List<Object?> get props => [cause];
}

final class FileNotSent extends SubmitDocumentFailure {
  const FileNotSent({required this.token, required this.cause});

  final String token;
  @override
  final DocumentSubmissionFailure cause;

  @override
  List<Object?> get props => [token, cause];
}

class SubmitDocument {
  const SubmitDocument(this.repository);

  final DocumentSubmissionRepository repository;

  Future<Result<SubmitDocumentFailure, String>> call({
    required SubmissionTarget target,
    required DocumentDraft draft,
    required PickedDocument file,
    UploadProgress? onProgress,
  }) async {
    final saved = await saveData(target, draft);
    return switch (saved) {
      Err(:final error) => Err(DataNotSaved(error)),
      Ok(value: final token) => sendFile(token, draft, file, onProgress),
    };
  }

  Future<Result<DocumentSubmissionFailure, String>> saveData(
    SubmissionTarget target,
    DocumentDraft draft,
  ) async {
    return switch (target) {
      NewSubmission() => repository.create(draft),
      ExistingSubmission(:final token) => (await repository.update(
        token,
        draft,
      )).fold(Err.new, (_) => Ok(token)),
    };
  }

  Future<Result<SubmitDocumentFailure, String>> sendFile(
    String token,
    DocumentDraft draft,
    PickedDocument file,
    UploadProgress? onProgress,
  ) async {
    final sent = await repository.uploadFile(
      token,
      draft.type.kind,
      file,
      onProgress: onProgress,
    );
    return switch (sent) {
      Err(:final error) => Err(FileNotSent(token: token, cause: error)),
      Ok() => Ok(token),
    };
  }
}
