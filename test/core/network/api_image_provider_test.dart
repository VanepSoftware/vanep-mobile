import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/network/api_image_provider.dart';

class MockDio extends Mock implements Dio {}

class MockApiImageLoader extends Mock implements ApiImageLoader {}

void main() {
  setUpAll(() => registerFallbackValue(Options()));

  test('loadBytes asks the authenticated client for raw bytes', () async {
    final dio = MockDio();
    when(
      () => dio.get<List<int>>(any(), options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response<List<int>>(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: const [1, 2, 3],
      ),
    );

    final bytes = await ApiImageLoader(
      dio: dio,
    ).loadBytes('/api/drivers/driver-1/photo');

    expect(bytes, Uint8List.fromList(const [1, 2, 3]));
    final options =
        verify(
              () => dio.get<List<int>>(
                '/api/drivers/driver-1/photo',
                options: captureAny(named: 'options'),
              ),
            ).captured.single
            as Options;
    expect(options.responseType, ResponseType.bytes);
  });

  test('two providers for the same path share the image cache key', () {
    final loader = MockApiImageLoader();

    expect(
      ApiImageProvider(path: '/a', loader: loader),
      ApiImageProvider(path: '/a', loader: MockApiImageLoader()),
    );
    expect(
      ApiImageProvider(path: '/a', loader: loader),
      isNot(ApiImageProvider(path: '/b', loader: loader)),
    );
  });

  testWidgets('apiImageFor builds no image when there is no path', (
    tester,
  ) async {
    final loader = MockApiImageLoader();
    final images = <ImageProvider?>[];

    await tester.pumpWidget(
      RepositoryProvider<ApiImageLoader>.value(
        value: loader,
        child: Builder(
          builder: (context) {
            images
              ..add(apiImageFor(context, null))
              ..add(apiImageFor(context, ''))
              ..add(apiImageFor(context, '/api/drivers/driver-1/photo'));
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(images[0], isNull);
    expect(images[1], isNull);
    expect(
      images[2],
      ApiImageProvider(path: '/api/drivers/driver-1/photo', loader: loader),
    );
  });
}
