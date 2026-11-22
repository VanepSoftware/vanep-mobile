import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';

abstract class VehicleCompliance {
  String get token;
  String get plate;
  String get model;
  List<RequirementStatus> get requirements;
}
