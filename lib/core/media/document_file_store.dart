import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

const String keptDocumentsFolderName = 'vanep_documents';

class DocumentFileStore {
  DocumentFileStore({
    Future<Directory> Function()? baseDirectory,
    DateTime Function()? clock,
  }) : baseDirectory = baseDirectory ?? getTemporaryDirectory,
       clock = clock ?? DateTime.now;

  final Future<Directory> Function() baseDirectory;
  final DateTime Function() clock;

  Future<String> keep(String sourcePath) async {
    final target = await targetPathFor(fileNameOf(sourcePath));
    await File(sourcePath).copy(target);
    return target;
  }

  Future<String> keepBytes(String fileName, Uint8List bytes) async {
    final target = await targetPathFor(fileName);
    await File(target).writeAsBytes(bytes, flush: true);
    return target;
  }

  Future<String> targetPathFor(String fileName) async {
    final base = await baseDirectory();
    final folder = await Directory('${base.path}/$keptDocumentsFolderName')
        .create(recursive: true);
    return '${folder.path}/${clock().microsecondsSinceEpoch}-$fileName';
  }
}

String fileNameOf(String path) => path.split(Platform.pathSeparator).last;
