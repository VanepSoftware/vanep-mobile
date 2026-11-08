import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/proposal_detail_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_comparison.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';

const comparisonArrowWidth = 32.0;

const comparisonArrowSize = 16.0;

const previousVersionLabelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  letterSpacing: 0.9,
  color: VanepColors.textSecondary,
);

class ProposalComparisonPage extends StatelessWidget {
  const ProposalComparisonPage({
    required this.previous,
    required this.current,
    super.key,
  });

  final Proposal previous;
  final Proposal current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final changes = compareProposalVersions(previous, current);

    return Scaffold(
      backgroundColor: VanepColors.surface,
      appBar: VanepAppBar(
        title: l10n.proposalComparisonTitle,
        caption: l10n.proposalComparisonVersions(
          previous.version,
          current.version,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          if (changes.isEmpty)
            DetailNotice(text: l10n.proposalComparisonNoChanges)
          else
            VanepCard(
              child: ComparisonTable(
                fields: changes,
                previous: previous,
                current: current,
              ),
            ),
        ],
      ),
    );
  }
}

class ComparisonColumns extends StatelessWidget {
  const ComparisonColumns({
    required this.previous,
    required this.current,
    this.showsArrow = false,
    super.key,
  });

  final Widget previous;
  final Widget current;
  final bool showsArrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: previous),
        SizedBox(
          width: comparisonArrowWidth,
          child: showsArrow ? const ComparisonArrow() : null,
        ),
        Expanded(child: current),
      ],
    );
  }
}

class ComparisonArrow extends StatelessWidget {
  const ComparisonArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 1),
      child: Icon(
        Icons.arrow_forward,
        size: comparisonArrowSize,
        color: VanepColors.textMuted,
      ),
    );
  }
}

class ComparisonVersionHeader extends StatelessWidget {
  const ComparisonVersionHeader({
    required this.previous,
    required this.current,
    super.key,
  });

  final Proposal previous;
  final Proposal current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ComparisonColumns(
      previous: Text(
        l10n.proposalDetailVersion(previous.version).toUpperCase(),
        style: previousVersionLabelStyle,
      ),
      current: Text(
        l10n.proposalDetailVersion(current.version).toUpperCase(),
        style: VanepTypography.overline,
      ),
    );
  }
}

class ComparisonTable extends StatelessWidget {
  const ComparisonTable({
    required this.fields,
    required this.previous,
    required this.current,
    super.key,
  });

  final List<ProposalComparisonField> fields;
  final Proposal previous;
  final Proposal current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ComparisonVersionHeader(previous: previous, current: current),
        for (final field in fields) ...[
          const Divider(height: 24, color: VanepColors.divider),
          if (field == ProposalComparisonField.schedule)
            ScheduleComparisonRow(previous: previous, current: current)
          else
            ComparisonRow(
              label: comparisonFieldLabel(l10n, field),
              before: formatComparisonLines(l10n, field, previous),
              now: formatComparisonLines(l10n, field, current),
            ),
        ],
      ],
    );
  }
}

class ScheduleComparisonRow extends StatelessWidget {
  const ScheduleComparisonRow({
    required this.previous,
    required this.current,
    super.key,
  });

  final Proposal previous;
  final Proposal current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final changes = findScheduleChanges(previous, current);
    final students = current.items.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ComparisonFieldLabel(text: l10n.proposalDetailScheduleTitle),
        for (final (index, change) in changes.indexed) ...[
          SizedBox(height: index == 0 ? 10 : 16),
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  formatScheduleChangeTitle(
                    l10n,
                    change,
                    namesChild:
                        students > 1 &&
                        change.dependentFirstNames.length < students,
                  ),
                  style: VanepTypography.cardSubtitle.copyWith(
                    color: VanepColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ComparisonValues(
                  before: [formatClockTime(change.before)],
                  now: [formatClockTime(change.after)],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class ComparisonFieldLabel extends StatelessWidget {
  const ComparisonFieldLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: VanepTypography.cardSubtitle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class ComparisonValues extends StatelessWidget {
  const ComparisonValues({required this.before, required this.now, super.key});

  final List<String> before;
  final List<String> now;

  @override
  Widget build(BuildContext context) {
    return ComparisonColumns(
      showsArrow: true,
      previous: ComparisonLines(
        lines: before,
        style: VanepTypography.cardSubtitle.copyWith(
          color: VanepColors.textSecondary,
        ),
      ),
      current: ComparisonLines(
        lines: now,
        style: VanepTypography.cardSubtitle.copyWith(
          color: VanepColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ComparisonRow extends StatelessWidget {
  const ComparisonRow({
    required this.label,
    required this.before,
    required this.now,
    super.key,
  });

  final String label;
  final List<String> before;
  final List<String> now;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ComparisonFieldLabel(text: label),
          const SizedBox(height: 6),
          ComparisonValues(before: before, now: now),
        ],
      ),
    );
  }
}

class ComparisonLines extends StatelessWidget {
  const ComparisonLines({required this.lines, required this.style, super.key});

  final List<String> lines;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, line) in lines.indexed) ...[
          if (index > 0) const SizedBox(height: 4),
          Text(line, style: style),
        ],
      ],
    );
  }
}
