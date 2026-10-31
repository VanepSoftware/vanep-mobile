import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/negotiations/data/dtos/negotiation_json.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';

part 'proposal_summary_dto.freezed.dart';
part 'proposal_summary_dto.g.dart';

@Freezed(toJson: false)
abstract class ProposalSummaryDto
    with _$ProposalSummaryDto
    implements ProposalSummary {
  const factory ProposalSummaryDto({
    @JsonKey(fromJson: readToken) required String token,
    @JsonKey(fromJson: readInt) required int version,
    @JsonKey(fromJson: readProposalStatus) required ProposalStatus status,
    @JsonKey(name: 'totalAmount', fromJson: readCents)
    required int totalAmountCents,
    @JsonKey(fromJson: readInt) required int installments,
    @JsonKey(name: 'installmentAmount', fromJson: readCents)
    required int installmentAmountCents,
    @JsonKey(name: 'lastInstallmentAmount', fromJson: readCents)
    required int lastInstallmentAmountCents,
    @JsonKey(fromJson: readInstant) required DateTime validUntil,
    @JsonKey(fromJson: readCalendarDate) required DateTime startsOn,
    @Default(false) bool hasPendingAdjustment,
  }) = _ProposalSummaryDto;

  factory ProposalSummaryDto.fromJson(Map<String, Object?> json) =>
      _$ProposalSummaryDtoFromJson(json);
}
