class AssistantLeanSignupRequestDto {
  const AssistantLeanSignupRequestDto({
    required this.inviteToken,
    required this.name,
    required this.birthDate,
    required this.email,
    required this.cpf,
    required this.password,
    required this.acceptTerms,
  });

  final String inviteToken;

  final String name;

  final String birthDate;

  final String email;

  final String cpf;

  final String password;

  final bool acceptTerms;

  Map<String, Object?> toJson() {
    return {
      'inviteToken': inviteToken,
      'name': name.trim(),
      'birthDate': birthDate,
      'email': email.trim(),
      'password': password,
      'document': cpf.replaceAll(RegExp(r'\D'), ''),
      'acceptTerms': acceptTerms,
    };
  }
}
