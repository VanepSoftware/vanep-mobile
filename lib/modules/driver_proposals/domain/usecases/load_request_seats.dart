import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/shift_seats.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

class LoadRequestSeats {
  const LoadRequestSeats({
    required this.listMyVans,
    required this.findDriverOccupancy,
  });

  final ListMyVans listMyVans;

  final FindDriverOccupancy findDriverOccupancy;

  // Seats only complement the request: when they cannot be read, none are shown.
  Future<List<ShiftSeats>> call(DriverServiceRequest request) async {
    final (vansResult, occupancyResult) = await (
      listMyVans(),
      findDriverOccupancy(),
    ).wait;
    return findRequestedShiftSeats(
      vans: vansResult.valueOrNull ?? const [],
      occupancy: occupancyResult.valueOrNull,
      items: request.items,
    );
  }
}
