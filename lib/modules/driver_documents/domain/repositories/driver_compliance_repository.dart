import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';

abstract interface class DriverComplianceRepository {
  Future<Result<ComplianceFailure, DriverCompliance>> loadMine();
}
