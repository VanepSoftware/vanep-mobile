import 'package:equatable/equatable.dart';

class PlaceSuggestion extends Equatable {
  const PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
    this.distanceMeters,
  });

  final String placeId;

  final String primaryText;

  final String secondaryText;

  final int? distanceMeters;

  @override
  List<Object?> get props => [
    placeId,
    primaryText,
    secondaryText,
    distanceMeters,
  ];
}
