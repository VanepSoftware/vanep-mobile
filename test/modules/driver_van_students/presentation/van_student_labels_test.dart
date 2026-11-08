import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/formatters/van_student_labels.dart';

import '../driver_van_students_fixtures.dart';

final l10n = AppLocalizationsPt();

final now = DateTime(2026, 11, 8, 10);

void main() {
  test('each family state has its subtitle', () {
    expect(
      studentRowSubtitle(l10n, uninvitedLaura, now),
      'Col. Horizonte · manhã · ida e volta',
    );
    expect(
      studentRowSubtitle(l10n, invitedSofia, now),
      'Convite enviado há 2 dias',
    );
    expect(
      studentRowSubtitle(l10n, joinedRafael, now),
      'Família entrou · confirmar',
    );
  });

  test('a contracted student takes the shift from its slots', () {
    expect(
      studentRowSubtitle(l10n, contractedBruno, now),
      'Col. Horizonte · manhã, tarde · ida e volta',
    );
  });

  test('an invite sent today or yesterday reads naturally', () {
    expect(invitedAgoLabel(l10n, now, now), 'Convite enviado hoje');
    expect(
      invitedAgoLabel(l10n, now.subtract(const Duration(days: 1)), now),
      'Convite enviado há 1 dia',
    );
  });

  test('the match body names the family and the age when known', () {
    expect(
      familyMatchBody(l10n, rafaelMatch),
      'A família Costa cadastrou Rafael Costa, 9 anos. '
      'Juntando, ele mantém a posição na rota.',
    );
    expect(familyMatchTitle(l10n, joinedRafael), 'É o mesmo Rafael?');
  });

  test('a refused action shows the API detail', () {
    expect(
      driverStudentFailureMessage(
        l10n,
        const DriverStudentRejectedFailure(
          detail: 'Este aluno já está ligado.',
        ),
      ),
      'Este aluno já está ligado.',
    );
    expect(
      driverStudentFailureMessage(l10n, const DriverStudentNetworkFailure()),
      'Sem conexão. Tente de novo.',
    );
  });
}
