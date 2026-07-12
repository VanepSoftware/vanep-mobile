import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/result/result.dart';

void main() {
  group('Result', () {
    test('Ok exposes value and reports success', () {
      const Result<String, int> result = Ok(42);

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
    });

    test('Err exposes error and reports failure', () {
      const Result<String, int> result = Err('boom');

      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
      expect(result.errorOrNull, 'boom');
      expect(result.valueOrNull, isNull);
    });

    test('fold runs the branch matching the variant', () {
      const Result<String, int> ok = Ok(2);
      const Result<String, int> err = Err('bad');

      expect(ok.fold((e) => 'err', (v) => 'ok $v'), 'ok 2');
      expect(err.fold((e) => 'err $e', (v) => 'ok'), 'err bad');
    });

    test('value equality and hashCode hold for same payloads', () {
      expect(const Ok<String, int>(1), const Ok<String, int>(1));
      expect(const Err<String, int>('x'), const Err<String, int>('x'));
      expect(const Ok<String, int>(1), isNot(const Ok<String, int>(2)));
      expect(
        const Ok<String, int>(1).hashCode,
        const Ok<String, int>(1).hashCode,
      );
      expect(
        const Err<String, int>('x').hashCode,
        const Err<String, int>('x').hashCode,
      );
    });
  });
}
