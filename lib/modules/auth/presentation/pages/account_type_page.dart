import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_glass_card.dart';
import '../../../../core/ui/vanep_screen_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/user_type.dart';
import 'signup_page.dart';

typedef AccountTypeSelected =
    Future<void> Function(BuildContext context, UserType type);

Future<void> openAccountTypeChoice(
  BuildContext context, {
  AccountTypeSelected onTypeSelected = openSignup,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AccountTypePage(onTypeSelected: onTypeSelected),
    ),
  );
}

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({required this.onTypeSelected, super.key});

  final AccountTypeSelected onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: VanepColors.surfaceGradientTop,
        foregroundColor: VanepColors.textPrimary,
        elevation: 0,
        title: Text(l10n.signupCreateAccount, style: VanepTypography.cardTitle),
      ),
      body: VanepScreenBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(l10n.signupChooseTypeTitle, style: VanepTypography.pageTitle),
            const SizedBox(height: 20),
            for (final type in UserType.signupTypes) ...[
              AccountTypeOption(
                label: accountTypeLabel(l10n, type),
                icon: accountTypeIcon(type),
                onTap: () => onTypeSelected(context, type),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

String accountTypeLabel(AppLocalizations l10n, UserType type) {
  return switch (type) {
    UserType.driver => l10n.signupTypeDriver,
    UserType.assistant => l10n.signupTypeAssistant,
    UserType.client || UserType.admin => l10n.signupTypeClient,
  };
}

IconData accountTypeIcon(UserType type) {
  return switch (type) {
    UserType.driver => Icons.airport_shuttle_outlined,
    UserType.assistant => Icons.support_agent_outlined,
    UserType.client || UserType.admin => Icons.family_restroom_outlined,
  };
}

class AccountTypeOption extends StatelessWidget {
  const AccountTypeOption({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: VanepGlassCard(
        child: Row(
          children: [
            Icon(icon, color: VanepColors.brand),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: VanepTypography.cardTitle)),
            const Icon(Icons.chevron_right, color: VanepColors.textMuted),
          ],
        ),
      ),
    );
  }
}
