import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';

class AssistantTripStop extends Equatable {
  const AssistantTripStop({
    required this.id,
    required this.order,
    required this.title,
    required this.address,
    this.scheduledTime,
    this.isSchool = false,
    this.items = const [],
  });

  final String id;
  final int order;
  final String title;
  final String address;
  final String? scheduledTime;
  final bool isSchool;
  final List<AssistantChecklistItem> items;

  AssistantTripStop copyWith({
    List<AssistantChecklistItem>? items,
  }) {
    return AssistantTripStop(
      id: id,
      order: order,
      title: title,
      address: address,
      scheduledTime: scheduledTime,
      isSchool: isSchool,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    order,
    title,
    address,
    scheduledTime,
    isSchool,
    items,
  ];
}
