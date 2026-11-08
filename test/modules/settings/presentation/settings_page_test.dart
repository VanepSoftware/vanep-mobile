import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_segmented_control.dart';
import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';
import 'package:vanep_mobile/modules/settings/presentation/cubit/theme_preference_cubit.dart';
import 'package:vanep_mobile/modules/settings/presentation/pages/settings_page.dart';

import '../../../core/ui/localized_harness.dart';
import '../settings_mocks.dart';

void main() {
  late MockChangeThemePreference changeThemePreference;
  late ThemePreferenceCubit cubit;

  setUpAll(registerSettingsFallbacks);

  setUp(() {
    changeThemePreference = MockChangeThemePreference();
    cubit = ThemePreferenceCubit(
      initialPreference: ThemePreference.system,
      changeThemePreference: changeThemePreference,
    );
  });

  tearDown(() => cubit.close());

  Future<void> pumpSettingsPage(WidgetTester tester) {
    return tester.pumpWidget(
      BlocProvider<ThemePreferenceCubit>.value(
        value: cubit,
        child: localizedHarness(const SettingsPage()),
      ),
    );
  }

  bool isSegmentSelected(WidgetTester tester, String label) {
    return tester
        .widget<VanepSegmentButton>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(VanepSegmentButton),
          ),
        )
        .isSelected;
  }

  testWidgets('shows the appearance options with the current one selected', (
    tester,
  ) async {
    await pumpSettingsPage(tester);

    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Aparência'), findsOneWidget);
    expect(isSegmentSelected(tester, 'Sistema'), isTrue);
    expect(isSegmentSelected(tester, 'Claro'), isFalse);
    expect(isSegmentSelected(tester, 'Escuro'), isFalse);
    expect(
      find.text(
        'No modo Sistema, o app segue o tema claro ou escuro do seu celular.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('picking an option applies and saves it', (tester) async {
    when(() => changeThemePreference(any()))
        .thenAnswer((_) async => const Ok<SettingsFailure, void>(null));
    await pumpSettingsPage(tester);

    await tester.tap(find.text('Escuro'));
    await tester.pump();

    expect(cubit.state.preference, ThemePreference.dark);
    expect(isSegmentSelected(tester, 'Escuro'), isTrue);
    verify(() => changeThemePreference(ThemePreference.dark)).called(1);
  });

  testWidgets('tells the user when the choice could not be saved', (
    tester,
  ) async {
    when(() => changeThemePreference(any())).thenAnswer(
      (_) async =>
          const Err<SettingsFailure, void>(SettingsFailure.storageUnavailable),
    );
    await pumpSettingsPage(tester);

    await tester.tap(find.text('Claro'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text(
        'Não foi possível salvar sua escolha de tema. Ela volta ao padrão '
        'quando você reabrir o app.',
      ),
      findsOneWidget,
    );
  });
}
