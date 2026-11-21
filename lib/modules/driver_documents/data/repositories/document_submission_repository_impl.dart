import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/media/document_file_store.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_documents/data/dtos/document_request_bodies.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/document_submission_failure_mapping.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

class DocumentSubmissionRepositoryImpl implements DocumentSubmissionRepository {
  const DocumentSubmissionRepositoryImpl(this.remote, this.fileStore);

  final DriverDocumentsRemoteDataSource remote;
  final DocumentFileStore fileStore;

  @override
  Future<Result<DocumentSubmissionFailure, String>> create(
    DocumentDraft draft,
  ) => guardData(() => remote.create(draft));

  @override
  Future<Result<DocumentSubmissionFailure, void>> update(
    String token,
    DocumentDraft draft,
  ) => guardData(() => remote.update(token, draft));

  @override
  Future<Result<DocumentSubmissionFailure, void>> uploadFile(
    String token,
    DocumentKind kind,
    PickedDocument file, {
    UploadProgress? onProgress,
  }) async {
    try {
      await remote.uploadFile(token, kind, file, onProgress: onProgress);
      return const Ok(null);
    } on DioException catch (error) {
      return Err(fileFailureFrom(error));
    }
  }

  @override
  Future<Result<DocumentSubmissionFailure, DocumentDraft>> findForResume(
    String token,
    DocumentKind kind,
  ) => guardData(
    () async =>
        draftFromResource(kind, await remote.fetchResource(token, kind)),
  );

  @override
  Future<Result<DocumentSubmissionFailure, String>> downloadFile(
    String fileUrl, {
    required String fileName,
  }) => guardData(() async {
    final savePath = await fileStore.targetPathFor(fileName);
    await remote.download(fileUrl, savePath);
    return savePath;
  });
}

Future<Result<DocumentSubmissionFailure, T>> guardData<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (error) {
    return Err(dataFailureFrom(error));
  } on FormatException {
    return const Err(UnexpectedSubmissionFailure());
  }
}
