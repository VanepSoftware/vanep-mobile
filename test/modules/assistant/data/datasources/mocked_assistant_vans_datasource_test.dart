import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';

void main() {
  const dataSource = MockedAssistantVansDataSource();

  test('no longer fakes the pending invite', () async {
    final overview = await dataSource.findVansOverview();

    expect(overview.pendingInvite, isNull);
  });

  test('offers two active vans and only the first has a route today', () async {
    final overview = await dataSource.findVansOverview();

    expect(overview.activeVans, hasLength(2));
    expect(
      overview.activeVans.map((summary) => summary.hasRouteToday),
      [true, false],
    );
  });

  test('offers one former link', () async {
    final overview = await dataSource.findVansOverview();

    expect(overview.formerVanCount, 1);
  });
}
