import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';

enum StudentFamilyFilter {
  all,
  withFamily,
  withoutFamily;

  bool includes(FamilyStatus status) {
    return switch (this) {
      StudentFamilyFilter.all => true,
      StudentFamilyFilter.withFamily => status.hasFamily,
      StudentFamilyFilter.withoutFamily => !status.hasFamily,
    };
  }
}
