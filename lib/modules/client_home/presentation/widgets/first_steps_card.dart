import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';

String firstStepTitle(AppLocalizations l10n, FirstStep step) {
  return switch (step) {
    FirstStep.account => l10n.clientHomeFirstStepAccount,
    FirstStep.address => l10n.clientHomeFirstStepAddress,
    FirstStep.dependents => l10n.clientHomeFirstStepDependents,
  };
}

String? firstStepHint(AppLocalizations l10n, FirstStep step) {
  return switch (step) {
    FirstStep.account => null,
    FirstStep.address => l10n.clientHomeFirstStepAddressHint,
    FirstStep.dependents => l10n.clientHomeFirstStepDependentsHint,
  };
}

String firstStepAction(AppLocalizations l10n, FirstStep step) {
  return switch (step) {
    FirstStep.address => l10n.clientHomeFirstStepAddressAction,
    FirstStep.account ||
    FirstStep.dependents => l10n.clientHomeFirstStepDependentsAction,
  };
}

class FirstStepsCard extends StatelessWidget {
  const FirstStepsCard({
    required this.steps,
    required this.onAddAddressTapped,
    required this.onAddDependentTapped,
    super.key,
  });

  final FirstStepsSection steps;
  final VoidCallback onAddAddressTapped;
  final VoidCallback onAddDependentTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentStep = steps.currentStep;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: brandCardGradient,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius + 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n
                  .clientHomeFirstStepsProgress(
                    steps.completedSteps,
                    FirstStepsSection.totalSteps,
                  )
                  .toUpperCase(),
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.brandSheen,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.clientHomeFirstStepsTitle,
              style: VanepTypography.heading.copyWith(
                color: VanepColors.onBrand,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.clientHomeFirstStepsMessage,
              style: VanepTypography.body.copyWith(color: onBrandMuted),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: steps.completedSteps / FirstStepsSection.totalSteps,
                minHeight: 4,
                color: VanepColors.brandSheen,
                backgroundColor: VanepColors.onBrand.withValues(alpha: 0.18),
              ),
            ),
            const SizedBox(height: 8),
            for (final (index, step) in FirstStep.values.indexed)
              FirstStepRow(
                number: index + 1,
                title: firstStepTitle(l10n, step),
                hint: steps.isStepDone(step) ? null : firstStepHint(l10n, step),
                done: steps.isStepDone(step),
                current: step == currentStep,
              ),
            if (currentStep != null) ...[
              const SizedBox(height: 12),
              VanepPrimaryButton(
                label: firstStepAction(l10n, currentStep),
                onBrand: true,
                trailingIcon: Icons.arrow_forward,
                onPressed: currentStep == FirstStep.address
                    ? onAddAddressTapped
                    : onAddDependentTapped,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FirstStepRow extends StatelessWidget {
  const FirstStepRow({
    required this.number,
    required this.title,
    required this.done,
    required this.current,
    this.hint,
    super.key,
  });

  final int number;
  final String title;
  final String? hint;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hintText = hint;
    final titleColor = done ? onBrandMuted : VanepColors.onBrand;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FirstStepMarker(number: number, done: done),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: VanepTypography.cardTitle.copyWith(
                    color: titleColor,
                    fontWeight: done ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                if (hintText != null)
                  Text(
                    hintText,
                    style: VanepTypography.cardSubtitle.copyWith(
                      color: onBrandMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (current)
            Text(
              l10n.clientHomeFirstStepNow,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.brandSheen,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class FirstStepMarker extends StatelessWidget {
  const FirstStepMarker({required this.number, required this.done, super.key});

  final int number;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? VanepColors.brandSheen : Colors.transparent,
        border: done
            ? null
            : Border.all(color: VanepColors.onBrand.withValues(alpha: 0.6)),
      ),
      child: done
          ? const Icon(Icons.check, size: 18, color: VanepColors.brandNavyDeep)
          : Text(
              '$number',
              style: VanepTypography.ratingLabel.copyWith(
                color: VanepColors.onBrand,
              ),
            ),
    );
  }
}
