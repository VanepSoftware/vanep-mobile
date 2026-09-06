import 'package:equatable/equatable.dart';

class DriverSearchResult extends Equatable {
  const DriverSearchResult({
    required this.token,
    required this.name,
    this.photo,
    this.rating,
    this.basePrice,
    this.experienceYears,
    this.available = false,
  });

  final String token;

  final String name;

  final String? photo;

  final double? rating;

  final double? basePrice;

  final int? experienceYears;

  final bool available;

  @override
  List<Object?> get props => [
    token,
    name,
    photo,
    rating,
    basePrice,
    experienceYears,
    available,
  ];
}
