import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';

void registerPlacesDependencies(GetIt getIt, {TargetPlatform? platform}) {
  getIt
    ..registerSingleton<PlaceAutocompleteDataSource>(
      PlaceAutocompleteDataSource(
        dio: Dio(),
        environment: getIt<Environment>(),
        platform: platform ?? defaultTargetPlatform,
      ),
    )
    ..registerFactory<PlaceAutocompleteController>(
      () => PlaceAutocompleteController(
        datasource: getIt<PlaceAutocompleteDataSource>(),
      ),
    );
}
