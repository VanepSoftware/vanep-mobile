import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

typedef SlotSignature = (Weekday, RouteLeg, ClockTime);

typedef DaySignature = (Weekday, bool, bool);

List<List<T>> groupBySignature<T, S>(
  List<T> items,
  Set<S> Function(T item) signatureOf,
) {
  final groups = <List<T>>[];
  final signatures = <Set<S>>[];
  for (final item in items) {
    final signature = signatureOf(item);
    final index = signatures.indexWhere(
      (known) =>
          known.length == signature.length && known.containsAll(signature),
    );
    if (index < 0) {
      signatures.add(signature);
      groups.add([item]);
    } else {
      groups[index].add(item);
    }
  }
  return groups;
}

List<List<ProposalItem>> groupItemsBySchedule(List<ProposalItem> items) {
  return groupBySignature<ProposalItem, SlotSignature>(
    items,
    (item) => {
      for (final slot in item.slots) (slot.weekday, slot.leg, slot.pickupTime),
    },
  );
}

List<List<T>> groupItemsByDays<T extends RequestItem>(List<T> items) {
  return groupBySignature<T, DaySignature>(
    items,
    (item) => {
      for (final day in item.days)
        (day.weekday, day.needsOutbound, day.needsReturn),
    },
  );
}
