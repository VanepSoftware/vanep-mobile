import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/remote_daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';

class MockDio extends Mock implements Dio {}

const environment = Environment(
  authBaseUrl: 'https://api.vanep.test',
  oauthClientId: 'vanep-mobile',
);

Map<String, dynamic> carlosMorning({Object? boardingStart = '06:40:00'}) => {
  'driverToken': 'drv-carlos',
  'driverName': 'Carlos Souza',
  'vehicleModel': 'Sprinter',
  'plate': 'SDF4E21',
  'shift': 'MORNING',
  'departureTime': '06:20:00',
  'riders': [
    {'dependentToken': 'dep-ana', 'name': 'Ana Lima'},
    {'dependentToken': 'dep-pedro', 'name': 'Pedro Lima'},
  ],
  'boardingStart': boardingStart,
  'boardingEnd': '06:50:00',
  'schoolDeparture': '12:30:00',
};

void main() {
  test('reads the vans of the day into a van day section', () async {
    final dio = MockDio();
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'date': '2027-03-01',
          'vans': [carlosMorning()],
        },
      ),
    );

    final overview = await RemoteDailyOverviewDataSource(
      dio: dio,
      environment: environment,
    ).findDailyOverview();

    final section = overview.today! as VanDaySection;
    final van = section.vans.single;
    expect(van.driverName, 'Carlos');
    expect(van.vehicleModel, 'Sprinter');
    expect(van.plate, 'SDF4E21');
    expect(van.shift, SchoolShift.morning);
    expect(van.departureAt, DateTime(2027, 3, 1, 6, 20));
    expect(van.riders, const [VanRider(name: 'Ana'), VanRider(name: 'Pedro')]);
    expect(van.schedule.boardingStartAt, DateTime(2027, 3, 1, 6, 40));
    expect(van.schedule.boardingEndAt, DateTime(2027, 3, 1, 6, 50));
    expect(van.schedule.schoolArrivalAt, isNull);
    expect(van.schedule.schoolDepartureAt, DateTime(2027, 3, 1, 12, 30));
    expect(van.live, isNull);
    verify(
      () => dio.get<Map<String, dynamic>>(
        'https://api.vanep.test/api/clients/me/day',
      ),
    ).called(1);
  });

  test('leaves today empty when no child rides a van today', () {
    expect(
      dailyOverviewFromJson({'date': '2027-03-01', 'vans': []}),
      const DailyOverview(),
    );
  });

  test('keeps a van whose children only ride back today', () {
    final overview = dailyOverviewFromJson({
      'date': '2027-03-01',
      'vans': [carlosMorning(boardingStart: null)],
    });

    final van = (overview.today! as VanDaySection).vans.single;
    expect(van.schedule.boardingStartAt, isNull);
  });

  test('skips a van with an unknown shift', () {
    expect(
      dailyOverviewFromJson({
        'date': '2027-03-01',
        'vans': [
          {...carlosMorning(), 'shift': 'SOMETIME'},
        ],
      }),
      const DailyOverview(),
    );
  });

  test('turns an ISO local time into a moment of the service day', () {
    expect(
      atTime(DateTime(2027, 3, 1), '18:05:00'),
      DateTime(2027, 3, 1, 18, 5),
    );
    expect(atTime(DateTime(2027, 3, 1), null), isNull);
    expect(atTime(DateTime(2027, 3, 1), 'soon'), isNull);
  });

  test('shows the week plan when nobody rides today', () {
    final overview = dailyOverviewFromJson({
      'date': '2027-03-01',
      'vans': [],
      'upcoming': [
        {'date': '2027-03-02', 'going': false, 'returning': false},
        {
          'date': '2027-03-03',
          'going': true,
          'returning': false,
          'firstPickup': '06:40:00',
        },
      ],
    });

    final section = overview.today! as NoRouteTodaySection;
    expect(section.nextRouteAt, DateTime(2027, 3, 3, 6, 40));
    expect(section.week, [
      WeekDayPlan(date: DateTime(2027, 3, 2), going: false, returning: false),
      WeekDayPlan(date: DateTime(2027, 3, 3), going: true, returning: false),
    ]);
    expect(section.firstDayWithoutReturn?.date, DateTime(2027, 3, 3));
  });

  test('has no week plan without any ride ahead', () {
    expect(noRouteTodayFromJson(const []), isNull);
    expect(noRouteTodayFromJson(null), isNull);
  });

  test('lists the children still without a van next to the vans', () {
    final overview = dailyOverviewFromJson({
      'date': '2027-03-01',
      'vans': [carlosMorning()],
      'childrenWithoutVan': [
        {'dependentToken': 'dep-davi', 'name': 'Davi Lima'},
      ],
    });

    final section = overview.today! as VanDaySection;
    expect(section.childrenWithoutRoute, const [
      ChildWithoutRoute(name: 'Davi', reason: NoRouteReason.noVanYet),
    ]);
  });

  test('warns about expired inspections even without vans today', () {
    final overview = dailyOverviewFromJson({
      'date': '2027-03-01',
      'vans': [],
      'upcoming': [],
      'expiredInspections': [
        {
          'driverToken': 'drv-carlos',
          'driverName': 'Carlos Souza',
          'expiredOn': '2027-02-20',
        },
        {'driverName': 'Sem data'},
      ],
    });

    expect(overview.today, isNull);
    expect(overview.needsYou, [
      VehicleInspectionExpiredItem(
        driverName: 'Carlos',
        expiredOn: DateTime(2027, 2, 20),
      ),
    ]);
  });
}
