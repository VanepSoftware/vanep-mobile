import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/user_type.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import 'signup_page.dart';

typedef AccountTypeSelected =
    Future<void> Function(BuildContext context, UserType type);

Future<void> openAccountTypeChoice(
  BuildContext context, {
  AccountTypeSelected onTypeSelected = openPasswordSignup,
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
      backgroundColor: VanepColors.card,
      appBar: const VanepAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          VanepPageHeader(
            title: l10n.signupChooseTypeTitle,
            subtitle: l10n.signupChooseTypeSubtitle,
          ),
          for (final type in UserType.signupTypes) ...[
            AccountTypeOption(
              label: accountTypeLabel(l10n, type),
              description: accountTypeDescription(l10n, type),
              icon: accountTypeIcon(type),
              onTap: () => onTypeSelected(context, type),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.signupAlreadyHaveAccount,
                style: VanepTypography.cardSubtitle.copyWith(fontSize: 15),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: TextButton.styleFrom(
                  foregroundColor: VanepColors.action,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: Text(
                  l10n.loginTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
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

String accountTypeDescription(AppLocalizations l10n, UserType type) {
  return switch (type) {
    UserType.driver => l10n.signupTypeDriverDescription,
    UserType.assistant => l10n.signupTypeAssistantDescription,
    UserType.client || UserType.admin => l10n.signupTypeClientDescription,
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
    required this.description,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return VanepOutlinedPanel(
      onTap: onTap,
      child: Row(
        children: [
          VanepIconBadge(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: VanepTypography.cardTitle),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: VanepTypography.cardSubtitle.copyWith(
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: VanepColors.textMuted),
        ],
      ),
    );
  }
}
