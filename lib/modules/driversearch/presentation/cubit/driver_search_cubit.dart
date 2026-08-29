import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_drivers_by_place.dart';
import 'driver_search_state.dart';

class DriverSearchCubit extends Cubit<DriverSearchState> {
  DriverSearchCubit({required this.searchDriversByPlace})
    : super(const DriverSearchState());

  final SearchDriversByPlace searchDriversByPlace;

  Future<void> searchPlace(
    String placeId, {
    required String label,
    String? sessionToken,
  }) async {
    emit(
      DriverSearchState(
        status: DriverSearchStatus.searching,
        searchedLabel: label,
      ),
    );
    final result = await searchDriversByPlace(placeId, sessionToken: sessionToken);
    emit(
      result.fold(
        (failure) => DriverSearchState(
          status: DriverSearchStatus.failed,
          failure: failure,
          searchedLabel: label,
        ),
        (drivers) => DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: drivers,
          searchedLabel: label,
        ),
      ),
    );
  }
}
