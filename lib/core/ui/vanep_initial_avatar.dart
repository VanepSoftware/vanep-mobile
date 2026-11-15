import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

List<({Color surface, Color text})> vanepInitialAvatarTones(
  VanepPalette palette,
) {
  return [
    (surface: palette.avatarAmberSurface, text: palette.avatarAmberText),
    (surface: palette.avatarBlueSurface, text: palette.avatarBlueText),
    (surface: palette.avatarGreenSurface, text: palette.avatarGreenText),
    (surface: palette.avatarGraySurface, text: palette.avatarGrayText),
  ];
}

({Color surface, Color text}) vanepInitialAvatarColors(
  VanepPalette palette,
  String seed,
) {
  final tones = vanepInitialAvatarTones(palette);
  final sum = seed.codeUnits.fold<int>(0, (total, unit) => total + unit);
  return tones[sum % tones.length];
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
    final colors = vanepInitialAvatarColors(context.palette, seed);
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
