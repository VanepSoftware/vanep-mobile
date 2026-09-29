import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'dio_client.dart';

/// Imagem servida pela propria API, que devolve caminho relativo e exige bearer.
///
/// Os `ImageProvider` de rede do Flutter usam o HttpClient nativo, que nao passa
/// pelo `AuthInterceptor`: o avatar tomaria 401 e falharia calado. Baixando pelo
/// Dio autenticado, o caminho relativo resolve contra a `baseUrl` e o retry de
/// token expirado do interceptor vale tambem para a foto.
@immutable
class ApiImage extends ImageProvider<ApiImage> {
  const ApiImage(this.path, {required this.dio, this.scale = 1.0});

  final String path;
  final Dio dio;
  final double scale;

  /// `null` quando nao ha foto ou o container ainda nao subiu, para a tela cair
  /// no placeholder em vez de tentar uma requisicao que nao tem como autenticar.
  static ImageProvider? forPath(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    final getIt = GetIt.I;
    if (!getIt.isRegistered<Dio>(instanceName: authenticatedDioName)) {
      return null;
    }
    return ApiImage(
      path,
      dio: getIt<Dio>(instanceName: authenticatedDioName),
    );
  }

  @override
  Future<ApiImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<ApiImage>(this);

  @override
  ImageStreamCompleter loadImage(ApiImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _download(key, decode),
      scale: key.scale,
      debugLabel: key.path,
    );
  }

  Future<ui.Codec> _download(ApiImage key, ImageDecoderCallback decode) async {
    final response = await key.dio.get<List<int>>(
      key.path,
      options: Options(responseType: ResponseType.bytes),
    );

    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('Resposta vazia para a imagem ${key.path}');
    }

    return decode(
      await ui.ImmutableBuffer.fromUint8List(Uint8List.fromList(data)),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiImage &&
          other.path == path &&
          other.scale == scale &&
          identical(other.dio, dio);

  @override
  int get hashCode => Object.hash(path, scale, identityHashCode(dio));

  @override
  String toString() => 'ApiImage("$path", scale: $scale)';
}
