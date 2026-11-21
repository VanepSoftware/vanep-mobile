import 'package:vanep_mobile/modules/driver_documents/domain/entities/document_submission.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

enum DocumentAction { send, finish, resend, sendNew, sendUpdated }

DocumentAction? documentActionFor(DocumentDisplayState state) {
  return switch (state) {
    DocumentNotSent() => DocumentAction.send,
    DocumentIncomplete() => DocumentAction.finish,
    DocumentRejected() => DocumentAction.resend,
    DocumentExpired() || DocumentExpiringSoon() => DocumentAction.sendNew,
    DocumentApproved() => DocumentAction.sendUpdated,
    DocumentUnderReview() || DocumentRenewalUnderReview() => null,
  };
}

DocumentSubmission? incompleteSubmissionOf(RequirementStatus requirement) {
  for (final submission in [requirement.pending, requirement.current]) {
    if (submission != null &&
        submission.status == SubmissionStatus.pending &&
        submission.fileUrl == null) {
      return submission;
    }
  }
  return null;
}

VehicleCompliance? findVehicle(DriverCompliance compliance, String token) {
  for (final vehicle in compliance.vehicles) {
    if (vehicle.token == token) return vehicle;
  }
  return null;
}

RequirementStatus? findRequirement(
  DriverCompliance compliance,
  DocumentType type, {
  String? vehicleToken,
}) {
  final requirements = vehicleToken == null
      ? compliance.driverRequirements
      : findVehicle(compliance, vehicleToken)?.requirements ?? const [];
  for (final requirement in requirements) {
    if (requirement.type == type) return requirement;
  }
  return null;
}
