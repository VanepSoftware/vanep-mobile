import 'dart:typed_data';

import 'package:dio/dio.dart';

class ApiImageLoader {
  const ApiImageLoader({required this.dio});

  final Dio dio;

  Future<Uint8List> loadBytes(String path) async {
    final response = await dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }
}
