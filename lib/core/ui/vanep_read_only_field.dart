import 'package:flutter/material.dart';

import 'vanep_text_field.dart';

class VanepReadOnlyField extends StatefulWidget {
  const VanepReadOnlyField({
    required this.label,
    required this.value,
    this.onTap,
    this.enabled = true,
    this.hintText,
    this.errorText,
    this.labelTrailing,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool enabled;
  final String? hintText;
  final String? errorText;
  final Widget? labelTrailing;

  @override
  State<VanepReadOnlyField> createState() => VanepReadOnlyFieldState();
}

class VanepReadOnlyFieldState extends State<VanepReadOnlyField> {
  late final TextEditingController controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(VanepReadOnlyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.text != widget.value) controller.text = widget.value;
  }

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
      onChanged: (_) {},
      readOnly: true,
      enabled: widget.enabled,
      hintText: widget.hintText,
      errorText: widget.errorText,
      labelTrailing: widget.labelTrailing,
      onTap: widget.onTap,
    );
  }
}
