import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

class AssistantChecklistItemDto extends AssistantChecklistItem {
  const AssistantChecklistItemDto({
    required super.studentToken,
    required super.studentName,
    required super.schoolName,
    required super.stopId,
    required super.stopAddress,
    super.scheduledTime,
    super.photoUrl,
    super.status,
    super.confirmedBy,
    super.noShowReason,
  });

  factory AssistantChecklistItemDto.fromJson(Map<String, Object?> json) {
    return AssistantChecklistItemDto(
      studentToken: json['studentToken'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      schoolName: json['schoolName'] as String? ?? '',
      stopId: json['stopId'] as String? ?? '',
      stopAddress: json['stopAddress'] as String? ?? '',
      scheduledTime: json['scheduledTime'] as String?,
      photoUrl: json['photoUrl'] as String?,
      status: BoardingStatus.fromApi(json['status']),
      confirmedBy: ConfirmationSource.fromApi(
        json['confirmedBy'] ?? json['confirmed_by'],
      ),
      noShowReason: NoShowReason.fromApi(
        json['noShowReason'] ?? json['no_show_reason'],
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'studentToken': studentToken,
      'studentName': studentName,
      'schoolName': schoolName,
      'stopId': stopId,
      'stopAddress': stopAddress,
      if (scheduledTime != null) 'scheduledTime': scheduledTime,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'status': BoardingStatus.toApi(status),
      if (confirmedBy != null)
        'confirmedBy': ConfirmationSource.toApi(confirmedBy),
      if (noShowReason != null)
        'noShowReason': NoShowReason.toApi(noShowReason!),
    };
  }
}

class AssistantTripStopDto extends AssistantTripStop {
  const AssistantTripStopDto({
    required super.id,
    required super.order,
    required super.title,
    required super.address,
    super.scheduledTime,
    super.isSchool,
    super.items,
  });

  factory AssistantTripStopDto.fromJson(Map<String, Object?> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(
          (item) =>
              AssistantChecklistItemDto.fromJson(Map<String, Object?>.from(item)),
        )
        .toList();

    return AssistantTripStopDto(
      id: json['id'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      address: json['address'] as String? ?? '',
      scheduledTime: json['scheduledTime'] as String?,
      isSchool: json['isSchool'] as bool? ?? false,
      items: items,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'address': address,
      if (scheduledTime != null) 'scheduledTime': scheduledTime,
      'isSchool': isSchool,
      'items': items
          .map(
            (e) => AssistantChecklistItemDto(
              studentToken: e.studentToken,
              studentName: e.studentName,
              schoolName: e.schoolName,
              stopId: e.stopId,
              stopAddress: e.stopAddress,
              scheduledTime: e.scheduledTime,
              photoUrl: e.photoUrl,
              status: e.status,
              confirmedBy: e.confirmedBy,
              noShowReason: e.noShowReason,
            ).toJson(),
          )
          .toList(),
    };
  }
}
