import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';

enum HomeHeadline {
  hello,
  goodMorning,
  goodAfternoon,
  goodEvening,
  goodWeekend,
  vanArriving,
  allGood,
}

enum HomeShortcut {
  reportAbsence,
  seeOnMap,
  adjustStop,
  payments,
  proposals,
  contracts,
}

class DailyOverview extends Equatable {
  const DailyOverview({this.today, this.needsYou = const []});

  final TodaySection? today;

  final List<NeedsYouItem> needsYou;

  @override
  List<Object?> get props => [today, needsYou];
}

class ClientHome extends Equatable {
  const ClientHome({
    required this.date,
    required this.headline,
    required this.today,
    required this.needsYou,
    required this.enabledShortcuts,
  });

  final DateTime date;

  final HomeHeadline headline;

  final TodaySection today;

  final NeedsYouSummary needsYou;

  final Set<HomeShortcut> enabledShortcuts;

  bool isShortcutEnabled(HomeShortcut shortcut) =>
      enabledShortcuts.contains(shortcut);

  @override
  List<Object?> get props => [
    date,
    headline,
    today,
    needsYou,
    enabledShortcuts,
  ];
}
