import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

class AssistantChecklistItem extends Equatable {
  const AssistantChecklistItem({
    required this.studentToken,
    required this.studentName,
    required this.schoolName,
    required this.stopId,
    required this.stopAddress,
    this.scheduledTime,
    this.photoUrl,
    this.status = BoardingStatus.pending,
    this.confirmedBy,
    this.noShowReason,
  });

  final String studentToken;
  final String studentName;
  final String schoolName;
  final String stopId;
  final String stopAddress;
  final String? scheduledTime;
  final String? photoUrl;
  final BoardingStatus status;
  final ConfirmationSource? confirmedBy;
  final NoShowReason? noShowReason;

  bool get isHandled =>
      status == BoardingStatus.boarded ||
      status == BoardingStatus.droppedOff ||
      status == BoardingStatus.noShow;

  AssistantChecklistItem copyWith({
    BoardingStatus? status,
    ConfirmationSource? Function()? confirmedBy,
    NoShowReason? Function()? noShowReason,
  }) {
    return AssistantChecklistItem(
      studentToken: studentToken,
      studentName: studentName,
      schoolName: schoolName,
      stopId: stopId,
      stopAddress: stopAddress,
      scheduledTime: scheduledTime,
      photoUrl: photoUrl,
      status: status ?? this.status,
      confirmedBy: confirmedBy != null ? confirmedBy() : this.confirmedBy,
      noShowReason: noShowReason != null ? noShowReason() : this.noShowReason,
    );
  }

  @override
  List<Object?> get props => [
    studentToken,
    studentName,
    schoolName,
    stopId,
    stopAddress,
    scheduledTime,
    photoUrl,
    status,
    confirmedBy,
    noShowReason,
  ];
}
