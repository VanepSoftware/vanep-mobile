import 'package:equatable/equatable.dart';

enum ContractReadinessSubject {
  client,
  dependent;

  static ContractReadinessSubject? fromApi(Object? raw) {
    return switch (raw) {
      'CLIENT' => ContractReadinessSubject.client,
      'DEPENDENT' => ContractReadinessSubject.dependent,
      _ => null,
    };
  }
}

enum ContractReadinessField {
  document,
  phone,
  address,
  birthDate,
  school,
  schoolDays;

  static ContractReadinessField? fromApi(Object? raw) {
    return switch (raw) {
      'DOCUMENT' => ContractReadinessField.document,
      'PHONE' => ContractReadinessField.phone,
      'ADDRESS' => ContractReadinessField.address,
      'BIRTH_DATE' => ContractReadinessField.birthDate,
      'SCHOOL' => ContractReadinessField.school,
      'SCHOOL_DAYS' => ContractReadinessField.schoolDays,
      _ => null,
    };
  }
}

class ReadinessGap extends Equatable {
  const ReadinessGap({
    required this.subject,
    required this.field,
    this.dependentToken,
  });

  final ContractReadinessSubject subject;

  final ContractReadinessField field;

  final String? dependentToken;

  @override
  List<Object?> get props => [subject, field, dependentToken];
}

class ContractReadiness extends Equatable {
  const ContractReadiness({required this.ready, required this.gaps});

  final bool ready;

  final List<ReadinessGap> gaps;

  Set<ContractReadinessField> gapsOfDependent(String dependentToken) {
    return {
      for (final gap in gaps)
        if (gap.subject == ContractReadinessSubject.dependent &&
            gap.dependentToken == dependentToken)
          gap.field,
    };
  }

  @override
  List<Object?> get props => [ready, gaps];
}
