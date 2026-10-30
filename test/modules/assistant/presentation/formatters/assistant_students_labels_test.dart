import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_students_labels.dart';

void main() {
  test('always picks the same tone for the same student', () {
    expect(
      studentAvatarToneOf('student-ana'),
      studentAvatarToneOf('student-ana'),
    );
  });

  test('picks a tone from the palette', () {
    expect(studentAvatarTones, contains(studentAvatarToneOf('student-lais')));
  });
}
