import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/driver_compliance_repository.dart';

class MockDriverComplianceRepository extends Mock
    implements DriverComplianceRepository {}

class MockDocumentSubmissionRepository extends Mock
    implements DocumentSubmissionRepository {}
