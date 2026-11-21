import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_primitives.dart';

// TODO(VAN-66): Replace static onboarding step breakdown (3 of 6, Sprinter 2021, CNH/CRLV progress)
// once the driver onboarding summary endpoint exposes per-step completion and vehicle metadata.
class DriverIncompleteCard extends StatelessWidget {
  const DriverIncompleteCard({required this.navigation, super.key});

  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DriverNavyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.driverHomeIncompleteOverline.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.72,
              color: Color(0xFF8EC5FF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.driverHomeIncompleteHeadline,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.5,
              minHeight: 6,
              backgroundColor: Color(0x2EFFFFFF),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8EC5FF)),
            ),
          ),
          const SizedBox(height: 16),
          DriverIncompleteDoneStepRow(title: l10n.driverHomeIncompleteStep1),
          const SizedBox(height: 10),
          DriverIncompleteDoneStepRow(title: l10n.driverHomeIncompleteStep2),
          const SizedBox(height: 10),
          DriverIncompleteDoneStepRow(title: l10n.driverHomeIncompleteStep3),
          const SizedBox(height: 10),
          DriverIncompleteNumberedStepRow(
            number: '4',
            title: l10n.driverHomeIncompleteStep4Title,
            subtitle: l10n.driverHomeIncompleteStep4Hint,
            trailingBadge: l10n.driverHomeIncompleteStepNow,
            highlighted: true,
          ),
          const SizedBox(height: 10),
          DriverIncompleteNumberedStepRow(
            number: '5',
            title: l10n.driverHomeIncompleteStep5Title,
            subtitle: l10n.driverHomeIncompleteStep5Hint,
            highlighted: false,
          ),
          const SizedBox(height: 10),
          DriverIncompleteNumberedStepRow(
            number: '6',
            title: l10n.driverHomeIncompleteStep6Title,
            subtitle: l10n.driverHomeIncompleteStep6Hint,
            highlighted: false,
          ),
          const SizedBox(height: 18),
          Semantics(
            label: l10n.driverHomeCompleteRegistration,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: DriverHomeTokens.brand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => navigation.openShortcut(Shortcut.documents),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.driverHomeIncompleteSendCnh,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DriverHomeTokens.brand,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: DriverHomeTokens.brand,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.driverHomeIncompleteFooter,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xB8FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverIncompleteDoneStepRow extends StatelessWidget {
  const DriverIncompleteDoneStepRow({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF8EC5FF),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: DriverHomeTokens.brand),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xD1FFFFFF),
          ),
        ),
      ),
    ],
  );
}

class DriverIncompleteNumberedStepRow extends StatelessWidget {
  const DriverIncompleteNumberedStepRow({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    this.trailingBadge,
    super.key,
  });

  final String number;
  final String title;
  final String subtitle;
  final bool highlighted;
  final String? trailingBadge;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: highlighted
                ? const Color(0xFF8EC5FF)
                : const Color(0x52FFFFFF),
            width: highlighted ? 2 : 1.5,
          ),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: highlighted ? Colors.white : const Color(0xB3FFFFFF),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xBAFFFFFF),
              ),
            ),
          ],
        ),
      ),
      if (trailingBadge != null) ...[
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            trailingBadge!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8EC5FF),
            ),
          ),
        ),
      ],
    ],
  );
}

