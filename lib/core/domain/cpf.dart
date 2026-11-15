const int cpfDigitCount = 11;

String extractCpfDigits(String raw) => raw.replaceAll(RegExp(r'\D'), '');

bool isValidCpf(String raw) {
  final digits = extractCpfDigits(raw);
  if (digits.length != cpfDigitCount) return false;
  if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;
  final numbers = digits.split('').map(int.parse).toList();
  return cpfCheckDigit(numbers.sublist(0, 9)) == numbers[9] &&
      cpfCheckDigit(numbers.sublist(0, 10)) == numbers[10];
}

int cpfCheckDigit(List<int> numbers) {
  var sum = 0;
  for (var index = 0; index < numbers.length; index++) {
    sum += numbers[index] * (numbers.length + 1 - index);
  }
  final remainder = (sum * 10) % 11;
  return remainder == 10 ? 0 : remainder;
}
