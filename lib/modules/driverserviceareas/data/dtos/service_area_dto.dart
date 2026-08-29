import '../../domain/entities/service_area.dart';

ServiceArea serviceAreaFromJson(Map<String, Object?> json) {
  return ServiceArea(
    token: json['token'] as String? ?? '',
    name: json['name'] as String? ?? '',
    cityName: json['cityName'] as String? ?? '',
    stateUf: json['stateUf'] as String? ?? '',
    coversWholeCity: json['coversWholeCity'] as bool? ?? false,
  );
}

Map<String, Object?> serviceAreaDraftToJson(String placeId, String? sessionToken) {
  return {
    'placeId': placeId,
    if (sessionToken != null && sessionToken.isNotEmpty)
      'sessionToken': sessionToken,
  };
}
