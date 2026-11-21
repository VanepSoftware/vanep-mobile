import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/data/dtos/document_request_bodies.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

void main() {
  group('request body', () {
    test('a person document sends type, trimmed number and expiry', () {
      expect(
        documentRequestBody(
          PersonalDocumentDraft(
            type: DocumentType.municipalAuthorization,
            documentNumber: '  ALV-9 ',
            expiresAt: DateTime(2028, 3, 1),
          ),
        ),
        {
          'documentType': 'MUNICIPAL_AUTHORIZATION',
          'documentNumber': 'ALV-9',
          'expiresAt': '2028-03-01',
        },
      );
    });

    test('blank fields go as null', () {
      expect(
        documentRequestBody(
          const PersonalDocumentDraft(
            type: DocumentType.criminalRecord,
            documentNumber: '   ',
          ),
        ),
        {
          'documentType': 'CRIMINAL_RECORD',
          'documentNumber': null,
          'expiresAt': null,
        },
      );
    });

    test('a van document sends the type of the resource', () {
      expect(
        documentRequestBody(
          VehicleDocumentDraft(
            vehicleToken: 'sprinter',
            type: DocumentType.vehicleRegistration,
            expiresAt: DateTime(2027, 7, 31),
          ),
        ),
        {
          'documentType': 'CRLV',
          'documentNumber': null,
          'expiresAt': '2027-07-31',
        },
      );
    });

    test('a CNH sends its own fields, with the category in upper case', () {
      expect(
        documentRequestBody(
          CnhDraft(
            registrationNumber: ' 01234567890 ',
            category: 'ad',
            issueDate: DateTime(2021, 8, 12),
            validUntil: DateTime(2031, 8, 12),
            issuingState: 'sp',
          ),
        ),
        {
          'registrationNumber': '01234567890',
          'category': 'AD',
          'issueDate': '2021-08-12',
          'validUntil': '2031-08-12',
          'issuingState': 'SP',
        },
      );
    });
  });

  group('saved data for "Terminar envio"', () {
    test('reads a person document', () {
      expect(
        draftFromResource(DocumentKind.driverDocument, {
          'documentType': 'CRIMINAL_RECORD',
          'documentNumber': 'CERT-1',
          'expiresAt': '2027-02-14',
        }),
        PersonalDocumentDraft(
          type: DocumentType.criminalRecord,
          documentNumber: 'CERT-1',
          expiresAt: DateTime(2027, 2, 14),
        ),
      );
    });

    test('reads a van document with its van', () {
      expect(
        draftFromResource(DocumentKind.vehicleDocument, {
          'vehicleToken': 'sprinter',
          'documentType': 'VEHICLE_INSPECTION',
          'documentNumber': null,
          'expiresAt': '2027-05-31',
        }),
        VehicleDocumentDraft(
          vehicleToken: 'sprinter',
          type: DocumentType.vehicleInspection,
          expiresAt: DateTime(2027, 5, 31),
        ),
      );
    });

    test('reads a CNH', () {
      expect(
        draftFromResource(DocumentKind.driverCnh, {
          'registrationNumber': '01234567890',
          'category': 'D',
          'issueDate': '2021-08-12',
          'validUntil': '2031-08-12',
          'issuingState': null,
        }),
        CnhDraft(
          registrationNumber: '01234567890',
          category: 'D',
          issueDate: DateTime(2021, 8, 12),
          validUntil: DateTime(2031, 8, 12),
        ),
      );
    });

    test('a van document without its van is unreadable', () {
      expect(
        () => draftFromResource(DocumentKind.vehicleDocument, {
          'documentType': 'CRLV',
        }),
        throwsFormatException,
      );
    });

    test('an unknown document type is unreadable', () {
      expect(
        () => draftFromResource(DocumentKind.driverDocument, {
          'documentType': 'RESIDENCE_PROOF',
        }),
        throwsFormatException,
      );
    });
  });
}
