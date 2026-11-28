import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/client_vans/domain/usecases/find_my_client_vans.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_state.dart';

class ClientVansCubit extends Cubit<ClientVansState> {
  ClientVansCubit({required this.findMyClientVans})
      : super(const ClientVansState());

  final FindMyClientVans findMyClientVans;

  Future<void> loadVans() async {
    emit(state.copyWith(status: ClientVansStatus.loading));
    final result = await findMyClientVans();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ClientVansStatus.loadFailed,
          failure: failure,
        ),
      ),
      (vans) => emit(
        state.copyWith(
          status: ClientVansStatus.loaded,
          vans: vans,
          selectedVanIndex: 0,
        ),
      ),
    );
  }

  void selectVan(int index) {
    if (index >= 0 && index < state.vans.length) {
      emit(state.copyWith(selectedVanIndex: index));
    }
  }

  Future<void> refresh() => loadVans();
}
