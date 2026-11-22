import 'dart:io';

import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/media/document_file_store.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/document_submission_failure_mapping.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';

class DocumentSubmissionRepositoryImpl implements DocumentSubmissionRepository {
  const DocumentSubmissionRepositoryImpl(this.remote, this.fileStore);

  final DriverDocumentsRemoteDataSource remote;
  final DocumentFileStore fileStore;

  @override
  Future<Result<DocumentSubmissionFailure, String>> send(
    DocumentUpload upload, {
    UploadProgress? onProgress,
  }) => guardSubmission(() => remote.send(upload, onProgress: onProgress));

  @override
  Future<Result<DocumentSubmissionFailure, String>> downloadFile(
    String fileUrl, {
    required String fileName,
  }) => guardSubmission(() async {
    final savePath = await fileStore.targetPathFor(fileName);
    await remote.download(fileUrl, savePath);
    return savePath;
  });
}

Future<Result<DocumentSubmissionFailure, T>> guardSubmission<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (error) {
    return Err(submissionFailureFrom(error));
  } on FormatException {
    return const Err(UnexpectedSubmissionFailure());
  } on FileSystemException {
    return const Err(UnexpectedSubmissionFailure());
  }
}
