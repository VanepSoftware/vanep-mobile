import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/service_area.dart';
import '../../domain/entities/service_area_draft.dart';
import '../../domain/usecases/find_my_service_areas.dart';
import '../../domain/usecases/replace_my_service_areas.dart';
import 'driver_service_areas_state.dart';

ServiceAreaDraft draftFromSavedArea(ServiceArea area) {
  return ServiceAreaDraft(
    placeId: area.token,
    label: area.name,
    looksCityWide: area.coversWholeCity,
  );
}

class DriverServiceAreasCubit extends Cubit<DriverServiceAreasState> {
  DriverServiceAreasCubit({
    required this.findMyServiceAreas,
    required this.replaceMyServiceAreas,
  }) : super(const DriverServiceAreasState());

  final FindMyServiceAreas findMyServiceAreas;
  final ReplaceMyServiceAreas replaceMyServiceAreas;

  Future<void> loadMyAreas() async {
    emit(state.copyWith(status: DriverServiceAreasStatus.loading, clearFailure: true));
    final result = await findMyServiceAreas();
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DriverServiceAreasStatus.ready,
          failure: failure,
        ),
        (areas) => state.copyWith(
          status: DriverServiceAreasStatus.ready,
          saved: areas,
          drafts: areas.map(draftFromSavedArea).toList(),
          clearFailure: true,
        ),
      ),
    );
  }

  void addDraft(ServiceAreaDraft draft) {
    if (!state.canAddMore) return;
    if (state.drafts.any((existing) => existing.placeId == draft.placeId)) return;
    emit(
      state.copyWith(
        drafts: [...state.drafts, draft],
        clearFailure: true,
      ),
    );
  }

  void removeDraft(String placeId) {
    emit(
      state.copyWith(
        drafts: state.drafts.where((draft) => draft.placeId != placeId).toList(),
        clearFailure: true,
      ),
    );
  }

  Future<void> saveAreas() async {
    emit(state.copyWith(status: DriverServiceAreasStatus.saving, clearFailure: true));
    final result = await replaceMyServiceAreas(state.drafts);
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DriverServiceAreasStatus.ready,
          failure: failure,
        ),
        (areas) => state.copyWith(
          status: DriverServiceAreasStatus.saved,
          saved: areas,
          drafts: areas.map(draftFromSavedArea).toList(),
          clearFailure: true,
        ),
      ),
    );
  }
}
