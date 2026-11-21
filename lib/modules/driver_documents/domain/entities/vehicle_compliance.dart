import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';

abstract class VehicleCompliance {
  String get token;
  String get plate;
  String get brand;
  String get model;
  bool get qualified;
  List<RequirementStatus> get requirements;
}
