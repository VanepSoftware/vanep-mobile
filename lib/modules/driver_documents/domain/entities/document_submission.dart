import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

abstract class DocumentSubmission {
  String get token;
  String? get documentNumber;
  DateTime? get expiresAt;
  SubmissionStatus get status;
  RejectionReason? get rejectionReasonCode;
  String? get rejectionReason;
  DateTime? get reviewedAt;
  DateTime get createdAt;
  String? get fileUrl;
  DocumentFile? get file;
  String? get cnhCategory;
}
