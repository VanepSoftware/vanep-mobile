import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_list.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_schedule.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';

String formatProposalHeaderSubtitle(
  AppLocalizations l10n,
  ProposalComposeDraft draft,
) {
  return l10n.driverProposalHeaderSubtitle(
    draft.familyName,
    joinNames(l10n, [for (final student in draft.students) student.name]),
  );
}

String formatProposalVanName(AppLocalizations l10n, ProposalVanOption van) {
  return l10n.driverProposalVanName(van.model, van.plate);
}

String formatProposalVanSeats(
  AppLocalizations l10n,
  SchoolShift shift,
  ProposalVanOption van,
) {
  return switch (shift) {
    SchoolShift.morning => l10n.driverProposalSeatsMorning(
      van.freeSeats,
      van.capacity,
    ),
    SchoolShift.afternoon => l10n.driverProposalSeatsAfternoon(
      van.freeSeats,
      van.capacity,
    ),
  };
}

String formatProposalLegs(AppLocalizations l10n, ProposalLegs legs) {
  return switch (legs) {
    ProposalLegs.outboundAndReturn => l10n.driverProposalLegsBoth,
    ProposalLegs.outboundOnly => l10n.driverProposalLegsOutboundOnly,
    ProposalLegs.returnOnly => l10n.driverProposalLegsReturnOnly,
    ProposalLegs.none => l10n.driverProposalLegsNone,
  };
}

String formatRouteLeg(AppLocalizations l10n, RouteLeg leg) {
  return switch (leg) {
    RouteLeg.outbound => l10n.driverProposalLegOutbound,
    RouteLeg.inbound => l10n.driverProposalLegReturn,
  };
}

String formatInstallmentAmount(
  AppLocalizations l10n, {
  required int installments,
  required int monthlyCents,
}) {
  return l10n.driverProposalInstallmentAmount(
    installments,
    formatMoney(l10n, monthlyCents),
  );
}

String formatProposalInstallments(
  AppLocalizations l10n,
  ProposalPayment payment,
) {
  return l10n.driverProposalInstallmentsValue(
    payment.installments,
    payment.dueDay,
  );
}

String formatProposalDay(AppLocalizations l10n, DateTime date) {
  return date.day == 1 ? l10n.driverProposalFirstDay : '${date.day}';
}

String formatProposalMonth(AppLocalizations l10n, DateTime date) {
  return DateFormat.MMM(l10n.localeName).format(date).replaceAll('.', '');
}

String formatProposalPeriod(AppLocalizations l10n, ProposalPayment payment) {
  final start = payment.startDate;
  final end = payment.endDate;
  final startLabel = start.year == end.year
      ? l10n.driverProposalDayMonth(
          formatProposalDay(l10n, start),
          formatProposalMonth(l10n, start),
        )
      : l10n.driverProposalDayMonthYear(
          formatProposalDay(l10n, start),
          formatProposalMonth(l10n, start),
          '${start.year}',
        );
  return l10n.driverProposalPeriodValue(
    startLabel,
    l10n.driverProposalDayMonthYear(
      formatProposalDay(l10n, end),
      formatProposalMonth(l10n, end),
      '${end.year}',
    ),
  );
}

String formatProposalClock(AppLocalizations l10n, int minutesFromMidnight) {
  final hour = minutesFromMidnight ~/ 60;
  final minute = (minutesFromMidnight % 60).toString().padLeft(2, '0');
  return l10n.clientHomeTimeOfDay('$hour', minute);
}

String formatPickupWindow(AppLocalizations l10n, ProposalRouteTimes times) {
  return l10n.driverProposalTimeRange(
    formatProposalClock(l10n, times.pickupStartMinutes),
    formatProposalClock(l10n, times.pickupEndMinutes),
  );
}

String formatReservationFee(
  AppLocalizations l10n,
  ProposalReservationFee fee,
) {
  return switch (fee) {
    ProposalReservationFee.none => l10n.driverProposalReservationFeeNone,
    ProposalReservationFee.oneInstallmentDeducted =>
      l10n.driverProposalReservationFeeOneInstallment,
  };
}

String formatReadjustment(
  AppLocalizations l10n,
  ProposalReadjustment readjustment,
) {
  return switch (readjustment) {
    ProposalReadjustment.ipcaOnRenewal => l10n.driverProposalReadjustmentIpca,
    ProposalReadjustment.igpmOnRenewal => l10n.driverProposalReadjustmentIgpm,
    ProposalReadjustment.none => l10n.driverProposalReadjustmentNone,
  };
}

String formatCancellation(
  AppLocalizations l10n,
  ProposalConditions conditions,
) {
  if (conditions.cancellationPenaltyPercent == 0) {
    return l10n.driverProposalCancellationNoPenalty(
      conditions.cancellationNoticeDays,
    );
  }
  return l10n.driverProposalCancellationValue(
    conditions.cancellationNoticeDays,
    conditions.cancellationPenaltyPercent,
  );
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
    DriverProposalFailure.incompleteDraft => l10n.driverProposalIncompleteDraft,
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
