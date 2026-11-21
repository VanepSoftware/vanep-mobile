import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_field_rules.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

import '../../driver_documents_fixture.dart';

Map<DocumentField, DocumentFieldError> validatePersonal(
  DocumentType type, {
  String? number,
  DateTime? expiresAt,
}) {
  return validateDocumentDraft(
    PersonalDocumentDraft(
      type: type,
      documentNumber: number,
      expiresAt: expiresAt,
    ),
    testAsOf,
  );
}

Map<DocumentField, DocumentFieldError> validateVehicle(
  DocumentType type, {
  String? number,
  DateTime? expiresAt,
}) {
  return validateDocumentDraft(
    VehicleDocumentDraft(
      vehicleToken: 'sprinter',
      type: type,
      documentNumber: number,
      expiresAt: expiresAt,
    ),
    testAsOf,
  );
}

Map<DocumentField, DocumentFieldError> validateCnh({
  String registration = '01234567890',
  String category = 'D',
  DateTime? issueDate,
  DateTime? validUntil,
  String? issuingState,
}) {
  return validateDocumentDraft(
    CnhDraft(
      registrationNumber: registration,
      category: category,
      issueDate: issueDate ?? DateTime(2024, 3, 1),
      validUntil: validUntil ?? DateTime(2031, 8, 12),
      issuingState: issuingState,
    ),
    testAsOf,
  );
}

