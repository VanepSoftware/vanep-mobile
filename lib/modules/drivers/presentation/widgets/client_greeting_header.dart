import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';

String firstNameOf(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.split(RegExp(r'\s+')).first;
}

class ClientGreetingHeader extends StatelessWidget {
  const ClientGreetingHeader({required this.displayName, super.key});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(
      l10n.homeGreeting(firstNameOf(displayName)),
      style: VanepTypography.pageTitle,
    );
  }
}
