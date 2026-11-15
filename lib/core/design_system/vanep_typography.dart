import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';

@immutable
class VanepTypography {
  const VanepTypography(this.palette);

  final VanepPalette palette;

  TextStyle get wordmark => const TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.7,
    height: 1,
  );

  TextStyle get tagline => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: palette.textSecondary,
  );

  TextStyle get heading => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: palette.textPrimary,
  );

  TextStyle get body => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: palette.textPrimary,
  );

  TextStyle get button =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  TextStyle get pageTitle => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: palette.textPrimary,
  );

  TextStyle get sectionTitle => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: palette.textPrimary,
  );

  TextStyle get cardTitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: palette.textPrimary,
  );

  TextStyle get cardSubtitle => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: palette.textSecondary,
  );

  TextStyle get ratingLabel => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: palette.textPrimary,
  );

  TextStyle get fieldLabel => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: palette.textPrimary,
  );

  TextStyle get fieldValue => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: palette.textPrimary,
  );

  TextStyle get loginTitle => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: palette.textPrimary,
  );

  TextStyle get overline => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.9,
    color: palette.action,
  );

  TextStyle get linkAction => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: palette.action,
  );
}
