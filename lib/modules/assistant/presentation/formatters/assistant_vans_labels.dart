import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

const minutesPerHour = 60;

const vanSubtitleSeparator = ' · ';

String formatDepartureTime(
  int departureMinutes, {
  required String languageCode,
}) {
  final hour = departureMinutes ~/ minutesPerHour;
  final minute = departureMinutes % minutesPerHour;
  final paddedMinute = minute.toString().padLeft(2, '0');
  if (languageCode != 'pt') return '$hour:$paddedMinute';
  return minute == 0 ? '${hour}h' : '${hour}h$paddedMinute';
}

int daysUntilInviteExpires(DateTime expiresAt, DateTime now) {
  return expiresAt.difference(now).inDays;
}

String assistantInitialsOf(String fullName) {
  final words = fullName
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  final first = words.first[0];
  final second = words.length > 1 ? words[1][0] : '';
  return '$first$second'.toUpperCase();
}

String firstNameOf(String fullName) {
  return fullName.trim().split(RegExp(r'\s+')).first;
}

String assistantVansShiftLabel(AppLocalizations l10n, String? shift) {
  return switch (shift) {
    'MORNING' => l10n.assistantVansShiftMorning,
    'AFTERNOON' => l10n.assistantVansShiftAfternoon,
    'NIGHT' => l10n.assistantVansShiftNight,
    'FULLTIME' => l10n.assistantVansShiftFullTime,
    _ => '',
  };
}

String assistantVanSubtitle(AppLocalizations l10n, AssistantVan van) {
  return [
    van.model,
    van.plate,
    assistantVansShiftLabel(l10n, van.shift),
  ].where((part) => part.isNotEmpty).join(vanSubtitleSeparator);
}
