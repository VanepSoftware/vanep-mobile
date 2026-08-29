import 'package:equatable/equatable.dart';

class ServiceAreaDraft extends Equatable {
  const ServiceAreaDraft({
    required this.placeId,
    required this.label,
    this.sessionToken,
    this.looksCityWide = false,
  });

  final String placeId;

  final String label;

  final String? sessionToken;

  final bool looksCityWide;

  @override
  List<Object?> get props => [placeId, label, sessionToken, looksCityWide];
}
