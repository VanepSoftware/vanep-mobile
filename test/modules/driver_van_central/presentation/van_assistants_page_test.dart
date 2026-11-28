import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/pages/van_assistants_page.dart';

import '../../auth/presentation/auth_test_harness.dart';
import '../driver_van_central_fixtures.dart';
import '../driver_van_central_mocks.dart';

void main() {
  late MockVanCentralCubit cubit;

  setUp(() {
    cubit = MockVanCentralCubit();
    when(() => cubit.refresh()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, List<VanAssistant>? team) async {
    when(() => cubit.state).thenReturn(
      VanCentralState(status: VanCentralStatus.loaded, assistants: team),
    );
    await tester.pumpWidget(
      authTestApp(
        BlocProvider<VanCentralCubit>.value(
          value: cubit,
          child: const VanAssistantsPage(),
        ),
      ),
    );
  }

  testWidgets('shows the summary and the team, working assistants first', (
    tester,
  ) async {
    await pump(tester, [
      const TestVanAssistant(
        token: 'a2',
        name: 'Rita Souza',
        status: VanAssistantStatus.pending,
        email: 'rita@vanep.test',
      ),
      TestVanAssistant(
        token: 'a1',
        name: 'Marcos Lima',
        status: VanAssistantStatus.active,
        email: 'marcos@vanep.test',
        activatedAt: DateTime(2026, 10, 1),
      ),
    ]);

    expect(find.text('Marcos · 1 convite pendente'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);
    expect(find.text('Convite pendente'), findsOneWidget);
    expect(find.text('marcos@vanep.test'), findsOneWidget);
    expect(find.text('Desde 01/10/2026'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Marcos Lima')).dy,
      lessThan(tester.getTopLeft(find.text('Rita Souza')).dy),
    );
  });

  testWidgets('shows the empty state', (tester) async {
    await pump(tester, const []);

    expect(find.text('Nenhum auxiliar ainda'), findsOneWidget);
    expect(
      find.textContaining('Você ainda não tem auxiliares'),
      findsOneWidget,
    );
  });

  testWidgets('says when the team could not be loaded and refreshes on pull', (
    tester,
  ) async {
    await pump(tester, null);

    expect(
      find.textContaining('Não foi possível carregar seus auxiliares'),
      findsOneWidget,
    );

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => cubit.refresh()).called(1);
  });
}
