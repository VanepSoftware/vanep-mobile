import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

void main() {
  test('conflicts are equal only with the same detail', () {
    expect(
      const NegotiationConflictFailure(detail: 'A proposta mudou.'),
      equals(const NegotiationConflictFailure(detail: 'A proposta mudou.')),
    );
    expect(
      const NegotiationConflictFailure(detail: 'A proposta mudou.'),
      isNot(equals(const NegotiationConflictFailure(detail: 'Já existe.'))),
    );
  });

  test('rejections are equal only with the same detail', () {
    expect(
      const NegotiationRejectedFailure(detail: 'Cadastro incompleto.'),
      equals(const NegotiationRejectedFailure(detail: 'Cadastro incompleto.')),
    );
    expect(
      const NegotiationRejectedFailure(detail: 'Cadastro incompleto.'),
      isNot(equals(const NegotiationRejectedFailure(detail: 'Limite.'))),
    );
  });

  test('a conflict and a rejection with the same detail differ', () {
    expect(
      const NegotiationConflictFailure(detail: 'x'),
      isNot(equals(const NegotiationRejectedFailure(detail: 'x'))),
    );
  });

  test('failures without detail are equal by kind', () {
    expect(
      const NegotiationNetworkFailure(),
      equals(const NegotiationNetworkFailure()),
    );
    expect(
      const NegotiationNotFoundFailure(),
      isNot(equals(const NegotiationInvalidFailure())),
    );
    expect(
      const NegotiationUnexpectedFailure(),
      isNot(equals(const NegotiationNetworkFailure())),
    );
  });
}
