import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';

class AssistantChecklistErrorView extends StatelessWidget {
  const AssistantChecklistErrorView({required this.state, super.key});

  final AssistantChecklistState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: VanepErrorView(
          message: assistantFailureMessage(l10n, state.failure!),
          retryLabel: l10n.assistantVansRetry,
          onRetry: () {
            final vanToken = state.vanToken;
            if (vanToken != null) {
              context.read<AssistantChecklistCubit>().loadRoute(vanToken);
            }
          },
        ),
      ),
    );
  }
}
