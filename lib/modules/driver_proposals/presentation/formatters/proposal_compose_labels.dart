import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

String formatProposalWeekday(AppLocalizations l10n, int weekday) {
  return formatWeekdayName(l10n, weekday);
}

String formatRouteLeg(AppLocalizations l10n, RouteLeg leg) {
  return switch (leg) {
    RouteLeg.outbound => l10n.driverProposalLegOutbound,
    RouteLeg.inbound => l10n.driverProposalLegReturn,
  };
}

String formatProposalClock(AppLocalizations l10n, int minutesFromMidnight) {
  final hour = minutesFromMidnight ~/ 60;
  final minute = (minutesFromMidnight % 60).toString().padLeft(2, '0');
  return l10n.clientHomeTimeOfDay('$hour', minute);
}

String formatReaisInput(int cents) {
  final reais = cents ~/ 100;
  final fraction = cents.abs() % 100;
  if (fraction == 0) return '$reais';
  return '$reais,${fraction.toString().padLeft(2, '0')}';
}

int? parseReaisInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 0;
  final match = RegExp(r'^(\d{1,7})(?:,(\d{0,2}))?$').firstMatch(trimmed);
  if (match == null) return null;
  final reais = int.parse(match.group(1)!);
  final fraction = match.group(2);
  final fractionCents = fraction == null || fraction.isEmpty
      ? 0
      : int.parse(fraction.padRight(2, '0'));
  return reais * 100 + fractionCents;
}

class ReaisInputFormatter extends TextInputFormatter {
  const ReaisInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (parseReaisInput(newValue.text) == null) return oldValue;
    return newValue;
  }
}

String driverProposalFailureLabel(
  AppLocalizations l10n,
  DriverProposalFailure failure,
) {
  return switch (failure) {
    DriverProposalFailure.network ||
    DriverProposalFailure.unexpected => l10n.driverProposalSendError,
    DriverProposalFailure.overdueInvoice => l10n.driverProposalOverdueMessage,
    DriverProposalFailure.notAcceptingStudents =>
      l10n.driverProposalNotAcceptingMessage,
    DriverProposalFailure.invalidAmount => l10n.driverProposalInvalidAmount,
  };
}

void reportStudentPrice({
  required ProposalStudentLine student,
  required String text,
  required void Function(String token, int cents) onPriceChanged,
}) {
  final cents = parseReaisInput(text);
  if (cents == null || cents == student.monthlyAmountCents) return;
  onPriceChanged(student.token, cents);
}
