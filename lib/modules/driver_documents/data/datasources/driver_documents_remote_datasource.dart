import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/file_uploader.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';

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

  Future<String> send(
    DocumentUpload upload, {
    UploadProgress? onProgress,
  }) async {
    final documentType = upload.type.documentApiName;
    final created = await fileUploader.createWithFile(
      creationEndpointFor(upload),
      path: upload.file.path,
      fileName: upload.file.fileName,
      fields: {'documentType': ?documentType},
      onSendProgress: onProgress,
    );
    return readToken(created['token']);
  }

  Future<void> download(String fileUrl, String savePath) async {
    await dio.download(fileUrl, savePath);
  }

  String creationEndpointFor(DocumentUpload upload) {
    return switch ((upload.type.kind, upload.vehicleToken)) {
      (DocumentKind.driverDocument, _) => environment.driverDocumentsEndpoint,
      (DocumentKind.driverCnh, _) => environment.driverCnhsEndpoint,
      (DocumentKind.vehicleDocument, final String vehicleToken) =>
        environment.vehicleDocumentsEndpoint(vehicleToken),
      (DocumentKind.vehicleDocument, null) => throw ArgumentError.value(
        upload.vehicleToken,
        'vehicleToken',
        'A van document needs its van',
      ),
    };
  }
}