void main() {
  group('fields of each type', () {
    test('person and van documents ask only what the back takes', () {
      expect(fieldRulesFor(DocumentType.criminalRecord), const [
        FieldRule(DocumentField.documentNumber, required: false),
        FieldRule(DocumentField.expiresAt, required: false),
      ]);
      expect(fieldRulesFor(DocumentType.schoolDriverCourse), const [
        FieldRule(DocumentField.documentNumber, required: false),
        FieldRule(DocumentField.expiresAt, required: false),
      ]);
      expect(fieldRulesFor(DocumentType.municipalAuthorization), const [
        FieldRule(DocumentField.documentNumber, required: true),
        FieldRule(DocumentField.expiresAt, required: false),
      ]);
      expect(fieldRulesFor(DocumentType.vehicleRegistration), const [
        FieldRule(DocumentField.expiresAt, required: true),
        FieldRule(DocumentField.documentNumber, required: false),
      ]);
      expect(fieldRulesFor(DocumentType.vehicleInspection), const [
        FieldRule(DocumentField.documentNumber, required: false),
        FieldRule(DocumentField.expiresAt, required: true),
      ]);
      expect(fieldRulesFor(DocumentType.schoolVehicleAuthorization), const [
        FieldRule(DocumentField.documentNumber, required: true),
        FieldRule(DocumentField.expiresAt, required: true),
      ]);
    });

    test('the CNH has its own fields', () {
      expect(fieldRulesFor(DocumentType.driverLicense), const [
        FieldRule(DocumentField.cnhRegistrationNumber, required: true),
        FieldRule(DocumentField.cnhCategory, required: true),
        FieldRule(DocumentField.cnhIssueDate, required: true),
        FieldRule(DocumentField.expiresAt, required: true),
        FieldRule(DocumentField.cnhIssuingState, required: false),
      ]);
    });
  });

  group('required fields', () {
    test('the municipal authorization needs its number', () {
      expect(validatePersonal(DocumentType.municipalAuthorization), {
        DocumentField.documentNumber: DocumentFieldError.required,
      });
      expect(
        validatePersonal(DocumentType.municipalAuthorization, number: '  '),
        {DocumentField.documentNumber: DocumentFieldError.required},
      );
    });

    test('the school vehicle authorization needs number and expiry', () {
      expect(validateVehicle(DocumentType.schoolVehicleAuthorization), {
        DocumentField.documentNumber: DocumentFieldError.required,
        DocumentField.expiresAt: DocumentFieldError.required,
      });
    });

    test('a criminal record can go with nothing filled', () {
      expect(validatePersonal(DocumentType.criminalRecord), isEmpty);
    });

    test('a number above 64 characters is too long', () {
      expect(validatePersonal(DocumentType.criminalRecord, number: 'A' * 65), {
        DocumentField.documentNumber: DocumentFieldError.tooLong,
      });
    });
  });

  group('date limits', () {
    test('no expiry before today', () {
      expect(
        validatePersonal(
          DocumentType.criminalRecord,
          expiresAt: DateTime(2026, 11, 19),
        ),
        {DocumentField.expiresAt: DocumentFieldError.alreadyExpired},
      );
      expect(
        validatePersonal(DocumentType.criminalRecord, expiresAt: testAsOf),
        isEmpty,
      );
    });

    test('the criminal record has no upper limit', () {
      expect(
        validatePersonal(
          DocumentType.criminalRecord,
          expiresAt: DateTime(2060, 1, 1),
        ),
        isEmpty,
      );
    });

    test('CRLV up to December 31 of next year', () {
      expect(
        validateVehicle(
          DocumentType.vehicleRegistration,
          expiresAt: DateTime(2027, 12, 31),
        ),
        isEmpty,
      );
      expect(
        validateVehicle(
          DocumentType.vehicleRegistration,
          expiresAt: DateTime(2028, 1, 1),
        ),
        {DocumentField.expiresAt: DocumentFieldError.tooFar},
      );
    });

    test('inspection up to today plus 7 months', () {
      expect(
        validateVehicle(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2027, 6, 20),
        ),
        isEmpty,
      );
      expect(
        validateVehicle(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2027, 6, 21),
        ),
        {DocumentField.expiresAt: DocumentFieldError.tooFar},
      );
    });

    test('school vehicle authorization up to today plus 2 years', () {
      expect(
        validateVehicle(
          DocumentType.schoolVehicleAuthorization,
          number: 'DF-1',
          expiresAt: DateTime(2028, 11, 20),
        ),
        isEmpty,
      );
      expect(
        validateVehicle(
          DocumentType.schoolVehicleAuthorization,
          number: 'DF-1',
          expiresAt: DateTime(2028, 11, 21),
        ),
        {DocumentField.expiresAt: DocumentFieldError.tooFar},
      );
    });

    test('course and municipal authorization up to today plus 5 years', () {
      expect(
        validatePersonal(
          DocumentType.schoolDriverCourse,
          expiresAt: DateTime(2031, 11, 20),
        ),
        isEmpty,
      );
      expect(
        validatePersonal(
          DocumentType.schoolDriverCourse,
          expiresAt: DateTime(2031, 11, 21),
        ),
        {DocumentField.expiresAt: DocumentFieldError.tooFar},
      );
      expect(
        validatePersonal(
          DocumentType.municipalAuthorization,
          number: 'ALV-9',
          expiresAt: DateTime(2031, 11, 21),
        ),
        {DocumentField.expiresAt: DocumentFieldError.tooFar},
      );
    });

    test('a month that ends earlier clamps to its last day, like the back', () {
      expect(
        latestExpiryFor(DocumentType.vehicleInspection, DateTime(2026, 7, 31)),
        DateTime(2027, 2, 28),
      );
    });
  });

  group('CNH', () {
    test('a valid CNH passes', () {
      expect(validateCnh(), isEmpty);
    });

    test('the registration number has 9 to 11 digits', () {
      expect(validateCnh(registration: '12345678'), {
        DocumentField.cnhRegistrationNumber: DocumentFieldError.invalidFormat,
      });
      expect(validateCnh(registration: '123456789'), isEmpty);
      expect(validateCnh(registration: '12345-6789'), {
        DocumentField.cnhRegistrationNumber: DocumentFieldError.invalidFormat,
      });
    });

    test('the category must be one of the CNH categories', () {
      expect(validateCnh(category: 'F'), {
        DocumentField.cnhCategory: DocumentFieldError.invalidFormat,
      });
      expect(validateCnh(category: ''), {
        DocumentField.cnhCategory: DocumentFieldError.required,
      });
    });

    test('the issue date cannot be in the future', () {
      expect(
        validateCnh(
          issueDate: DateTime(2026, 11, 21),
          validUntil: DateTime(2030, 1, 1),
        ),
        {DocumentField.cnhIssueDate: DocumentFieldError.inFuture},
      );
    });

    test('validity after the issue date and up to ten years after it', () {
      expect(
        validateCnh(
          issueDate: DateTime(2024, 3, 1),
          validUntil: DateTime(2034, 3, 1),
        ),
        isEmpty,
      );
      expect(
        validateCnh(
          issueDate: DateTime(2024, 3, 1),
          validUntil: DateTime(2034, 3, 2),
        ),
        {DocumentField.expiresAt: DocumentFieldError.tooFar},
      );
      expect(
        validateCnh(
          issueDate: DateTime(2026, 11, 20),
          validUntil: DateTime(2026, 11, 20),
        ),
        {DocumentField.expiresAt: DocumentFieldError.beforeIssue},
      );
    });

    test('an expired CNH is refused', () {
      expect(
        validateCnh(
          issueDate: DateTime(2016, 3, 1),
          validUntil: DateTime(2026, 3, 1),
        ),
        {DocumentField.expiresAt: DocumentFieldError.alreadyExpired},
      );
    });

    test('the issuing state is two letters when filled', () {
      expect(validateCnh(issuingState: 'SP'), isEmpty);
      expect(validateCnh(issuingState: 'Sao'), {
        DocumentField.cnhIssuingState: DocumentFieldError.invalidFormat,
      });
    });

    test('only categories with D or E count for school transport', () {
      expect(cnhCategoryAllowsSchoolTransport('D'), isTrue);
      expect(cnhCategoryAllowsSchoolTransport('AE'), isTrue);
      expect(cnhCategoryAllowsSchoolTransport('AB'), isFalse);
      expect(cnhCategoryAllowsSchoolTransport('B'), isFalse);
    });
  });
}
