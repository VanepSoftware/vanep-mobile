import '../../domain/entities/service_area.dart';
import '../../domain/entities/service_area_draft.dart';

ServiceArea serviceAreaFromJson(Map<String, Object?> json) {
  return ServiceArea(
    token: json['token'] as String? ?? '',
    name: json['name'] as String? ?? '',
    cityName: json['cityName'] as String? ?? '',
    stateUf: json['stateUf'] as String? ?? '',
    coversWholeCity: json['coversWholeCity'] as bool? ?? false,
  );
}

Map<String, Object?> serviceAreaDraftToJson(ServiceAreaDraft draft) {
  if (draft.isAlreadySaved) {
    return {'areaToken': draft.areaToken};
  }
  return {
    'placeId': draft.placeId,
    if (draft.sessionToken != null && draft.sessionToken!.isNotEmpty)
      'sessionToken': draft.sessionToken,
  };
}
