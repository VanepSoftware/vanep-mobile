import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';

/// Reads the client's day from GET /api/clients/me/day: the vans of today or,
/// without any, the next school days. With neither it leaves
/// [DailyOverview.today] empty, so the home falls back to first steps, no linked
/// van or negotiating.
class RemoteDailyOverviewDataSource implements DailyOverviewDataSource {
  const RemoteDailyOverviewDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  @override
  Future<DailyOverview> findDailyOverview() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.clientDayEndpoint,
    );
    return dailyOverviewFromJson(response.data ?? const {});
  }
}

DailyOverview dailyOverviewFromJson(Map<String, dynamic> json) {
  final date = DateTime.tryParse('${json['date']}');
  final rawVans = json['vans'];
  if (date == null || rawVans is! List) return const DailyOverview();
  final needsYou = expiredInspectionsFromJson(json['expiredInspections']);
  final vans = rawVans
      .whereType<Map<String, dynamic>>()
      .map((van) => vanDayFromJson(van, date))
      .whereType<VanDay>()
      .toList();
  if (vans.isEmpty) {
    return DailyOverview(
      today: noRouteTodayFromJson(
        json['upcoming'],
        childrenWithoutRoute: childrenWithoutVanFromJson(
          json['childrenWithoutVan'],
        ),
      ),
      needsYou: needsYou,
    );
  }
  return DailyOverview(
    today: VanDaySection(
      vans: vans,
      childrenWithoutRoute: childrenWithoutVanFromJson(
        json['childrenWithoutVan'],
      ),
    ),
    needsYou: needsYou,
  );
}

List<VehicleInspectionExpiredItem> expiredInspectionsFromJson(
  Object? inspections,
) {
  if (inspections is! List) return const [];
  final items = <VehicleInspectionExpiredItem>[];
  for (final inspection in inspections.whereType<Map<String, dynamic>>()) {
    final expiredOn = DateTime.tryParse('${inspection['expiredOn']}');
    if (expiredOn == null) continue;
    items.add(
      VehicleInspectionExpiredItem(
        driverName: firstName(inspection['driverName'] as String? ?? ''),
        expiredOn: expiredOn,
      ),
    );
  }
  return items;
}

List<ChildWithoutRoute> childrenWithoutVanFromJson(Object? children) {
  if (children is! List) return const [];
  return [
    for (final child in children.whereType<Map<String, dynamic>>())
      ChildWithoutRoute(
        name: firstName(child['name'] as String? ?? ''),
        reason: NoRouteReason.noVanYet,
      ),
  ];
}

/// The week plan shown when nobody rides today, or null when no child rides in
/// the days the API looked ahead.
NoRouteTodaySection? noRouteTodayFromJson(
  Object? upcoming, {
  List<ChildWithoutRoute> childrenWithoutRoute = const [],
}) {
  if (upcoming is! List) return null;
  final week = <WeekDayPlan>[];
  DateTime? nextRouteAt;
  for (final day in upcoming.whereType<Map<String, dynamic>>()) {
    final date = DateTime.tryParse('${day['date']}');
    if (date == null) continue;
    week.add(
      WeekDayPlan(
        date: date,
        going: day['going'] == true,
        returning: day['returning'] == true,
      ),
    );
    nextRouteAt ??= atTime(date, day['firstPickup']);
  }
  if (nextRouteAt == null) return null;
  return NoRouteTodaySection(
    nextRouteAt: nextRouteAt,
    week: week,
    childrenWithoutRoute: childrenWithoutRoute,
  );
}

VanDay? vanDayFromJson(Map<String, dynamic> json, DateTime date) {
  final shift = SchoolShift.fromApi(json['shift']);
  final departureAt = atTime(date, json['departureTime']);
  if (shift == null || departureAt == null) return null;
  final riders = json['riders'];
  return VanDay(
    driverName: firstName(json['driverName'] as String? ?? ''),
    vehicleModel: json['vehicleModel'] as String?,
    plate: json['plate'] as String?,
    shift: shift,
    departureAt: departureAt,
    riders: [
      if (riders is List)
        for (final rider in riders.whereType<Map<String, dynamic>>())
          VanRider(name: firstName(rider['name'] as String? ?? '')),
    ],
    schedule: VanSchedule(
      boardingStartAt: atTime(date, json['boardingStart']),
      boardingEndAt: atTime(date, json['boardingEnd']),
      schoolDepartureAt: atTime(date, json['schoolDeparture']),
    ),
  );
}

/// Joins the service [date] with an ISO local time such as "06:40:00".
DateTime? atTime(DateTime date, Object? time) {
  if (time is! String) return null;
  final parts = time.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

String firstName(String fullName) =>
    fullName.trim().split(RegExp(r'\s+')).first;