// TODO(VAN-66): Replace static submission timestamp ("12/10 · 18h40") with the backend
// submittedAt timestamp from the driver registration review endpoint.
class DriverUnderReviewCard extends StatelessWidget {
  const DriverUnderReviewCard({required this.navigation, super.key});

  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DriverHomeTokens.surface,
        borderRadius: BorderRadius.circular(DriverHomeTokens.radiusLg),
        border: Border.all(color: DriverHomeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: DriverHomeTokens.actionSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  color: DriverHomeTokens.action,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: l10n.driverHomeReviewTitle,
                      child: Text(
                        l10n.driverHomeUnderReviewOverline.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.72,
                          color: DriverHomeTokens.action,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.driverHomeUnderReviewHeadline,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: DriverHomeTokens.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.driverHomeUnderReviewSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: DriverHomeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFECEEF1)),
          ),
          const DriverReviewTimeline(isRejected: false),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => navigation.openShortcut(Shortcut.documents),
            child: Text(
              l10n.driverHomeSeeSentDocuments,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DriverHomeTokens.action,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverRejectedCard extends StatelessWidget {
  const DriverRejectedCard({
    required this.data,
    required this.navigation,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reason = data.rejectionReason ?? l10n.driverHomeRejectedDescription;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: DriverHomeTokens.danger,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.driverHomeRejectedTitle,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: DriverHomeTokens.textPrimary,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DriverHomeTokens.danger,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFEFC9C3)),
        ),
        const DriverReviewTimeline(isRejected: true),
        const SizedBox(height: 16),
        VanepPrimaryButton(
          label: l10n.driverHomeResubmit,
          onPressed: navigation.correctAndResubmit,
        ),
      ],
    );
  }
}

class DriverReviewTimeline extends StatelessWidget {
  const DriverReviewTimeline({required this.isRejected, super.key});

  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: DriverHomeTokens.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.driverHomeTimelineSent,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.textPrimary,
                ),
              ),
            ),
            Text(
              l10n.driverHomeTimelineSentTime,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DriverHomeTokens.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRejected
                      ? DriverHomeTokens.danger
                      : DriverHomeTokens.action,
                  width: 2,
                ),
              ),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isRejected
                      ? DriverHomeTokens.danger
                      : DriverHomeTokens.action,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isRejected
                    ? l10n.driverHomeRejectedTitle
                    : l10n.driverHomeTimelineInReview,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.textPrimary,
                ),
              ),
            ),
            Text(
              l10n.driverHomeIncompleteStepNow,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isRejected
                    ? DriverHomeTokens.danger
                    : DriverHomeTokens.action,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC8CDD5), width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.driverHomeTimelineApproved,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DriverHomeTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.driverHomeTimelineApprovedHint,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: DriverHomeTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DriverBuildingRouteCard extends StatelessWidget {
  const DriverBuildingRouteCard({required this.navigation, super.key});

  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DriverNavyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: l10n.driverHomeBuildingTitle,
            child: Text(
              l10n.driverHomeBuildingOverline.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.72,
                color: Color(0xFF8EC5FF),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.driverHomeBuildingHeadline,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          DriverBuildingStepTile(
            number: '1',
            title: l10n.driverHomeBuildingStep1Title,
            subtitle: l10n.driverHomeBuildingStep1Hint,
            active: true,
          ),
          const SizedBox(height: 10),
          DriverBuildingStepTile(
            number: '2',
            title: l10n.driverHomeBuildingStep2Title,
            subtitle: l10n.driverHomeBuildingStep2Hint,
            active: false,
          ),
          const SizedBox(height: 10),
          DriverBuildingStepTile(
            number: '3',
            title: l10n.driverHomeBuildingStep3Title,
            subtitle: l10n.driverHomeBuildingStep3Hint,
            active: false,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: DriverHomeTokens.brand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => navigation.openShortcut(Shortcut.students),
              icon: const Icon(
                Icons.person_add_outlined,
                size: 20,
                color: DriverHomeTokens.brand,
              ),
              label: Text(
                l10n.driverHomeAddStudents,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.brand,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0x14FFFFFF),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x29FFFFFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => navigation.openShortcut(Shortcut.students),
              icon: const Icon(
                Icons.share_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                l10n.driverHomeShareParentGroupLink,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverBuildingStepTile extends StatelessWidget {
  const DriverBuildingStepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.active,
    super.key,
  });

  final String number;
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
      border: Border.all(color: const Color(0x24FFFFFF)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8EC5FF) : Colors.transparent,
            shape: BoxShape.circle,
            border: active
                ? null
                : Border.all(color: const Color(0x66FFFFFF), width: 1.5),
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: active ? DriverHomeTokens.brand : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xBAFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
