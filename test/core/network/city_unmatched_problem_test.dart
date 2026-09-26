import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/network/city_unmatched_problem.dart';

void main() {
  test('recognizes the code when the back sends one', () {
    expect(
      isIbgeCityUnmatchedProblem({'code': 'location.city.unmatched'}),
      isTrue,
    );
  });

  test('recognizes the Portuguese detail the back sends today', () {
    expect(
      isIbgeCityUnmatchedProblem({
        'detail':
            'Este nome de cidade não corresponde a um município brasileiro. '
            'Escolha outra sugestão.',
      }),
      isTrue,
    );
  });

  test('recognizes the English detail', () {
    expect(
      isIbgeCityUnmatchedProblem({
        'detail':
            'This city name does not match a Brazilian municipality. '
            'Choose another suggestion.',
      }),
      isTrue,
    );
  });

  test('ignores the other 400 details of the same endpoints', () {
    expect(
      isIbgeCityUnmatchedProblem({
        'detail':
            'Escolha um endereço mais específico: este local não tem '
            'logradouro.',
      }),
      isFalse,
    );
    expect(
      isIbgeCityUnmatchedProblem({'detail': 'Endereço não encontrado.'}),
      isFalse,
    );
    expect(
      isIbgeCityUnmatchedProblem({
        'detail': 'Você pode ter no máximo 10 áreas.',
      }),
      isFalse,
    );
  });

  test('ignores bodies without a usable shape', () {
    expect(isIbgeCityUnmatchedProblem(null), isFalse);
    expect(isIbgeCityUnmatchedProblem('texto'), isFalse);
    expect(isIbgeCityUnmatchedProblem({'detail': 42}), isFalse);
    expect(isIbgeCityUnmatchedProblem(<String, Object?>{}), isFalse);
  });
}
