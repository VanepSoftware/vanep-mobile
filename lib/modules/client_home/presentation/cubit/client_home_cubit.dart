import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/client_home/domain/usecases/load_client_home.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_state.dart';

class ClientHomeCubit extends Cubit<ClientHomeState> {
  ClientHomeCubit({required this.loadClientHome})
    : super(const ClientHomeState());

  final LoadClientHome loadClientHome;

  Future<void> loadHome() async {
    final currentHome = state.home;
    if (currentHome == null) {
      emit(const ClientHomeState(status: ClientHomeStatus.loading));
    }
    final result = await loadClientHome();
    emit(
      result.fold(
        (failure) => currentHome == null
            ? ClientHomeState(
                status: ClientHomeStatus.loadFailed,
                failure: failure,
              )
            : state,
        (home) => ClientHomeState(status: ClientHomeStatus.ready, home: home),
      ),
    );
  }
}
