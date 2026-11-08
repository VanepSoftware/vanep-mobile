import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class AvatarTone {
  const AvatarTone(this.background, this.foreground);

  final Color background;

  final Color foreground;
}

List<AvatarTone> avatarTones(VanepPalette palette) {
  return [
    AvatarTone(palette.actionSurface, palette.action),
    AvatarTone(palette.warningSurface, palette.warning),
    AvatarTone(palette.successSurface, palette.success),
  ];
}

AvatarTone avatarToneFor(VanepPalette palette, String name) {
  final tones = avatarTones(palette);
  final seed = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  return tones[seed % tones.length];
}

String initialsOf(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  if (words.length == 1) return words.single[0].toUpperCase();
  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

class VanepPersonAvatar extends StatelessWidget {
  const VanepPersonAvatar({
    required this.name,
    this.size = 40,
    this.dimmed = false,
    super.key,
  });

  final String name;
  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tone = avatarToneFor(context.palette, name);
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: VanepAvatar(
        size: size,
        initials: initialsOf(name),
        backgroundColor: tone.background,
        foregroundColor: tone.foreground,
      ),
    );
  }
}

class VanepAvatarStack extends StatelessWidget {
  const VanepAvatarStack({
    required this.names,
    this.dimmedNames = const {},
    this.hiddenCount = 0,
    this.size = 36,
    this.step,
    super.key,
  });

  final List<String> names;
  final Set<String> dimmedNames;
  final int hiddenCount;
  final double size;
  final double? step;

  @override
  Widget build(BuildContext context) {
    final step = this.step ?? size * 0.62;
    final avatars = <Widget>[
      for (final name in names)
        VanepPersonAvatar(
          name: name,
          size: size - 3,
          dimmed: dimmedNames.contains(name),
        ),
      if (hiddenCount > 0)
        VanepAvatar(
          size: size - 3,
          initials: '+$hiddenCount',
          backgroundColor: context.palette.avatarPlaceholder,
          foregroundColor: context.palette.textSecondary,
        ),
    ];
    return SizedBox(
      width: size + step * (avatars.length - 1),
      height: size,
      child: Stack(
        children: [
          for (final (index, avatar) in avatars.indexed)
            Positioned(
              left: step * index,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.palette.card,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: avatar,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
