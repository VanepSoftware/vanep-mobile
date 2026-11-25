import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/modules/driver_professional_data/presentation/cubit/professional_data_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/change_accepting_students.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_attendance.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/get_profile_summary.dart';

void registerDriverProfessionalDataDependencies(GetIt getIt) {
  getIt.registerFactory<ProfessionalDataCubit>(
    () => ProfessionalDataCubit(
      getProfileSummary: getIt<GetProfileSummary>(),
      findDriverAttendance: getIt<FindDriverAttendance>(),
      changeAcceptingStudents: getIt<ChangeAcceptingStudents>(),
    ),
  );
}
