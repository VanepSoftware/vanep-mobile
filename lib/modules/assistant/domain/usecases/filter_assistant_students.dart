import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';

const plainLettersByAccentedLetter = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

String normalizeForSearch(String text) {
  return text
      .toLowerCase()
      .split('')
      .map((letter) => plainLettersByAccentedLetter[letter] ?? letter)
      .join();
}

List<AssistantStudentSummary> filterAssistantStudents(
  List<AssistantStudentSummary> students,
  String query,
) {
  final normalizedQuery = normalizeForSearch(query.trim());
  final matching = students
      .where(
        (student) => normalizeForSearch(student.name).contains(normalizedQuery),
      )
      .toList();
  return matching
    ..sort(
      (first, second) => normalizeForSearch(
        first.name,
      ).compareTo(normalizeForSearch(second.name)),
    );
}
