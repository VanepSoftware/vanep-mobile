const accentedLetters = 'áàâãäåéèêëíìîïóòôõöúùûüçñ';

const plainLetters = 'aaaaaaeeeeiiiiooooouuuucn';

String foldForSearch(String text) {
  final lower = text.trim().toLowerCase();
  final folded = StringBuffer();
  for (final rune in lower.runes) {
    final letter = String.fromCharCode(rune);
    final index = accentedLetters.indexOf(letter);
    folded.write(index < 0 ? letter : plainLetters[index]);
  }
  return folded.toString();
}
