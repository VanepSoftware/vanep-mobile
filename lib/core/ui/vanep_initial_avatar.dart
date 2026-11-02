import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';

const vanepInitialAvatarPalette = <({Color surface, Color text})>[
  (surface: VanepColors.avatarAmberSurface, text: VanepColors.avatarAmberText),
  (surface: VanepColors.avatarBlueSurface, text: VanepColors.avatarBlueText),
  (surface: VanepColors.avatarGreenSurface, text: VanepColors.avatarGreenText),
  (surface: VanepColors.avatarGraySurface, text: VanepColors.avatarGrayText),
];

({Color surface, Color text}) vanepInitialAvatarColors(String seed) {
  final sum = seed.codeUnits.fold<int>(0, (total, unit) => total + unit);
  return vanepInitialAvatarPalette[sum % vanepInitialAvatarPalette.length];
}

String vanepInitialOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}

class VanepInitialAvatar extends StatelessWidget {
  const VanepInitialAvatar({
    required this.name,
    required this.seed,
    this.size = 40,
    super.key,
  });

  final String name;
  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = vanepInitialAvatarColors(seed);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
        ),
        child: Text(
          vanepInitialOf(name),
          style: TextStyle(
            color: colors.text,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
