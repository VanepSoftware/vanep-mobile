import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cep_lookup.dart';

part 'cep_lookup_dto.freezed.dart';
part 'cep_lookup_dto.g.dart';

@freezed
abstract class CepLookupDto with _$CepLookupDto {
  const factory CepLookupDto({
    required String cityToken,
    required String cityName,
    required String uf,
    String? street,
    String? neighborhood,
  }) = _CepLookupDto;

  factory CepLookupDto.fromJson(Map<String, Object?> json) =>
      _$CepLookupDtoFromJson(json);
}

CepLookup cepLookupFromDto(CepLookupDto dto) {
  return CepLookup(
    cityToken: dto.cityToken,
    cityName: dto.cityName,
    uf: dto.uf,
    street: dto.street,
    neighborhood: dto.neighborhood,
  );
}

CepLookup cepLookupFromJson(Map<String, Object?> json) {
  return cepLookupFromDto(CepLookupDto.fromJson(json));
}
