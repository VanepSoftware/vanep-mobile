import 'package:vanep_mobile/modules/driver_van_central/driver_van_central_container.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/places/places_container.dart';
import 'package:vanep_mobile/core/share/share_container.dart';
import 'package:vanep_mobile/core/share/text_sharer.dart';
import 'package:vanep_mobile/modules/driver_van_students/driver_van_students_container.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_cubit.dart';
import 'package:vanep_mobile/modules/ibge_locations/ibge_locations_container.dart';
import 'package:vanep_mobile/modules/schools/schools_container.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance()
      ..registerSingleton<Environment>(
        const Environment(
          authBaseUrl: 'http://10.0.2.2:8080',
          oauthClientId: 'vanep-mobile',
        ),
      )
      ..registerSingleton<Dio>(Dio(), instanceName: authenticatedDioName);
    registerPlacesDependencies(getIt, platform: TargetPlatform.android);
    registerShareDependencies(getIt);
    registerIbgeLocationsDependencies(getIt);
    registerSchoolsDependencies(getIt);
    registerDriverVanCentralDependencies(getIt);
    registerDriverVanStudentsDependencies(getIt);
  });

  test('resolves both cubits for the chosen van and the sharer', () {
    expect(getIt<VanStudentsCubit>(param1: 'van-1').vehicleToken, 'van-1');
    expect(
      getIt<UnlinkedPassengerFormCubit>(param1: 'van-1')
          .state
          .draft
          .vehicleToken,
      'van-1',
    );
    expect(getIt<TextSharer>(), isA<SharePlusTextSharer>());
  });
}
