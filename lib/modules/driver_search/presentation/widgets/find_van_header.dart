import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class FindVanHeader extends StatelessWidget {
  const FindVanHeader({
    required this.onInviteTapped,
    this.showBackButton = false,
    this.onBackTapped,
    super.key,
  });

  final VoidCallback onInviteTapped;
  final bool showBackButton;
  final VoidCallback? onBackTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton) ...[
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: InkWell(
              onTap: onBackTapped ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.palette.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.palette.inputBorder),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: context.palette.textPrimary,
                ),
              ),
            ),
          ),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.navVans,
                style: context.typography.pageTitle.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.findVanPrototypeSubtitle,
                style: context.typography.cardSubtitle.copyWith(
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _InvitePillButton(
          label: l10n.findVanHaveInvite,
          onTap: onInviteTapped,
        ),
      ],
    );
  }
}

class _InvitePillButton extends StatelessWidget {
  const _InvitePillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: context.palette.inputBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                size: 18,
                color: context.palette.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
