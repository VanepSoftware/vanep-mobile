import 'package:equatable/equatable.dart';

import '../../../drivers/domain/entities/driver.dart';

class DriverSearchResult extends Equatable implements Driver {
  const DriverSearchResult({
    required this.token,
    required this.name,
    this.photoUrl,
    this.rating,
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
    basePrice,
    experienceYears,
    available,
    serviceAreas,
  ];
}
