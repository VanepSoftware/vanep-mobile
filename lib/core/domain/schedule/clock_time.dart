import 'package:equatable/equatable.dart';

class ClockTime extends Equatable implements Comparable<ClockTime> {
  const ClockTime({required this.hour, required this.minute});

  final int hour;

  final int minute;

  static ClockTime? fromApi(Object? raw) {
    if (raw is! String) return null;
    final match = RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?$')
        .firstMatch(raw.trim());
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    if (hour > 23 || minute > 59) return null;
    return ClockTime(hour: hour, minute: minute);
  }

  String toApi() {
    final paddedHour = hour.toString().padLeft(2, '0');
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }

  int get minutesSinceMidnight => hour * 60 + minute;

  bool isAfter(ClockTime other) => compareTo(other) > 0;

  @override
  int compareTo(ClockTime other) {
    return minutesSinceMidnight.compareTo(other.minutesSinceMidnight);
  }

  @override
  List<Object?> get props => [hour, minute];
}
