import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

void main() {
  test('reads each requirement name of the back', () {
    expect(
      DocumentType.fromRequirementApi('DRIVER_LICENSE'),
      DocumentType.driverLicense,
    );
    expect(
      DocumentType.fromRequirementApi('SCHOOL_DRIVER_COURSE'),
      DocumentType.schoolDriverCourse,
    );
    expect(
      DocumentType.fromRequirementApi('CRIMINAL_RECORD'),
      DocumentType.criminalRecord,
    );
    expect(
      DocumentType.fromRequirementApi('MUNICIPAL_AUTHORIZATION'),
      DocumentType.municipalAuthorization,
    );
    expect(
      DocumentType.fromRequirementApi('VEHICLE_REGISTRATION'),
      DocumentType.vehicleRegistration,
    );
    expect(
      DocumentType.fromRequirementApi('VEHICLE_INSPECTION'),
      DocumentType.vehicleInspection,
    );
    expect(
      DocumentType.fromRequirementApi('SCHOOL_VEHICLE_AUTHORIZATION'),
      DocumentType.schoolVehicleAuthorization,
    );
  });

  test('an unknown requirement is ignored', () {
    expect(DocumentType.fromRequirementApi('RESIDENCE_PROOF'), isNull);
    expect(DocumentType.fromRequirementApi(null), isNull);
  });

  test('the document type sent to each resource', () {
    expect(DocumentType.driverLicense.documentApiName, isNull);
    expect(DocumentType.criminalRecord.documentApiName, 'CRIMINAL_RECORD');
    expect(DocumentType.vehicleRegistration.documentApiName, 'CRLV');
    expect(
      DocumentType.vehicleInspection.documentApiName,
      'VEHICLE_INSPECTION',
    );
  });

  test('each type belongs to its resource', () {
    expect(DocumentType.driverLicense.kind, DocumentKind.driverCnh);
    expect(
      DocumentType.municipalAuthorization.kind,
      DocumentKind.driverDocument,
    );
    expect(
      DocumentType.schoolVehicleAuthorization.kind,
      DocumentKind.vehicleDocument,
    );
  });
}
