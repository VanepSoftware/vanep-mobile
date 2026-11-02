import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_state.dart';

class AssistantVanSelectorCubit extends Cubit<AssistantVanSelectorState> {
  AssistantVanSelectorCubit({
    required this.getLinkedVans,
  }) : super(const AssistantVanSelectorState());

  final GetLinkedVans getLinkedVans;

  Future<void> loadVans() async {
    emit(state.copyWith(isLoading: true, failure: () => null));

    final result = await getLinkedVans();
    switch (result) {
      case Ok(:final value):
        final newSelected = value.isEmpty
            ? null
            : (state.selectedVan != null &&
                    value.any((v) => v.token == state.selectedVan!.token))
                ? state.selectedVan
                : value.first;
        emit(
          state.copyWith(
            isLoading: false,
            vans: value,
            selectedVan: () => newSelected,
          ),
        );
      case Err(:final error):
        emit(
          state.copyWith(
            isLoading: false,
            failure: () => error,
          ),
        );
    }
  }

  void selectVan(AssistantVan van) {
    emit(state.copyWith(selectedVan: () => van));
  }
}
