import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/usecases/verify_email_code.dart';
import 'account_text_field.dart';

class VerificationCodeField extends StatelessWidget {
  const VerificationCodeField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    super.key,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AccountTextField(
      label: label,
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: enabled,
      errorText: errorText,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(verificationCodeLength),
      ],
    );
  }
}
