import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/data/schedule_slot_dto.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/family_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_source.dart';

part 'driver_student_dto.freezed.dart';
part 'driver_student_dto.g.dart';

StudentSource readStudentSource(Object? raw) {
  return requireRead(StudentSource.fromApi(raw), 'student source', raw);
}

FamilyStatus readFamilyStatus(Object? raw) {
  return requireRead(FamilyStatus.fromApi(raw), 'family status', raw);
}

SchoolShift? readOptionalSchoolShift(Object? raw) => SchoolShift.fromApi(raw);

@Freezed(toJson: false)
abstract class FamilyMatchDto with _$FamilyMatchDto implements FamilyMatch {
  const factory FamilyMatchDto({
    @JsonKey(fromJson: readToken) required String token,
    @JsonKey(fromJson: readToken) required String dependentToken,
    @Default('') String dependentName,
    int? dependentAge,
    @Default('') String clientName,
  }) = _FamilyMatchDto;

  factory FamilyMatchDto.fromJson(Map<String, Object?> json) =>
      _$FamilyMatchDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class DriverStudentDto
    with _$DriverStudentDto
    implements DriverStudent {
  const factory DriverStudentDto({
    @JsonKey(fromJson: readToken) required String token,
    @JsonKey(fromJson: readStudentSource) required StudentSource source,
    @Default('') String name,
    @Default('') String schoolName,
    @JsonKey(fromJson: readOptionalSchoolShift) SchoolShift? schoolShift,
    @Default([]) List<ScheduleSlotDto> slots,
    String? vehicleToken,
    String? dependentToken,
    @JsonKey(fromJson: readFamilyStatus) required FamilyStatus familyStatus,
    @JsonKey(fromJson: readOptionalInstant) DateTime? invitedAt,
    FamilyMatchDto? familyMatch,
  }) = _DriverStudentDto;

  factory DriverStudentDto.fromJson(Map<String, Object?> json) =>
      _$DriverStudentDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class FamilyInviteDto with _$FamilyInviteDto implements FamilyInvite {
  const factory FamilyInviteDto({
    @JsonKey(fromJson: readToken) required String code,
    @JsonKey(fromJson: readToken) required String inviteUrl,
    @JsonKey(fromJson: readInstant) required DateTime sentAt,
  }) = _FamilyInviteDto;

  factory FamilyInviteDto.fromJson(Map<String, Object?> json) =>
      _$FamilyInviteDtoFromJson(json);
}
