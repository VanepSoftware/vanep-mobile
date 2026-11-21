import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/network/file_uploader.dart';
import 'package:vanep_mobile/modules/driver_documents/data/dtos/document_request_bodies.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

class DriverDocumentsRemoteDataSource {
  const DriverDocumentsRemoteDataSource({
    required this.dio,
    required this.environment,
    required this.fileUploader,
  });

  final Dio dio;
  final Environment environment;
  final FileUploader fileUploader;

  Future<Map<String, Object?>> fetchCompliance() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driverComplianceEndpoint,
    );
    return response.data ?? const {};
  }

  Future<String> create(DocumentDraft draft) async {
    final response = await dio.post<Map<String, dynamic>>(
      creationEndpointFor(draft),
      data: documentRequestBody(draft),
    );
    return readToken(response.data?['token']);
  }

  Future<void> update(String token, DocumentDraft draft) async {
    await dio.put<Map<String, dynamic>>(
      resourceEndpointFor(draft.type.kind, token),
      data: documentRequestBody(draft),
    );
  }

  Future<void> uploadFile(
    String token,
    DocumentKind kind,
    PickedDocument file, {
    UploadProgress? onProgress,
  }) {
    return fileUploader.upload(
      '${resourceEndpointFor(kind, token)}/file',
      path: file.path,
      fileName: file.fileName,
      onSendProgress: onProgress,
    );
  }

  Future<Map<String, Object?>> fetchResource(
    String token,
    DocumentKind kind,
  ) async {
    final response = await dio.get<Map<String, dynamic>>(
      resourceEndpointFor(kind, token),
    );
    return response.data ?? const {};
  }

  Future<void> download(String fileUrl, String savePath) async {
    await dio.download(fileUrl, savePath);
  }

  String creationEndpointFor(DocumentDraft draft) {
    return switch (draft) {
      PersonalDocumentDraft() => environment.driverDocumentsEndpoint,
      VehicleDocumentDraft(:final vehicleToken) =>
        environment.vehicleDocumentsEndpoint(vehicleToken),
      CnhDraft() => environment.driverCnhsEndpoint,
    };
  }

  String resourceEndpointFor(DocumentKind kind, String token) {
    return switch (kind) {
      DocumentKind.driverDocument => environment.driverDocumentEndpoint(token),
      DocumentKind.vehicleDocument => environment.vehicleDocumentEndpoint(
        token,
      ),
      DocumentKind.driverCnh => environment.driverCnhEndpoint(token),
    };
  }
}
