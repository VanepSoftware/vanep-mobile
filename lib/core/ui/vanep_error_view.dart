import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepErrorView extends StatelessWidget {
  const VanepErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.cardSubtitle,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(retryLabel, style: context.typography.ratingLabel),
          ),
        ],
      ),
    );
  }
}
