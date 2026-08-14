import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/profile_field_limits.dart';
import '../cubit/personal_data_cubit.dart';
import '../cubit/personal_data_state.dart';
import '../mappers/profile_edit_failure_l10n.dart';

Future<void> showEmailChangeSheet(BuildContext context) {
  final cubit = context.read<PersonalDataCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: VanepColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: const EmailChangeSheet(),
        ),
      );
    },
  );
}

class EmailChangeSheet extends StatefulWidget {
  const EmailChangeSheet({super.key});

  @override
  State<EmailChangeSheet> createState() => _EmailChangeSheetState();
}

class _EmailChangeSheetState extends State<EmailChangeSheet> {
  late final TextEditingController _controller;
  String? _confirmedEmail;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<PersonalDataCubit, PersonalDataState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback &&
          current.feedback is PersonalDataEmailChangeSuccessFeedback,
      listener: (context, state) {
        if (state.feedback is PersonalDataEmailChangeSuccessFeedback) {
          setState(() => _confirmedEmail = _controller.text.trim());
        }
      },
      builder: (context, state) {
        final confirmedEmail = _confirmedEmail;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: confirmedEmail == null
                ? buildEmailChangeForm(context, l10n, state, _controller)
                : EmailChangeConfirmation(email: confirmedEmail),
          ),
        );
      },
    );
  }
}

Widget buildEmailChangeForm(
  BuildContext context,
  AppLocalizations l10n,
  PersonalDataState state,
  TextEditingController controller,
) {
  final emailError = profileFieldErrorMessage(l10n, state.fieldErrors['email']);

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l10n.profileChangeEmailTitle, style: VanepTypography.cardTitle),
      const SizedBox(height: 16),
      VanepTextField(
        label: l10n.profileFieldEmail,
        controller: controller,
        onChanged: (_) {},
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.email],
        maxLength: ProfileFieldLimits.emailMaxLength,
        errorText: emailError,
      ),
      const SizedBox(height: 20),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return VanepPrimaryButton(
            label: l10n.profileChangeEmailSubmit,
            isLoading: state.isEmailSubmitting,
            onPressed: state.isEmailSubmitting || value.text.trim().isEmpty
                ? null
                : () => context.read<PersonalDataCubit>().requestEmailChange(
                    value.text,
                  ),
          );
        },
      ),
    ],
  );
}

class EmailChangeConfirmation extends StatelessWidget {
  const EmailChangeConfirmation({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 44,
          color: VanepColors.brand,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.profileEmailChangeConfirmationTitle,
          style: VanepTypography.cardTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.profileEmailChangeConfirmationMessage(email),
          style: VanepTypography.cardSubtitle.copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        VanepPrimaryButton(
          label: l10n.continueButton,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
