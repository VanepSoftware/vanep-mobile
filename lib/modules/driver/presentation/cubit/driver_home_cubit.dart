import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/repositories/driver_home_repository.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit({this.repository, this.rules = const DriverHomeRules()})
    : super(const DriverHomeState());

  final DriverHomeRepository? repository;
  final DriverHomeRules rules;

  void seedToday({required String shiftStartTime}) =>
      emit(state.copyWith(shiftStartTime: shiftStartTime));

  Future<void> refresh() async {
    if (state.loading || state.busy || isClosed) return;
    final source = repository;
    if (source == null) {
      emit(state.copyWith(error: DriverHomeMessage.unavailable));
      return;
    }
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final data = await source.load();
      if (!isClosed) emit(state.copyWith(data: data));
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(error: DriverHomeMessage.refreshFailed));
      }
    } finally {
      if (!isClosed) emit(state.copyWith(loading: false));
    }
  }

  Future<void> startRoute() => _command((source, fresh) async {
    // RN-02 é aplicada também ao comando, com dados atualizados.
    final denial = rules.startDenial(fresh);
    if (denial != null) return denial;
    await source.startTrip(fresh.todayTrip!.id);
    return null;
  });

  // Chamado pela UI somente quando a alça conclui o deslize.
  Future<void> confirmBySlide(StopConfirmation expected) =>
      _command((source, fresh) async {
        if (!rules.canConfirm(fresh, expected)) {
          return DriverHomeMessage.stopChanged;
        }
        await source.confirmStop(fresh.nextConfirmation!);
        return null;
      });

  Future<void> _command(
    Future<DriverHomeMessage?> Function(
      DriverHomeRepository source,
      DriverHomeData fresh,
    )
    action,
  ) async {
    if (state.busy || state.loading || isClosed) return;
    final source = repository;
    if (source == null) {
      emit(state.copyWith(error: DriverHomeMessage.unavailable));
      return;
    }
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final fresh = await source.load();
      if (isClosed) return;
      emit(state.copyWith(data: fresh));
      final error = await action(source, fresh);
      if (isClosed) return;
      if (error != null) {
        emit(state.copyWith(error: error));
        return;
      }
      try {
        final data = await source.load();
        if (!isClosed) emit(state.copyWith(data: data));
      } catch (_) {
        if (!isClosed) {
          emit(state.copyWith(error: DriverHomeMessage.refreshAfterAction));
        }
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(error: DriverHomeMessage.actionFailed));
      }
    } finally {
      if (!isClosed) emit(state.copyWith(busy: false));
    }
  }

  void setLocationSharing(bool sharing) =>
      emit(state.copyWith(sharingLocation: sharing));
}
