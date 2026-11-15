import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

extension VanepThemeContext on BuildContext {
  VanepPalette get palette =>
      Theme.of(this).extension<VanepPalette>() ?? VanepPalette.light;

  VanepTypography get typography => VanepTypography(palette);

  SystemUiOverlayStyle get surfaceOverlayStyle =>
      Theme.of(this).brightness == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}
