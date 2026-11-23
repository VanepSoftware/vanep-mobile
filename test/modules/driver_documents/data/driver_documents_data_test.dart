import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/file_uploader.dart';
import 'package:vanep_mobile/modules/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/document_submission_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/driver_compliance_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';

import '../../../core/media/document_capture_fixture.dart';
import '../../../core/media/media_mocks.dart';
import 'driver_documents_json_fixture.dart';

class MockDio extends Mock implements Dio {}

class MockFileUploader extends Mock implements FileUploader {}

class MockDriverDocumentsRemoteDataSource extends Mock
    implements DriverDocumentsRemoteDataSource {}

const base = 'http://10.0.2.2:8080';

const environment = Environment(
  authBaseUrl: base,
  oauthClientId: 'vanep-mobile',
);

const upload = DocumentUpload(
  type: DocumentType.criminalRecord,
  file: testScannedDocument,
);

Response<T> ok<T>(T data) =>
    Response<T>(requestOptions: RequestOptions(), data: data, statusCode: 200);

void main() {
  setUpAll(() {
    registerFallbackValue(upload);
  });

  group('remote data source', () {
    late MockDio dio;
    late MockFileUploader uploader;
    late DriverDocumentsRemoteDataSource remote;

    setUp(() {
      dio = MockDio();
      uploader = MockFileUploader();
      remote = DriverDocumentsRemoteDataSource(
        dio: dio,
        environment: environment,
        fileUploader: uploader,
      );
      when(
        () => uploader.createWithFile(
          any(),
          path: any(named: 'path'),
          fileName: any(named: 'fileName'),
          fields: any(named: 'fields'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async => {'token': 'new-1'});
    });

    test('reads the situation from the driver compliance route', () async {
      when(
        () => dio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => ok(Map<String, dynamic>.from(complianceJson)));

      await remote.fetchCompliance();

      verify(
        () => dio.get<Map<String, dynamic>>('$base/api/drivers/me/compliance'),
      ).called(1);
    });

    test('a document goes in one post with its type and its file', () async {
      void onProgress(int sent, int total) {}

      final token = await remote.send(
        const DocumentUpload(
          type: DocumentType.criminalRecord,
          file: testScannedDocument,
        ),
        onProgress: onProgress,
      );

      expect(token, 'new-1');
      verify(
        () => uploader.createWithFile(
          '$base/api/driver-documents',
          path: testScannedDocument.path,
          fileName: testScannedDocument.fileName,
          fields: {'documentType': 'CRIMINAL_RECORD'},
          onSendProgress: onProgress,
        ),
      ).called(1);
    });

    test('a van document goes to the documents of its van', () async {
      await remote.send(
        const DocumentUpload(
          type: DocumentType.vehicleRegistration,
          vehicleToken: 'sprinter',
          file: testScannedDocument,
        ),
      );

      verify(
        () => uploader.createWithFile(
          '$base/api/vehicles/sprinter/documents',
          path: any(named: 'path'),
          fileName: any(named: 'fileName'),
          fields: {'documentType': 'CRLV'},
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).called(1);
    });

    test('the CNH goes with the file only', () async {
      await remote.send(
        const DocumentUpload(
          type: DocumentType.driverLicense,
          file: testScannedDocument,
        ),
      );

      verify(
        () => uploader.createWithFile(
          '$base/api/driver-cnhs',
          path: any(named: 'path'),
          fileName: any(named: 'fileName'),
          fields: <String, String>{},
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).called(1);
    });

    test('a van document without its van is a programming error', () {
      expect(
        () => remote.send(
          const DocumentUpload(
            type: DocumentType.vehicleInspection,
            file: testScannedDocument,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('compliance repository', () {
    late MockDriverDocumentsRemoteDataSource remote;
    late DriverComplianceRepositoryImpl repository;

    setUp(() {
      remote = MockDriverDocumentsRemoteDataSource();
      repository = DriverComplianceRepositoryImpl(remote);
    });

    test('reads the situation', () async {
      when(remote.fetchCompliance).thenAnswer((_) async => complianceJson);

      final result = await repository.loadMine();

      expect(result.valueOrNull?.asOf, DateTime(2026, 11, 20));
    });

    test('no answer is a network failure', () async {
      when(remote.fetchCompliance)
          .thenThrow(DioException(requestOptions: RequestOptions()));

      expect(
        (await repository.loadMine()).errorOrNull,
        ComplianceFailure.network,
      );
    });

    test('an unreadable answer is unexpected', () async {
      when(remote.fetchCompliance).thenAnswer((_) async => {'asOf': 'today'});

      expect(
        (await repository.loadMine()).errorOrNull,
        ComplianceFailure.unexpected,
      );
    });
  });

  group('submission repository', () {
    late MockDriverDocumentsRemoteDataSource remote;
    late MockDocumentFileStore store;
    late DocumentSubmissionRepositoryImpl repository;

    setUp(() {
      remote = MockDriverDocumentsRemoteDataSource();
      store = MockDocumentFileStore();
      repository = DocumentSubmissionRepositoryImpl(remote, store);
    });

    test('a refused upload becomes the failure of its code', () async {
      when(() => remote.send(any(), onProgress: any(named: 'onProgress')))
          .thenThrow(
            DioException(
              requestOptions: RequestOptions(),
              response: Response<Object?>(
                requestOptions: RequestOptions(),
                statusCode: 409,
                data: {'code': 'document.submission.pending_exists'},
              ),
            ),
          );

      final result = await repository.send(upload);

      expect(result.errorOrNull, const PendingExistsFailure());
    });

    test('a kept file that is gone fails instead of hanging', () async {
      when(() => remote.send(any(), onProgress: any(named: 'onProgress')))
          .thenThrow(const PathNotFoundException('/tmp/gone.pdf', OSError()));

      final result = await repository.send(upload);

      expect(result.errorOrNull, const UnexpectedSubmissionFailure());
    });

    test('downloads the file next to the kept documents', () async {
      when(() => store.targetPathFor('cnh.pdf'))
          .thenAnswer((_) async => '/tmp/vanep_documents/1-cnh.pdf');
      when(() => remote.download(any(), any())).thenAnswer((_) async {});

      final result = await repository.downloadFile(
        '/api/driver-cnhs/cnh-1/file',
        fileName: 'cnh.pdf',
      );

      expect(result.valueOrNull, '/tmp/vanep_documents/1-cnh.pdf');
      verify(
        () => remote.download(
          '/api/driver-cnhs/cnh-1/file',
          '/tmp/vanep_documents/1-cnh.pdf',
        ),
      ).called(1);
    });

    test('the whole submission works through the repository', () async {
      when(() => remote.send(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => 'doc-1');

      final result = await SubmitDocument(repository)(upload);

      expect(result.valueOrNull, 'doc-1');
    });
  });
}
