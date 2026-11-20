import 'package:equatable/equatable.dart';

const placeSearchBiasRadiusMeters = 50000.0;

class PlaceSearchCenter extends Equatable {
  const PlaceSearchCenter({required this.latitude, required this.longitude});

  final double latitude;

  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

PlaceSearchCenter? placeSearchCenterOrNull(
  double? latitude,
  double? longitude,
) {
  if (latitude == null || longitude == null) return null;
  return PlaceSearchCenter(latitude: latitude, longitude: longitude);
}
