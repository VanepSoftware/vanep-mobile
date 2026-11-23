import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';

class StudentPriceEditor extends StatefulWidget {
  const StudentPriceEditor({
    required this.students,
    required this.legsLabel,
    required this.onPriceChanged,
    super.key,
  });

  final List<ProposalStudentLine> students;
  final String legsLabel;
  final void Function(String token, int cents)? onPriceChanged;

  @override
  State<StudentPriceEditor> createState() => StudentPriceEditorState();
}

class StudentPriceEditorState extends State<StudentPriceEditor> {
  final controllers = <String, TextEditingController>{};

  @override
  void didUpdateWidget(StudentPriceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final student in widget.students) {
      final controller = controllers[student.token];
      if (controller == null) continue;
      if (parseReaisInput(controller.text) == student.monthlyAmountCents) {
        continue;
      }
      final text = formatReaisInput(student.monthlyAmountCents);
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController controllerFor(ProposalStudentLine student) {
    return controllers.putIfAbsent(
      student.token,
      () => TextEditingController(
        text: formatReaisInput(student.monthlyAmountCents),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onPriceChanged = widget.onPriceChanged;
    return VanepRowsCard(
      rows: [
        for (final student in widget.students)
          StudentPriceRow(
            student: student,
            legsLabel: widget.legsLabel,
            controller: controllerFor(student),
            onChanged: onPriceChanged == null
                ? null
                : (text) => reportStudentPrice(
                    student: student,
                    text: text,
                    onPriceChanged: onPriceChanged,
                  ),
          ),
      ],
    );
  }
}

class StudentPriceRow extends StatelessWidget {
  const StudentPriceRow({
    required this.student,
    required this.legsLabel,
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final ProposalStudentLine student;
  final String legsLabel;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          VanepPersonAvatar(name: student.name, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: VanepTypography.cardTitle),
                Text(
                  legsLabel,
                  style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 112,
            child: ProposalMoneyField(
              semanticLabel: AppLocalizations.of(
                context,
              )!.driverProposalPriceFieldLabel(student.name),
              controller: controller,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class ProposalMoneyField extends StatelessWidget {
  const ProposalMoneyField({
    required this.semanticLabel,
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final String semanticLabel;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(VanepTheme.controlRadius),
      borderSide: BorderSide.none,
    );
    return Semantics(
      label: semanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        enabled: onChanged != null,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: const [ReaisInputFormatter()],
        cursorColor: VanepColors.action,
        style: VanepTypography.cardTitle.copyWith(fontSize: 18),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: VanepColors.surface,
          prefixText: l10n.driverProposalCurrency,
          prefixStyle: VanepTypography.cardSubtitle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(VanepTheme.controlRadius),
            borderSide: const BorderSide(color: VanepColors.action, width: 1.5),
          ),
        ),
      ),
    );
  }
}
