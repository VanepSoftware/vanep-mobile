import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';

enum ClientVansStatus {
  loading,
  loaded,
  loadFailed,
}

class ClientVansState extends Equatable {
  const ClientVansState({
    this.status = ClientVansStatus.loading,
    this.vans = const [],
    this.selectedVanIndex = 0,
    this.failure,
  });

  final ClientVansStatus status;
  final List<ClientVan> vans;
  final int selectedVanIndex;
  final ClientVansFailure? failure;

  bool get isLoading => status == ClientVansStatus.loading;
  bool get hasVans => vans.isNotEmpty;

  ClientVan? get selectedVan {
    if (vans.isEmpty) return null;
    if (selectedVanIndex >= 0 && selectedVanIndex < vans.length) {
      return vans[selectedVanIndex];
    }
    return vans.first;
  }

  ClientVansState copyWith({
    ClientVansStatus? status,
    List<ClientVan>? vans,
    int? selectedVanIndex,
    ClientVansFailure? failure,
  }) {
    return ClientVansState(
      status: status ?? this.status,
      vans: vans ?? this.vans,
      selectedVanIndex: selectedVanIndex ?? this.selectedVanIndex,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, vans, selectedVanIndex, failure];
}
