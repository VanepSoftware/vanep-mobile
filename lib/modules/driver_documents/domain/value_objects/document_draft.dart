import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

sealed class DocumentDraft extends Equatable {
  const DocumentDraft();

  DocumentType get type;
}

final class PersonalDocumentDraft extends DocumentDraft {
  const PersonalDocumentDraft({
    required this.type,
    this.documentNumber,
    this.expiresAt,
  });

  @override
  final DocumentType type;
  final String? documentNumber;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [type, documentNumber, expiresAt];
}

final class VehicleDocumentDraft extends DocumentDraft {
  const VehicleDocumentDraft({
    required this.vehicleToken,
    required this.type,
    this.documentNumber,
    this.expiresAt,
  });

  final String vehicleToken;
  @override
  final DocumentType type;
  final String? documentNumber;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [vehicleToken, type, documentNumber, expiresAt];
}

final class CnhDraft extends DocumentDraft {
  const CnhDraft({
    required this.registrationNumber,
    required this.category,
    required this.issueDate,
    required this.validUntil,
    this.issuingState,
  });

  final String registrationNumber;
  final String category;
  final DateTime? issueDate;
  final DateTime? validUntil;
  final String? issuingState;

  @override
  DocumentType get type => DocumentType.driverLicense;

  @override
  List<Object?> get props => [
    registrationNumber,
    category,
    issueDate,
    validUntil,
    issuingState,
  ];
}
