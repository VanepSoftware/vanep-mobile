import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/brazilian_state.dart';

part 'brazilian_state_dto.freezed.dart';
part 'brazilian_state_dto.g.dart';

@freezed
abstract class BrazilianStateDto with _$BrazilianStateDto {
  const factory BrazilianStateDto({
    required String token,
    required String name,
    required String uf,
    required bool active,
  }) = _BrazilianStateDto;

  factory BrazilianStateDto.fromJson(Map<String, Object?> json) =>
      _$BrazilianStateDtoFromJson(json);
}

BrazilianState brazilianStateFromDto(BrazilianStateDto dto) {
  return BrazilianState(
    token: dto.token,
    name: dto.name,
    uf: dto.uf,
    active: dto.active,
  );
}

BrazilianState brazilianStateFromJson(Map<String, Object?> json) {
  return brazilianStateFromDto(BrazilianStateDto.fromJson(json));
}
