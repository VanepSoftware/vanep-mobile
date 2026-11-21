import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/media/document_file_store.dart';

import 'document_capture_fixture.dart';

void main() {
  late Directory base;
  late DocumentFileStore store;
  var tick = 0;

  setUp(() async {
    base = await createTestDirectory();
    tick = 0;
    store = DocumentFileStore(
      baseDirectory: () async => base,
      clock: () => DateTime.fromMicrosecondsSinceEpoch(++tick),
    );
  });

  tearDown(() => base.delete(recursive: true));

  test('keeps a copy that outlives the source file', () async {
    final source = writeTestFile(base, 'scan.pdf', sizeBytes: 10);

    final kept = await store.keep(source.path);
    source.deleteSync();

    expect(File(kept).existsSync(), isTrue);
    expect(File(kept).lengthSync(), 10);
    expect(kept, startsWith('${base.path}/vanep_documents/'));
    expect(kept, endsWith('scan.pdf'));
  });

  test('two copies of files with the same name do not collide', () async {
    final source = writeTestFile(base, 'page.jpg');

    final first = await store.keep(source.path);
    final second = await store.keep(source.path);

    expect(first, isNot(second));
  });

  test('keeps bytes under the given file name', () async {
    final kept = await store.keepBytes(
      'crlv.pdf',
      Uint8List.fromList([1, 2, 3]),
    );

    expect(File(kept).readAsBytesSync(), [1, 2, 3]);
    expect(kept, endsWith('crlv.pdf'));
  });
}
