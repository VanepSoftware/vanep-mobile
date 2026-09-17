import 'package:equatable/equatable.dart';

class AssistantInvite extends Equatable {
  const AssistantInvite({
    required this.token,
    required this.driverName,
    this.driverPhoto,
    this.driverRating,
    this.vehicleDescription,
    required this.expiresAt,
    required this.status,
  });

  final String token;

  final String driverName;

  final String? driverPhoto;

  final double? driverRating;

  final String? vehicleDescription;

  final DateTime expiresAt;

  final String status;

  @override
  List<Object?> get props => [
    token,
    driverName,
    driverPhoto,
    driverRating,
    vehicleDescription,
    expiresAt,
    status,
  ];
}
