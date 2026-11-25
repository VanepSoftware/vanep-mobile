import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';

class DriverComplianceState extends Equatable {
  const DriverComplianceState.loading() : compliance = null, failure = null;

  const DriverComplianceState.ready(DriverCompliance this.compliance)
    : failure = null;

  const DriverComplianceState.failed(ComplianceFailure this.failure)
    : compliance = null;

  final DriverCompliance? compliance;
  final ComplianceFailure? failure;

  @override
  List<Object?> get props => [compliance, failure];
}
