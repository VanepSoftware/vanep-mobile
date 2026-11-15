import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_route_repository_impl.dart';

import '../../fixtures/assistant_route_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockAssistantRouteDataSource dataSource;
  late AssistantRouteRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(testStopConfirmationAtPickup));

  setUp(() {
    dataSource = MockAssistantRouteDataSource();
    repository = AssistantRouteRepositoryImpl(dataSource: dataSource);
  });

  test('wraps the home overview in Ok', () async {
    when(() => dataSource.findHomeOverview())
        .thenAnswer((_) async => testHomeOverviewTwoVans);

    final result = await repository.findHomeOverview();

    expect(result.valueOrNull, testHomeOverviewTwoVans);
  });

  test('wraps today route in Ok, including no trip today', () async {
    when(() => dataSource.findTodayRoute('mock-van-carlos'))
        .thenAnswer((_) async => null);

    final result = await repository.findTodayRoute('mock-van-carlos');

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isNull);
  });

  test('returns the route after confirming a stop', () async {
    final route = testRouteOnPickup();
    when(() => dataSource.confirmStop(any())).thenAnswer((_) async => route);

    final result = await repository.confirmStop(testStopConfirmationAtPickup);

    expect(result.valueOrNull, route);
  });

  test('returns the route after undoing a stop', () async {
    final route = testRouteOnPickup();
    when(
      () => dataSource.undoStopConfirmation(
        vanToken: 'mock-van-carlos',
        stopToken: 'stop-3',
      ),
    ).thenAnswer((_) async => route);

    final result = await repository.undoStopConfirmation(
      vanToken: 'mock-van-carlos',
      stopToken: 'stop-3',
    );

    expect(result.valueOrNull, route);
  });

  test('marks the assistant as present in the van', () async {
    when(() => dataSource.markPresentInVan('mock-van-carlos'))
        .thenAnswer((_) async {});

    final result = await repository.markPresentInVan('mock-van-carlos');

    expect(result.isOk, isTrue);
  });
}
