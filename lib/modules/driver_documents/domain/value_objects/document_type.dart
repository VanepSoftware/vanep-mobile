import 'package:vanep_mobile/core/domain/schedule/api_name.dart';

enum DocumentKind { driverDocument, vehicleDocument, driverCnh }

enum DocumentType {
  driverLicense(
    kind: DocumentKind.driverCnh,
    requirementApiName: 'DRIVER_LICENSE',
  ),
  schoolDriverCourse(
    kind: DocumentKind.driverDocument,
    requirementApiName: 'SCHOOL_DRIVER_COURSE',
    documentApiName: 'SCHOOL_DRIVER_COURSE',
  ),
  criminalRecord(
    kind: DocumentKind.driverDocument,
    requirementApiName: 'CRIMINAL_RECORD',
    documentApiName: 'CRIMINAL_RECORD',
  ),
  municipalAuthorization(
    kind: DocumentKind.driverDocument,
    requirementApiName: 'MUNICIPAL_AUTHORIZATION',
    documentApiName: 'MUNICIPAL_AUTHORIZATION',
  ),
  vehicleRegistration(
    kind: DocumentKind.vehicleDocument,
    requirementApiName: 'VEHICLE_REGISTRATION',
    documentApiName: 'CRLV',
  ),
  vehicleInspection(
    kind: DocumentKind.vehicleDocument,
    requirementApiName: 'VEHICLE_INSPECTION',
    documentApiName: 'VEHICLE_INSPECTION',
  ),
  schoolVehicleAuthorization(
    kind: DocumentKind.vehicleDocument,
    requirementApiName: 'SCHOOL_VEHICLE_AUTHORIZATION',
    documentApiName: 'SCHOOL_VEHICLE_AUTHORIZATION',
  );

  const DocumentType({
    required this.kind,
    required this.requirementApiName,
    this.documentApiName,
  });

  final DocumentKind kind;
  final String requirementApiName;
  final String? documentApiName;

  bool get isVehicleDocument => kind == DocumentKind.vehicleDocument;

  static DocumentType? fromRequirementApi(Object? raw) =>
      findByApiName(values, (type) => type.requirementApiName, raw);
}
