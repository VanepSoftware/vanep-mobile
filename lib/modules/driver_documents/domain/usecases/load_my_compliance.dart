import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/driver_compliance_repository.dart';

class LoadMyCompliance {
  const LoadMyCompliance(this.repository);

  final DriverComplianceRepository repository;

  Future<Result<ComplianceFailure, DriverCompliance>> call() =>
      repository.loadMine();
}
