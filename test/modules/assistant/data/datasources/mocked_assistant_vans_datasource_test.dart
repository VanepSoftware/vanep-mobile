import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

void main() {
  final now = DateTime(2026, 10, 25, 12);
  final dataSource = MockedAssistantVansDataSource(clock: () => now);

  test('offers a pending invite that expires in three days', () async {
    final overview = await dataSource.findVansOverview();

    expect(
      daysUntilInviteExpires(overview.pendingInvite!.expiresAt, now),
      3,
    );
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
