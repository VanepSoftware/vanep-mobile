import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';

abstract class DriverCompliance {
  DateTime get asOf;
  List<RequirementStatus> get driverRequirements;
  List<VehicleCompliance> get vehicles;
}
