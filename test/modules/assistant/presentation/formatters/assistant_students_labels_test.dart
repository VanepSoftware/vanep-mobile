import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_students_labels.dart';

void main() {
  const palette = VanepPalette.light;

  test('always picks the same tone for the same student', () {
    expect(
      studentAvatarToneOf(palette, 'student-ana'),
      studentAvatarToneOf(palette, 'student-ana'),
    );
  });

  test('picks a tone from the palette', () {
    expect(
      studentAvatarTonesOf(palette),
      contains(studentAvatarToneOf(palette, 'student-lais')),
    );
  });

  test('follows the dark palette too', () {
    expect(
      studentAvatarTonesOf(VanepPalette.dark),
      contains(studentAvatarToneOf(VanepPalette.dark, 'student-lais')),
    );
  });
}
