import '../../domain/entities/assistant_van.dart';

class AssistantVanDto extends AssistantVan {
  const AssistantVanDto({
    required super.token,
    required super.driverToken,
    required super.driverName,
    required super.plate,
    required super.model,
    super.shift,
  });

  factory AssistantVanDto.fromJson(Map<String, Object?> json) {
    return AssistantVanDto(
      token: json['token'] as String? ?? '',
      driverToken: json['driverToken'] as String? ?? '',
      driverName: json['driverName'] as String? ?? '',
      plate: json['plate'] as String? ?? '',
      model: json['model'] as String? ?? '',
      shift: json['shift'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'token': token,
      'driverToken': driverToken,
      'driverName': driverName,
      'plate': plate,
      'model': model,
      if (shift != null) 'shift': shift,
    };
  }
}
