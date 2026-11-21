import 'package:vanep_mobile/modules/driver_documents/domain/entities/document_submission.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

abstract class RequirementStatus {
  DocumentType get type;
  bool get optional;
  bool get satisfied;
  ComplianceState get state;
  DocumentSubmission? get current;
  DocumentSubmission? get pending;
  bool? get expiringSoon;
}
