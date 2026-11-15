import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepWordmark extends StatelessWidget {
  const VanepWordmark({this.color, this.fontSize, super.key});

  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'vanep',
            style: TextStyle(color: color ?? context.palette.textPrimary),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(color: context.palette.action),
          ),
        ],
        style: context.typography.wordmark.copyWith(fontSize: fontSize),
      ),
    );
  }
}
