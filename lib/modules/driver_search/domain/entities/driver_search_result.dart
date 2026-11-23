import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';

class DriverSearchResult extends Equatable implements Driver {
  const DriverSearchResult({
    required this.token,
    required this.name,
    this.photoUrl,
    this.rating,
    this.ratingCount,
    this.basePrice,
    this.experienceYears,
    this.available = false,
    this.serviceAreas = const [],
  });

  @override
  final String token;

  @override
  final String name;

  @override
  final String? photoUrl;

  @override
  final double? rating;

  final int? ratingCount;

  @override
  final int? experienceYears;

  final double? basePrice;

  final bool available;

  final List<String> serviceAreas;

  @override
  String? get city => null;

  @override
  List<Object?> get props => [
    token,
    name,
    photoUrl,
    rating,
    ratingCount,
    basePrice,
    experienceYears,
    available,
    serviceAreas,
  ];
}
