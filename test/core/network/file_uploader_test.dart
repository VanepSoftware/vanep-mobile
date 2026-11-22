import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/network/file_uploader.dart';

class MockDio extends Mock implements Dio {}

DioException statusError(int? status) => DioException(
  requestOptions: RequestOptions(),
  response: status == null
      ? null
      : Response<void>(requestOptions: RequestOptions(), statusCode: status),
);

void main() {
  late MockDio dio;
  late Directory directory;
  late File file;

  setUp(() async {
    dio = MockDio();
    directory = await Directory.systemTemp.createTemp('vanep');
    file = File('${directory.path}/van.jpg')..writeAsBytesSync([1, 2]);
    when(
      () => dio.post<void>(
        any(),
        data: any(named: 'data'),
        onSendProgress: any(named: 'onSendProgress'),
      ),
    ).thenAnswer((_) async => Response(requestOptions: RequestOptions()));
  });

  tearDown(() => directory.delete(recursive: true));

  test('posts the file as the "file" part of a multipart form', () async {
    await FileUploader(dio: dio).upload(
      '/api/vehicles/van-1/photo-front',
      path: file.path,
      fileName: 'van.jpg',
    );

    final form =
        verify(
              () => dio.post<void>(
                '/api/vehicles/van-1/photo-front',
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'van.jpg');
  });

  test('reports the upload progress to the caller', () async {
    void onProgress(int sent, int total) {}

    await FileUploader(dio: dio).upload(
      '/api/driver-documents/doc-1/file',
      path: file.path,
      fileName: 'scan.pdf',
      onSendProgress: onProgress,
    );

    verify(
      () => dio.post<void>(
        '/api/driver-documents/doc-1/file',
        data: any(named: 'data'),
        onSendProgress: onProgress,
      ),
    ).called(1);
  });

  test('creates a resource with its fields and the file in one form', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        onSendProgress: any(named: 'onSendProgress'),
      ),
    ).thenAnswer(
      (_) async =>
          Response(requestOptions: RequestOptions(), data: {'token': 'doc-1'}),
    );

    final created = await FileUploader(dio: dio).createWithFile(
      '/api/driver-documents',
      path: file.path,
      fileName: 'scan.pdf',
      fields: {'documentType': 'CRIMINAL_RECORD'},
    );

    expect(created, {'token': 'doc-1'});
    final form =
        verify(
              () => dio.post<Map<String, dynamic>>(
                '/api/driver-documents',
                data: captureAny(named: 'data'),
                onSendProgress: any(named: 'onSendProgress'),
              ),
            ).captured.single
            as FormData;
    expect(form.fields.single.key, 'documentType');
    expect(form.fields.single.value, 'CRIMINAL_RECORD');
    expect(form.files.single.key, 'file');
  });

  test('maps the server answer to a photo failure', () {
    expect(photoFailureFrom(statusError(null)), PhotoFailure.network);
    expect(photoFailureFrom(statusError(413)), PhotoFailure.tooLarge);
    expect(photoFailureFrom(statusError(400)), PhotoFailure.unsupportedType);
    expect(photoFailureFrom(statusError(403)), PhotoFailure.unexpected);
  });
}
