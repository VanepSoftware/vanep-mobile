import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';

const needsYouVisibleLimit = 3;

int compareNeedsYouItems(NeedsYouItem first, NeedsYouItem second) {
  final byTier = first.tier.index.compareTo(second.tier.index);
  if (byTier != 0) return byTier;
  return compareDeadlines(first.deadline, second.deadline);
}

int compareDeadlines(DateTime? first, DateTime? second) {
  if (first == null && second == null) return 0;
  if (first == null) return 1;
  if (second == null) return -1;
  return first.compareTo(second);
}

class PrioritizeNeedsYouItems {
  const PrioritizeNeedsYouItems();

  NeedsYouSummary call(List<NeedsYouItem> items) {
    final ordered = [...items]..sort(compareNeedsYouItems);
    final visible = ordered.take(needsYouVisibleLimit).toList();
    return NeedsYouSummary(
      visible: visible,
      hiddenCount: ordered.length - visible.length,
    );
  }
}
