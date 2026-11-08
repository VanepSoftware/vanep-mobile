import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_vans_page.dart';

import '../../../auth/presentation/auth_test_harness.dart';
import '../../fixtures/assistant_fixtures.dart';

class MockAssistantVansCubit extends MockCubit<AssistantVansState>
    implements AssistantVansCubit {}

void main() {
  late MockAssistantVansCubit cubit;

  setUp(() {
    cubit = MockAssistantVansCubit();
    when(() => cubit.loadVans()).thenAnswer((_) async {});
  });

  Future<void> pumpPage(WidgetTester tester, AssistantVansState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      authTestApp(
        BlocProvider<AssistantVansCubit>.value(
          value: cubit,
          child: const AssistantVansPage(),
        ),
      ),
    );
  }

  AssistantVansState readyState(AssistantVansOverview overview) {
    return AssistantVansState(
      status: AssistantVansStatus.ready,
      overview: overview,
    );
  }

  testWidgets('shows the header', (tester) async {
    await pumpPage(tester, readyState(testAssistantVansOverview));

    expect(find.text('Vans'), findsOneWidget);
    expect(find.text('As vans em que você trabalha'), findsOneWidget);
  });

  testWidgets('shows the pending invite with both buttons', (tester) async {
    await pumpPage(
      tester,
      readyState(
        AssistantVansOverview(
          pendingInvite: buildAssistantPendingInvite(
            expiresIn: const Duration(days: 3, hours: 1),
          ),
        ),
      ),
    );

    expect(find.text('Convite pendente'), findsOneWidget);
    expect(find.text('João Pedro Lima'), findsOneWidget);
    expect(find.text('JP'), findsOneWidget);
    expect(find.text('Master 2019 · tarde'), findsOneWidget);
    expect(find.text('Expira em 3 dias'), findsOneWidget);
    expect(find.text('Recusar'), findsOneWidget);
    expect(find.text('Aceitar'), findsOneWidget);
  });

  testWidgets('hides the invite section when there is no invite', (
    tester,
  ) async {
    await pumpPage(
      tester,
      readyState(
        const AssistantVansOverview(
          activeVans: [testAssistantVanSummaryWithRoute],
        ),
      ),
    );

    expect(find.text('Convite pendente'), findsNothing);
    expect(find.text('Ativas'), findsOneWidget);
  });

  testWidgets('shows each active van and the route button only when it has '
      'a route today', (tester) async {
    await pumpPage(tester, readyState(testAssistantVansOverview));

    expect(find.text('Van de Carlos'), findsOneWidget);
    expect(find.text('Sprinter · SDF4E21 · manhã'), findsOneWidget);
    expect(find.text('Saída 6h20'), findsOneWidget);
    expect(find.text('16 alunos'), findsOneWidget);
    expect(find.text('Van de Rita'), findsOneWidget);
    expect(find.text('Saída 11h40'), findsOneWidget);
    expect(find.text('1 aluno'), findsOneWidget);
    expect(find.text('Detalhes'), findsNWidgets(2));
    expect(find.text('Rota de hoje'), findsOneWidget);
  });

  testWidgets('shows the former links row when there are former links', (
    tester,
  ) async {
    await pumpPage(tester, readyState(testAssistantVansOverview));

    expect(find.text('Vínculos anteriores · 1 van'), findsOneWidget);
  });

  testWidgets('hides the former links row when there are no former links', (
    tester,
  ) async {
    await pumpPage(
      tester,
      readyState(
        const AssistantVansOverview(
          activeVans: [testAssistantVanSummaryWithRoute],
        ),
      ),
    );

    expect(find.textContaining('Vínculos anteriores'), findsNothing);
  });

  testWidgets('shows the empty state', (tester) async {
    await pumpPage(tester, readyState(const AssistantVansOverview()));

    expect(find.text('Você ainda não tem vans vinculadas.'), findsOneWidget);
  });

  testWidgets('shows the skeleton while loading', (tester) async {
    await pumpPage(tester, const AssistantVansState());

    expect(find.byType(AssistantVansSkeleton), findsOneWidget);
    expect(find.text('Ativas'), findsNothing);
  });

  testWidgets('shows the error and retries', (tester) async {
    await pumpPage(
      tester,
      const AssistantVansState(
        status: AssistantVansStatus.loadFailed,
        failure: AssistantFailure.network,
      ),
    );

    expect(find.byType(VanepErrorView), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));

    verify(() => cubit.loadVans()).called(1);
  });
}
