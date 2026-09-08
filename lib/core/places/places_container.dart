import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../environment/environment.dart';
import 'place_autocomplete_controller.dart';
import 'place_autocomplete_datasource.dart';

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
