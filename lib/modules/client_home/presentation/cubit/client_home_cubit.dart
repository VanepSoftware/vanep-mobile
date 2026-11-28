import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/client_home/domain/usecases/load_client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/rate_driver.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_state.dart';

class ClientHomeCubit extends Cubit<ClientHomeState> {
  ClientHomeCubit({required this.loadClientHome, required this.rateDriver})
    : super(const ClientHomeState());

  final LoadClientHome loadClientHome;
  final RateDriver rateDriver;

  /// Sends the rating and, on success, reloads the home so the item leaves.
  Future<bool> rate(String driverToken, int stars) async {
    final result = await rateDriver(driverToken, stars);
    if (result.isErr) return false;
    if (!isClosed) await loadHome();
    return true;
  }

  Future<void> loadHome() async {
    final currentHome = state.home;
    if (currentHome == null) {
      emit(const ClientHomeState(status: ClientHomeStatus.loading));
    }
    final result = await loadClientHome();
    if (isClosed) return;
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
