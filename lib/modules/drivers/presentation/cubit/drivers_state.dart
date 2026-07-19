import 'package:equatable/equatable.dart';

import '../../domain/entities/driver.dart';
import '../../domain/failures/driver_failure.dart';

enum DriversStatus { initial, loading, loaded, error }

class DriversState extends Equatable {
  const DriversState({
    this.status = DriversStatus.initial,
    this.drivers = const [],
    this.query = '',
    this.failure,
  });

  final DriversStatus status;
  final List<Driver> drivers;
  final String query;
  final DriverFailure? failure;

  List<Driver> get visibleDrivers {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return drivers;
    return drivers
        .where(
          (driver) =>
              driver.name.toLowerCase().contains(term) ||
              (driver.city?.toLowerCase().contains(term) ?? false),
        )
        .toList();
  }

  DriversState copyWith({
    DriversStatus? status,
    List<Driver>? drivers,
    String? query,
    DriverFailure? failure,
  }) {
    return DriversState(
      status: status ?? this.status,
      drivers: drivers ?? this.drivers,
      query: query ?? this.query,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, drivers, query, failure];
}
