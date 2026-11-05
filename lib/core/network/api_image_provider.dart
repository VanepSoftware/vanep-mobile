import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/network/api_image_loader.dart';

class ApiImageProvider extends ImageProvider<ApiImageProvider> {
  const ApiImageProvider({required this.path, required this.loader});

  final String path;
  final ApiImageLoader loader;

  @override
  Future<ApiImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ApiImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    ApiImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: decodeApiImage(key, decode),
      scale: 1,
      debugLabel: key.path,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ApiImageProvider && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}

Future<ui.Codec> decodeApiImage(
  ApiImageProvider key,
  ImageDecoderCallback decode,
) async {
  final bytes = await key.loader.loadBytes(key.path);
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  return decode(buffer);
}

ImageProvider? apiImageFor(BuildContext context, String? path) {
  if (path == null || path.isEmpty) return null;
  return ApiImageProvider(path: path, loader: context.read<ApiImageLoader>());
}

void keepPlaceholderOnImageError(Object error, StackTrace? stackTrace) {}
