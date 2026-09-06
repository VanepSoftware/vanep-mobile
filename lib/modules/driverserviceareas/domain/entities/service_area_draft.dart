import 'package:equatable/equatable.dart';

class ServiceAreaDraft extends Equatable {
  const ServiceAreaDraft({
    required this.label,
    this.placeId,
    this.areaToken,
    this.sessionToken,
    this.looksCityWide = false,
  });

  final String label;

  final String? placeId;

  final String? areaToken;

  final String? sessionToken;

  final bool looksCityWide;

  bool get isAlreadySaved => areaToken != null && areaToken!.isNotEmpty;

  String get identity => areaToken ?? placeId ?? label;

  @override
  List<Object?> get props => [label, placeId, areaToken, sessionToken, looksCityWide];
}
