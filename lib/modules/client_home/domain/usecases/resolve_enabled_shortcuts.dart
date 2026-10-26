import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';

class ResolveEnabledShortcuts {
  const ResolveEnabledShortcuts();

  Set<HomeShortcut> call(TodaySection today) {
    if (today.hasLinkedVan) return HomeShortcut.values.toSet();
    return const {HomeShortcut.proposals};
  }
}
