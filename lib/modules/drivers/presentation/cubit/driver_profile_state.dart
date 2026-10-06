import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';

enum DriverProfileStatus { loading, loaded, error }

class DriverProfileState extends Equatable {
  const DriverProfileState({
    this.status = DriverProfileStatus.loading,
    this.profile,
    this.failure,
  });

  final DriverProfileStatus status;
  final DriverProfile? profile;
  final DriverFailure? failure;

  @override
  List<Object?> get props => [status, profile, failure];
}
