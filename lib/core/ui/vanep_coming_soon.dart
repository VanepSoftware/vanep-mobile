import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepComingSoon extends StatelessWidget {
  const VanepComingSoon({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: context.typography.pageTitle),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.typography.cardSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.hourglass_empty,
              color: context.palette.textMuted,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
