import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_map_placeholder.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_pickup_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';

import '../../ibge_locations/ibge_locations_fixture.dart';
import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';
import 'dependents_page_harness.dart';

const anaWithAddress = TestDependent(
  token: 'dep-ana',
  name: 'Ana Oliveira',
  address: TestDependentAddress(complement: 'Casa'),
);

const anaWithoutAddress = TestDependent(token: 'dep-ana', name: 'Ana Oliveira');

void main() {
  late DependentEditorDoubles doubles;
  Dependent? result;

  setUpAll(registerDependentWidgetFallbacks);

  setUp(() {
    doubles = DependentEditorDoubles()..register();
    result = null;
  });

  tearDown(getIt.reset);

  Future<void> openEditor(WidgetTester tester, Dependent dependent) {
    return pumpAndOpen(
      tester,
      dependentsHarness(MockDependentsCubit(), (context) async {
        result = await openDependentPickup(context, dependent: dependent);
      }),
    );
  }

  testWidgets('shows the static map with the adjust chip', (tester) async {
    await openEditor(tester, anaWithAddress);

    expect(find.text('Embarque'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.byType(VanepMapPlaceholder), findsOneWidget);
    expect(find.text('Ajustar no mapa'), findsOneWidget);
  });

  testWidgets('tapping adjust on map changes nothing', (tester) async {
    await openEditor(tester, anaWithAddress);

    await tester.tap(find.text('Ajustar no mapa'));
    await tester.pumpAndSettle();

    expect(find.byType(DependentPickupPage), findsOneWidget);
    expect(find.text('QNL 5 Conjunto A'), findsOneWidget);
    expect(
      tester
          .widget<VanepPrimaryButton>(find.byType(VanepPrimaryButton))
          .onPressed,
      isNull,
    );
  });

  testWidgets('opens with the saved address in the form', (tester) async {
    await openEditor(tester, anaWithAddress);

    expect(find.text('72120-120'), findsOneWidget);
    expect(find.text('QNL 5 Conjunto A'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Casa'), findsOneWidget);
    expect(find.textContaining('Taguatinga'), findsOneWidget);
  });

  testWidgets('a new address from the cep is saved and handed back', (
    tester,
  ) async {
    when(() => doubles.lookupCep(any()))
        .thenAnswer((_) async => Ok<CepFailure, CepLookup>(fakeCepLookup()));
    doubles.updateReturns(anaWithAddress);
    await openEditor(tester, anaWithoutAddress);

    await tester.enterText(fieldLabeled('CEP'), '72120120');
    await tester.pumpAndSettle();
    await tester.enterText(fieldLabeled('Número'), '10');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final draft =
        verify(
              () => doubles.updateDependent(
                snapshot: anaWithoutAddress,
                draft: captureAny(named: 'draft'),
              ),
            ).captured.single
            as DependentDraft;
    expect(draft.address.zipCode, '72120120');
    expect(draft.address.number, '10');
    expect(result, anaWithAddress);
    expect(find.byType(DependentPickupPage), findsNothing);
  });
}
