import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/places/school_place_types.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/datasources/driver_student_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/repositories/driver_student_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/create_unlinked_passenger.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/dismiss_student_family_match.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/find_parents_group_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/invite_student_family.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/list_driver_students.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/merge_student_family.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_cubit.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

void registerDriverVanStudentsDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<DriverStudentRemoteDataSource>(
      DriverStudentRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: getIt<Environment>(),
      ),
    )
    ..registerSingleton<DriverStudentRepository>(
      DriverStudentRepositoryImpl(
        remote: getIt<DriverStudentRemoteDataSource>(),
      ),
    )
    ..registerFactory<ListDriverStudents>(
      () => ListDriverStudents(getIt<DriverStudentRepository>()),
    )
    ..registerFactory<InviteStudentFamily>(
      () => InviteStudentFamily(getIt<DriverStudentRepository>()),
    )
    ..registerFactory<FindParentsGroupInvite>(
      () => FindParentsGroupInvite(getIt<DriverStudentRepository>()),
    )
    ..registerFactory<MergeStudentFamily>(
      () => MergeStudentFamily(getIt<DriverStudentRepository>()),
    )
    ..registerFactory<DismissStudentFamilyMatch>(
      () => DismissStudentFamilyMatch(getIt<DriverStudentRepository>()),
    )
    ..registerFactory<CreateUnlinkedPassenger>(
      () => CreateUnlinkedPassenger(getIt<DriverStudentRepository>()),
    )
    ..registerFactoryParam<VanStudentsCubit, String?, void>(
      (vehicleToken, _) => VanStudentsCubit(
        vehicleToken: vehicleToken,
        listDriverStudents: getIt<ListDriverStudents>(),
        findDriverOccupancy: getIt<FindDriverOccupancy>(),
        inviteStudentFamily: getIt<InviteStudentFamily>(),
        findParentsGroupInvite: getIt<FindParentsGroupInvite>(),
        mergeStudentFamily: getIt<MergeStudentFamily>(),
        dismissStudentFamilyMatch: getIt<DismissStudentFamilyMatch>(),
      ),
    )
    ..registerFactoryParam<UnlinkedPassengerFormCubit, String?, void>(
      (vehicleToken, _) => UnlinkedPassengerFormCubit(
        vehicleToken: vehicleToken,
        autocomplete: PlaceAutocompleteController(
          datasource: getIt<PlaceAutocompleteDataSource>(),
          includedPrimaryTypes: schoolPlacePrimaryTypes,
        ),
        resolveSchool: getIt<ResolveSchool>(),
        lookupCep: getIt<LookupCep>(),
        listStates: getIt<ListStates>(),
        listCities: getIt<ListCities>(),
        createUnlinkedPassenger: getIt<CreateUnlinkedPassenger>(),
      ),
    );
}
