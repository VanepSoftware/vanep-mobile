class AssistantLeanSignupRequestDto {
  const AssistantLeanSignupRequestDto({
    required this.inviteToken,
    required this.name,
    required this.birthDate,
    required this.email,
    required this.cpf,
  });

  final String inviteToken;

  final String name;

  final String birthDate;

  final String email;

  final String cpf;

  Map<String, Object?> toJson() {
    return {
      'inviteToken': inviteToken,
      'name': name.trim(),
      'birthDate': birthDate,
      'email': email.trim(),
      'document': cpf.replaceAll(RegExp(r'\D'), ''),
    };
  }
}
