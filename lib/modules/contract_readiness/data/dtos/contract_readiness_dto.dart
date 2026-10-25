import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';

part 'contract_readiness_dto.freezed.dart';
part 'contract_readiness_dto.g.dart';

@freezed
abstract class ReadinessGapDto with _$ReadinessGapDto {
  const factory ReadinessGapDto({
    @JsonKey(fromJson: ContractReadinessSubject.fromApi, includeToJson: false)
    ContractReadinessSubject? subject,
    String? dependentToken,
    @JsonKey(fromJson: ContractReadinessField.fromApi, includeToJson: false)
    ContractReadinessField? field,
  }) = _ReadinessGapDto;

  factory ReadinessGapDto.fromJson(Map<String, Object?> json) =>
      _$ReadinessGapDtoFromJson(json);
}

@freezed
abstract class ContractReadinessDto with _$ContractReadinessDto {
  const factory ContractReadinessDto({
    @Default(false) bool ready,
    @Default(<ReadinessGapDto>[]) List<ReadinessGapDto> missing,
  }) = _ContractReadinessDto;

  factory ContractReadinessDto.fromJson(Map<String, Object?> json) =>
      _$ContractReadinessDtoFromJson(json);
}

ContractReadiness contractReadinessFromDto(ContractReadinessDto dto) {
  return ContractReadiness(
    ready: dto.ready,
    gaps: [
      for (final gap in dto.missing)
        if (gap case ReadinessGapDto(
          subject: final subject?,
          field: final field?,
        ))
          ReadinessGap(
            subject: subject,
            field: field,
            dependentToken: gap.dependentToken,
          ),
    ],
  );
}

ContractReadiness contractReadinessFromJson(Map<String, Object?> json) {
  return contractReadinessFromDto(ContractReadinessDto.fromJson(json));
}
