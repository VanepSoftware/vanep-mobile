import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/formatters/upper_case_input_formatter.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/assistant_invite_cubit.dart';
import '../cubit/assistant_invite_state.dart';
import '../mappers/assistant_failure_l10n.dart';
import 'assistant_lean_signup_page.dart';

Future<void> openAssistantInvite(
  BuildContext context, {
  String? initialCode,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => getIt<AssistantInviteCubit>(param1: initialCode),
        child: const AssistantInviteCodePage(),
      ),
    ),
  );
}

class AssistantInviteCodePage extends StatefulWidget {
  const AssistantInviteCodePage({super.key});

  @override
  State<AssistantInviteCodePage> createState() =>
      _AssistantInviteCodePageState();
}

class _AssistantInviteCodePageState extends State<AssistantInviteCodePage> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AssistantInviteCubit>();
    _codeController = TextEditingController(text: cubit.state.code);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AssistantInviteCubit>();

    return BlocConsumer<AssistantInviteCubit, AssistantInviteState>(
      listenWhen: (previous, current) =>
          previous.step != current.step &&
          current.step == AssistantInviteStep.signup,
      listener: (context, state) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: const AssistantLeanSignupPage(),
            ),
          ),
        );
      },
      builder: (context, state) {
        final errorText = state.codeFailure != null
            ? assistantFailureMessage(l10n, state.codeFailure!)
            : null;

        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: const VanepAppBar(),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                VanepPageHeader(
                  title: l10n.assistantInviteTitle,
                  subtitle: l10n.assistantInviteSubtitle,
                ),
                const SizedBox(height: 12),
                VanepTextField(
                  label: l10n.assistantInviteCodeLabel,
                  hintText: l10n.assistantInviteCodeHint,
                  controller: _codeController,
                  inputFormatters: const [UpperCaseInputFormatter()],
                  errorText: errorText,
                  onChanged: cubit.updateCode,
                  enabled: !state.isValidatingCode,
                ),
                const SizedBox(height: 24),
                VanepPrimaryButton(
                  label: l10n.assistantInviteSubmit,
                  isLoading: state.isValidatingCode,
                  onPressed: state.canValidateCode
                      ? () => cubit.validateCode(_codeController.text)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
