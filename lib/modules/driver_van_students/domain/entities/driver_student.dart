import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/schedule_slot.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_source.dart';

abstract class FamilyMatch {
  String get token;

  String get dependentToken;

  String get dependentName;

  int? get dependentAge;

  String get clientName;
}

abstract class DriverStudent {
  String get token;

  StudentSource get source;

  String get name;

  String get schoolName;

  SchoolShift? get schoolShift;

  List<ScheduleSlot> get slots;

  String? get vehicleToken;

  String? get dependentToken;

  FamilyStatus get familyStatus;

  DateTime? get invitedAt;

  FamilyMatch? get familyMatch;
}
