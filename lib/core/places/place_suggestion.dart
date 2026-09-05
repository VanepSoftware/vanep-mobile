import 'package:equatable/equatable.dart';

class PlaceSuggestion extends Equatable {
  const PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
  });

  final String placeId;

  final String primaryText;

  final String secondaryText;

  @override
  List<Object?> get props => [placeId, primaryText, secondaryText];
}
