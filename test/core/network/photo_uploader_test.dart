import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/network/photo_uploader.dart';

class MockDio extends Mock implements Dio {}

DioException statusError(int? status) => DioException(
  requestOptions: RequestOptions(),
  response: status == null
      ? null
      : Response<void>(requestOptions: RequestOptions(), statusCode: status),
);

void main() {
  test('posts the photo as the "file" part of a multipart form', () async {
    final dio = MockDio();
    final directory = await Directory.systemTemp.createTemp('vanep');
    final file = File('${directory.path}/van.jpg')..writeAsBytesSync([1, 2]);
    when(
      () => dio.post<void>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => Response(requestOptions: RequestOptions()));

    await PhotoUploader(dio: dio).upload(
      '/api/vehicles/van-1/photo-front',
      PickedPhoto(path: file.path, fileName: 'van.jpg'),
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
    await directory.delete(recursive: true);
  });

  test('maps the server answer to a photo failure', () {
    expect(photoFailureFrom(statusError(null)), PhotoFailure.network);
    expect(photoFailureFrom(statusError(413)), PhotoFailure.tooLarge);
    expect(photoFailureFrom(statusError(400)), PhotoFailure.unsupportedType);
    expect(photoFailureFrom(statusError(403)), PhotoFailure.unexpected);
  });
}
