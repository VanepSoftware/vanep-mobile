import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/api_name.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

enum OperationShift {
  morning('MORNING'),
  afternoon('AFTERNOON'),
  night('NIGHT');

  const OperationShift(this.apiName);

  final String apiName;

  static OperationShift? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }

  static String? toApi(OperationShift? value) => value?.apiName;
}

OperationShift deriveOperationShift(SchoolShift? schoolShift, RouteLeg leg) {
  return switch (schoolShift) {
    SchoolShift.morning => OperationShift.morning,
    SchoolShift.afternoon => OperationShift.afternoon,
    SchoolShift.night => OperationShift.night,
    SchoolShift.fullTime || null =>
      leg == RouteLeg.outbound
          ? OperationShift.morning
          : OperationShift.afternoon,
  };
}
