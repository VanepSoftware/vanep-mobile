import 'package:flutter/material.dart';

import 'vanep_colors.dart';

class VanepTypography {
  const VanepTypography._();

  static const TextStyle wordmark = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.7,
    height: 1,
  );

  static const TextStyle tagline = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: VanepColors.foreground,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: VanepColors.foreground,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: VanepColors.foreground,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: VanepColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: VanepColors.brand,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: VanepColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: VanepColors.textSecondary,
  );

  static const TextStyle ratingLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: VanepColors.brand,
  );
}
