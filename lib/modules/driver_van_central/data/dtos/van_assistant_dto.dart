import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';

part 'van_assistant_dto.freezed.dart';
part 'van_assistant_dto.g.dart';

@freezed
abstract class VanAssistantDto with _$VanAssistantDto implements VanAssistant {
  const factory VanAssistantDto({
    required String token,
    required String name,
    @JsonKey(
      fromJson: vanAssistantStatusFromApi,
      toJson: vanAssistantStatusToApi,
    )
    required VanAssistantStatus status,
  }) = _VanAssistantDto;

  factory VanAssistantDto.fromJson(Map<String, Object?> json) =>
      _$VanAssistantDtoFromJson(json);
}

VanAssistantStatus vanAssistantStatusFromApi(String? value) {
  for (final status in VanAssistantStatus.values) {
    if (status.name == value?.toLowerCase()) return status;
  }
  return VanAssistantStatus.inactive;
}

String vanAssistantStatusToApi(VanAssistantStatus status) =>
    status.name.toUpperCase();
