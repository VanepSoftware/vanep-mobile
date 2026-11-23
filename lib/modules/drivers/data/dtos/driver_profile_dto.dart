import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';

part 'driver_profile_dto.freezed.dart';
part 'driver_profile_dto.g.dart';

@freezed
abstract class DriverProfileVehicleDto
    with _$DriverProfileVehicleDto
    implements DriverProfileVehicle {
  const factory DriverProfileVehicleDto({
    required String token,
    required String brand,
    required String model,
    required int manufactureYear,
    required String color,
    required int capacity,
    @Default(false) bool hasAssistant,
    @JsonKey(name: 'photoFront') String? photoFrontUrl,
    @JsonKey(name: 'photoSide') String? photoSideUrl,
  }) = _DriverProfileVehicleDto;

  factory DriverProfileVehicleDto.fromJson(Map<String, Object?> json) =>
      _$DriverProfileVehicleDtoFromJson(json);
}

@freezed
abstract class DriverShiftVacancyDto
    with _$DriverShiftVacancyDto
    implements DriverShiftVacancy {
  const factory DriverShiftVacancyDto({
    required String shift,
    int? spots,
    String? status,
  }) = _DriverShiftVacancyDto;

  factory DriverShiftVacancyDto.fromJson(Map<String, Object?> json) =>
      _$DriverShiftVacancyDtoFromJson(json);
}

@freezed
abstract class DriverRatingBreakdownDto
    with _$DriverRatingBreakdownDto
    implements DriverRatingBreakdown {
  const factory DriverRatingBreakdownDto({
    required int stars,
    required int count,
  }) = _DriverRatingBreakdownDto;

  factory DriverRatingBreakdownDto.fromJson(Map<String, Object?> json) =>
      _$DriverRatingBreakdownDtoFromJson(json);
}

@freezed
abstract class DriverProfileRatingDto
    with _$DriverProfileRatingDto
    implements DriverProfileRating {
  const factory DriverProfileRatingDto({
    required String authorName,
    required String dateLabel,
    required int stars,
    required String comment,
  }) = _DriverProfileRatingDto;

  factory DriverProfileRatingDto.fromJson(Map<String, Object?> json) =>
      _$DriverProfileRatingDtoFromJson(json);
}

@freezed
abstract class DriverProfileDto
    with _$DriverProfileDto
    implements DriverProfile {
  const factory DriverProfileDto({
    required String token,
    required String name,
    String? phone,
    @JsonKey(name: 'photo') String? photoUrl,
    double? rating,
    int? ratingCount,
    String? bio,
    int? experienceYears,
    double? basePrice,
    @Default(false) bool available,
    @Default(true) bool verified,
    String? workStartTime,
    String? workEndTime,
    String? workDays,
    int? waitToleranceMinutes,
    @Default(<String>[]) List<String> serviceAreas,
    @Default(<DriverProfileVehicleDto>[])
    List<DriverProfileVehicleDto> vehicles,
    @Default(<DriverShiftVacancyDto>[])
    List<DriverShiftVacancyDto> shiftVacancies,
    @Default(<DriverRatingBreakdownDto>[])
    List<DriverRatingBreakdownDto> ratingBreakdown,
    @Default(<DriverProfileRatingDto>[])
    List<DriverProfileRatingDto> ratings,
  }) = _DriverProfileDto;

  factory DriverProfileDto.fromJson(Map<String, Object?> json) =>
      _$DriverProfileDtoFromJson(json);
}
