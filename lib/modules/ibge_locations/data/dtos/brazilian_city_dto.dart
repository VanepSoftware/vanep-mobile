import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/brazilian_city.dart';

part 'brazilian_city_dto.freezed.dart';
part 'brazilian_city_dto.g.dart';

@freezed
abstract class BrazilianCityDto with _$BrazilianCityDto {
  const factory BrazilianCityDto({
    required String token,
    required String name,
    required String stateToken,
    required String stateUf,
    required bool active,
    DateTime? createdAt,
  }) = _BrazilianCityDto;

  factory BrazilianCityDto.fromJson(Map<String, Object?> json) =>
      _$BrazilianCityDtoFromJson(json);
}

BrazilianCity brazilianCityFromDto(BrazilianCityDto dto) {
  return BrazilianCity(
    token: dto.token,
    name: dto.name,
    stateToken: dto.stateToken,
    stateUf: dto.stateUf,
    active: dto.active,
    createdAt: dto.createdAt,
  );
}

BrazilianCity brazilianCityFromJson(Map<String, Object?> json) {
  return brazilianCityFromDto(BrazilianCityDto.fromJson(json));
}
