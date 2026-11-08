import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/money_input_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

int? parseNumberInput(String text) => int.tryParse(text.trim());

class ComposerMoneyField extends StatefulWidget {
  const ComposerMoneyField({
    required this.label,
    required this.cents,
    required this.onChanged,
    this.isRequired = false,
    this.hintText,
    this.errorText,
    super.key,
  });

  final String label;
  final int? cents;
  final ValueChanged<int?> onChanged;
  final bool isRequired;
  final String? hintText;
  final String? errorText;

  @override
  State<ComposerMoneyField> createState() => ComposerMoneyFieldState();
}

class ComposerMoneyFieldState extends State<ComposerMoneyField> {
  final controller = TextEditingController();

  bool hasInitialText = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cents = widget.cents;
    if (hasInitialText) return;
    hasInitialText = true;
    if (cents != null) {
      controller.text = formatMoneyInput(
        AppLocalizations.of(context)!.localeName,
        cents,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepTextField(
      label: widget.label,
      controller: controller,
      isRequired: widget.isRequired,
      hintText: widget.hintText,
      errorText: widget.errorText,
      keyboardType: TextInputType.number,
      inputFormatters: [MoneyInputFormatter(localeName: l10n.localeName)],
      onChanged: (text) => widget.onChanged(parseMoneyInput(text)),
    );
  }
}

class ComposerNumberField extends StatefulWidget {
  const ComposerNumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final String? errorText;

  @override
  State<ComposerNumberField> createState() => ComposerNumberFieldState();
}

class ComposerNumberFieldState extends State<ComposerNumberField> {
  late final controller = TextEditingController(
    text: widget.value?.toString() ?? '',
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VanepTextField(
      label: widget.label,
      controller: controller,
      isRequired: true,
      errorText: widget.errorText,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      onChanged: (text) => widget.onChanged(parseNumberInput(text)),
    );
  }
}

class ComposerDateField extends StatefulWidget {
  const ComposerDateField({
    required this.label,
    required this.date,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
    this.errorText,
    super.key,
  });

  final String label;
  final DateTime? date;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPicked;
  final String? errorText;

  @override
  State<ComposerDateField> createState() => ComposerDateFieldState();
}

class ComposerDateFieldState extends State<ComposerDateField> {
  final controller = TextEditingController();

  void showDate() {
    final date = widget.date;
    controller.text = date == null
        ? ''
        : formatNumericDate(AppLocalizations.of(context)!, date);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showDate();
  }

  @override
  void didUpdateWidget(ComposerDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) showDate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = widget.date;
    final initial = date == null || date.isBefore(widget.firstDate)
        ? widget.firstDate
        : date.isAfter(widget.lastDate)
        ? widget.lastDate
        : date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    if (picked != null) widget.onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date = widget.date;
    controller.text = date == null ? '' : formatNumericDate(l10n, date);
    return VanepTextField(
      label: widget.label,
      controller: controller,
      isRequired: true,
      readOnly: true,
      errorText: widget.errorText,
      onTap: pickDate,
      onChanged: (_) {},
      suffix: const Icon(Icons.calendar_today_outlined),
    );
  }
}

class ComposerFieldError extends StatelessWidget {
  const ComposerFieldError({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: VanepTypography.cardSubtitle.copyWith(color: VanepColors.danger),
      ),
    );
  }
}
