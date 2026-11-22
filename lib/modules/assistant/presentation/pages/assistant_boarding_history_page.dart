import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_boarding_history_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_history_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

class AssistantBoardingHistoryPage extends StatelessWidget {
  const AssistantBoardingHistoryPage({
    required this.studentToken,
    required this.studentName,
    super.key,
  });

  final String studentToken;
  final String studentName;

  static Route<void> route({
    required String studentToken,
    required String studentName,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<AssistantBoardingHistoryCubit>(
        create: (_) =>
            getIt<AssistantBoardingHistoryCubit>()..loadHistory(studentToken),
        child: AssistantBoardingHistoryPage(
          studentToken: studentToken,
          studentName: studentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: AppBar(
        backgroundColor: context.palette.surface,
        title: Text(l10n.assistantHistoryTitle),
      ),
      body:
          BlocBuilder<
            AssistantBoardingHistoryCubit,
            AssistantBoardingHistoryState
          >(
            builder: (context, state) => switch (state.status) {
              AssistantBoardingHistoryStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              AssistantBoardingHistoryStatus.loadFailed => Padding(
                padding: assistantHomePagePadding,
                child: VanepErrorView(
                  message: assistantFailureMessage(l10n, state.failure!),
                  retryLabel: l10n.assistantHomeRetry,
                  onRetry: () => context
                      .read<AssistantBoardingHistoryCubit>()
                      .loadHistory(studentToken),
                ),
              ),
              AssistantBoardingHistoryStatus.ready =>
                AssistantBoardingHistoryBody(
                  studentName: studentName,
                  days: state.days,
                ),
            },
          ),
    );
  }
}

class AssistantBoardingHistoryBody extends StatelessWidget {
  const AssistantBoardingHistoryBody({
    required this.studentName,
    required this.days,
    super.key,
  });

  final String studentName;
  final List<AssistantBoardingHistoryDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListView(
      padding: assistantHomePagePadding,
      children: [
        Text(studentName, style: typography.pageTitle),
        Text(l10n.assistantHistoryLastDays, style: typography.cardSubtitle),
        const SizedBox(height: assistantHomeSectionSpacing),
        if (days.isEmpty)
          Text(l10n.assistantHistoryEmpty, style: typography.cardSubtitle),
        for (final day in days) ...[
          VanepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historyDayTitle(l10n, day.date),
                  style: typography.cardTitle,
                ),
                const SizedBox(height: 8),
                for (final (label, record) in [
                  (l10n.assistantStopsOutbound, day.outbound),
                  (l10n.assistantStopsReturn, day.inbound),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(label, style: typography.overline),
                        ),
                        Expanded(
                          child: Text(
                            legRecordLine(
                              l10n,
                              record,
                              languageCode: languageCode,
                            ),
                            style: typography.body,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: assistantHomeItemSpacing),
        ],
      ],
    );
  }
}
