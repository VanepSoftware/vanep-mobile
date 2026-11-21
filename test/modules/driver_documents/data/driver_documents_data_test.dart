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
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_target.dart';

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

Response<T> ok<T>(T data) =>
    Response<T>(requestOptions: RequestOptions(), data: data, statusCode: 200);

void main() {
  setUpAll(() {
    registerFallbackValue(testScannedDocument);
    registerFallbackValue(DocumentKind.driverDocument);
    registerFallbackValue(
      const PersonalDocumentDraft(type: DocumentType.criminalRecord),
    );
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
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => ok({'token': 'new-1'}));
      when(() => dio.put<Map<String, dynamic>>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => ok({'token': 'doc-1'}));
      when(
        () => uploader.upload(
          any(),
          path: any(named: 'path'),
          fileName: any(named: 'fileName'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async {});
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

    test('each draft is created in its own resource', () async {
      await remote.create(
        const PersonalDocumentDraft(type: DocumentType.criminalRecord),
      );
      await remote.create(
        const VehicleDocumentDraft(
          vehicleToken: 'sprinter',
          type: DocumentType.vehicleInspection,
        ),
      );
      final token = await remote.create(
        CnhDraft(
          registrationNumber: '01234567890',
          category: 'D',
          issueDate: DateTime(2021, 8, 12),
          validUntil: DateTime(2031, 8, 12),
        ),
      );

      expect(token, 'new-1');
      verify(
        () => dio.post<Map<String, dynamic>>(
          '$base/api/driver-documents',
          data: any(named: 'data'),
        ),
      ).called(1);
      verify(
        () => dio.post<Map<String, dynamic>>(
          '$base/api/vehicles/sprinter/documents',
          data: any(named: 'data'),
        ),
      ).called(1);
      verify(
        () => dio.post<Map<String, dynamic>>(
          '$base/api/driver-cnhs',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('an update goes to the resource of the token', () async {
      await remote.update(
        'vdoc-1',
        const VehicleDocumentDraft(
          vehicleToken: 'sprinter',
          type: DocumentType.vehicleInspection,
        ),
      );

      verify(
        () => dio.put<Map<String, dynamic>>(
          '$base/api/vehicle-documents/vdoc-1',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test(
      'the file goes to the /file route of its resource, with progress',
      () async {
        void onProgress(int sent, int total) {}

        await remote.uploadFile(
          'cnh-1',
          DocumentKind.driverCnh,
          testScannedDocument,
          onProgress: onProgress,
        );

        verify(
          () => uploader.upload(
            '$base/api/driver-cnhs/cnh-1/file',
            path: testScannedDocument.path,
            fileName: testScannedDocument.fileName,
            onSendProgress: onProgress,
          ),
        ).called(1);
      },
    );

    test('reads the saved resource of a submission', () async {
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => ok({'documentType': 'CRIMINAL_RECORD'}));

      await remote.fetchResource('doc-1', DocumentKind.driverDocument);

      verify(
        () => dio.get<Map<String, dynamic>>('$base/api/driver-documents/doc-1'),
      ).called(1);
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

    test('a refused creation becomes the failure of its code', () async {
      when(() => remote.create(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response<Object?>(
            requestOptions: RequestOptions(),
            statusCode: 409,
            data: {'code': 'document.submission.pending_exists'},
          ),
        ),
      );

      final result = await repository.create(
        const PersonalDocumentDraft(type: DocumentType.criminalRecord),
      );

      expect(result.errorOrNull, const PendingExistsFailure());
    });

    test('a refused file uses the file mapping', () async {
      when(
        () => remote.uploadFile(
          any(),
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response<Object?>(
            requestOptions: RequestOptions(),
            statusCode: 413,
          ),
        ),
      );

      final result = await repository.uploadFile(
        'doc-1',
        DocumentKind.driverDocument,
        testScannedDocument,
      );

      expect(result.errorOrNull, const FileTooLargeFailure());
    });

    test('reads the saved data of a submission to finish it', () async {
      when(() => remote.fetchResource('doc-1', DocumentKind.driverDocument))
          .thenAnswer(
            (_) async => {
              'documentType': 'CRIMINAL_RECORD',
              'documentNumber': 'C-1',
            },
          );

      final result = await repository.findForResume(
        'doc-1',
        DocumentKind.driverDocument,
      );

      expect(
        result.valueOrNull,
        const PersonalDocumentDraft(
          type: DocumentType.criminalRecord,
          documentNumber: 'C-1',
        ),
      );
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
      when(() => remote.create(any())).thenAnswer((_) async => 'doc-1');
      when(
        () => remote.uploadFile(
          any(),
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async {});

      final result = await SubmitDocument(repository)(
        target: const NewSubmission(),
        draft: const PersonalDocumentDraft(type: DocumentType.criminalRecord),
        file: testScannedDocument,
      );

      expect(result.valueOrNull, 'doc-1');
    });
  });
}
