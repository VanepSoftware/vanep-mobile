import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/gender.dart';
import '../../domain/entities/dependent.dart';

part 'dependent_dto.freezed.dart';
part 'dependent_dto.g.dart';

@freezed
abstract class DependentAddressDto
    with _$DependentAddressDto
    implements DependentAddress {
  const factory DependentAddressDto({
    @Default('') String token,
    @Default('') String street,
    String? number,
    String? complement,
    String? district,
    @Default('') String cityName,
    @Default('') String stateUf,
  }) = _DependentAddressDto;

  factory DependentAddressDto.fromJson(Map<String, Object?> json) =>
      _$DependentAddressDtoFromJson(json);
}

@freezed
abstract class DependentDto with _$DependentDto implements Dependent {
  const factory DependentDto({
    @Default('') String token,
    @Default('') String name,
    String? birthDate,
    @JsonKey(fromJson: Gender.fromApi, toJson: Gender.toApi) Gender? gender,
    @Default(false) bool isDefault,
    DependentAddressDto? address,
  }) = _DependentDto;

  factory DependentDto.fromJson(Map<String, Object?> json) =>
      _$DependentDtoFromJson(json);
}
