import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:vanep_mobile/core/media/picked_document.dart';

Future<Directory> createTestDirectory() =>
    Directory.systemTemp.createTemp('vanep_documents_test');

File writeTestFile(Directory directory, String name, {int sizeBytes = 4}) {
  return File('${directory.path}/$name')
    ..writeAsBytesSync(List<int>.filled(sizeBytes, 7));
}

const testScannedDocument = PickedDocument(
  path: '/tmp/vanep_documents/1-scan.pdf',
  fileName: '1-scan.pdf',
  mimeType: 'application/pdf',
  sizeBytes: 1400 * 1024,
  pageCount: 2,
  pagePreviewPaths: [
    '/tmp/vanep_documents/2-page-1.jpg',
    '/tmp/vanep_documents/3-page-2.jpg',
  ],
);

final class FakePlatformFile extends PlatformFile {
  FakePlatformFile({required this.name, this.filePath, this.bytes});

  @override
  final String name;

  final String? filePath;

  final Uint8List? bytes;

  @override
  Uri get uri => filePath == null
      ? Uri.parse('content://documents/$name')
      : Uri.file(filePath!);

  @override
  XFile get xFile => XFile(filePath ?? name);

  @override
  int? lengthSync() => bytes?.length ?? File(filePath!).lengthSync();

  @override
  Future<int?> length() async => lengthSync();

  @override
  Future<Uint8List> readAsBytes() async =>
      bytes ?? File(filePath!).readAsBytesSync();

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes ?? Uint8List(0));
}
