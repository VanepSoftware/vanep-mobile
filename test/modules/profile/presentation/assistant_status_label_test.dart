import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';
import 'package:vanep_mobile/modules/profile/presentation/formatters/assistant_status_label.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';

void main() {
  Future<AppLocalizations> loadPt(WidgetTester tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return l10n;
  }

  testWidgets('maps assistant statuses to localized labels', (tester) async {
    final l10n = await loadPt(tester);

    expect(assistantStatusLabel(l10n, AssistantStatus.unlinked), 'Sem vínculo');
    expect(
      assistantStatusLabel(l10n, AssistantStatus.pending),
      'Convite pendente',
    );
    expect(assistantStatusLabel(l10n, AssistantStatus.active), 'Ativo');
    expect(assistantStatusLabel(l10n, AssistantStatus.inactive), 'Inativo');
    expect(assistantStatusLabel(l10n, null), isNull);
  });

  test('maps assistant statuses to quiet chip colors', () {
    expect(
      assistantStatusColor(VanepPalette.light, AssistantStatus.active),
      VanepPalette.light.success,
    );
    expect(
      assistantStatusColor(VanepPalette.light, AssistantStatus.pending),
      VanepColors.ratingStar,
    );
    expect(
      assistantStatusColor(VanepPalette.light, AssistantStatus.unlinked),
      VanepPalette.light.textMuted,
    );
    expect(
      assistantStatusColor(VanepPalette.light, AssistantStatus.inactive),
      VanepPalette.light.danger,
    );
    expect(assistantStatusColor(VanepPalette.light, null), isNull);
  });

  test('assistant status colors follow the dark palette', () {
    expect(
      assistantStatusColor(VanepPalette.dark, AssistantStatus.active),
      VanepPalette.dark.success,
    );
  });
}
