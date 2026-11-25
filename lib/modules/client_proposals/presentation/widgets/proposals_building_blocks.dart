import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';

class ProposalDriverHeader extends StatelessWidget {
  const ProposalDriverHeader({
    required this.request,
    this.subtitle,
    this.subtitleLeading,
    this.trailing,
    this.showVerified = false,
    super.key,
  });

  final ClientServiceRequest request;
  final String? subtitle;
  final Widget? subtitleLeading;
  final Widget? trailing;
  final bool showVerified;

  @override
  Widget build(BuildContext context) {
    final rating = request.driverRating;
    final effectiveSubtitle =
        subtitle ??
        (rating == null
            ? null
            : formatProposalRating(AppLocalizations.of(context)!, rating));
    return ProposalPersonHeader(
      avatar: VanepPersonAvatar(name: request.driverName),
      name: request.driverName,
      nameTrailing: showVerified
          ? Icon(Icons.verified, size: 16, color: context.palette.action)
          : null,
      subtitle: effectiveSubtitle,
      subtitleLeading:
          subtitleLeading ??
          (subtitle == null && rating != null
              ? const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: VanepColors.ratingStar,
                )
              : null),
      trailing: trailing,
    );
  }
}
