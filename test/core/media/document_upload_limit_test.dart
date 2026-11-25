import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/media/document_upload_limit.dart';

void main() {
  const bytesInMegabyte = 1024 * 1024;

  test('the limit is 10 MB counted as 1024 x 1024 bytes', () {
    expect(documentUploadLimitBytes, 10 * bytesInMegabyte);
  });

  test('a file of exactly 10 MB is within the limit', () {
    expect(isWithinDocumentUploadLimit(documentUploadLimitBytes), isTrue);
  });

  test('one byte above 10 MB is over the limit', () {
    expect(isWithinDocumentUploadLimit(documentUploadLimitBytes + 1), isFalse);
  });

  test('a small scanned PDF is within the limit', () {
    expect(isWithinDocumentUploadLimit(1400 * 1024), isTrue);
  });
}
