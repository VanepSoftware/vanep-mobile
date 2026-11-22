import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/resolve_document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';

class DocumentEntry extends Equatable {
  const DocumentEntry({required this.requirement, required this.state});

  final RequirementStatus requirement;
  final DocumentDisplayState state;

  @override
  List<Object?> get props => [requirement.type, state];
}

class DocumentGroups extends Equatable {
  const DocumentGroups({
    required this.pending,
    required this.sent,
    required this.optional,
  });

  final List<DocumentEntry> pending;
  final List<DocumentEntry> sent;
  final List<DocumentEntry> optional;

  List<DocumentEntry> get all => [...pending, ...sent, ...optional];

  @override
  List<Object?> get props => [pending, sent, optional];
}

class VehicleDocumentGroups {
  const VehicleDocumentGroups({required this.vehicle, required this.groups});

  final VehicleCompliance vehicle;
  final DocumentGroups groups;

  int get pendingCount => groups.pending.length;

  bool get isUpToDate => pendingCount == 0;
}

DocumentGroups groupDocuments(
  List<RequirementStatus> requirements,
  DateTime asOf,
) {
  final entries =
      [
        for (final requirement in requirements)
          DocumentEntry(
            requirement: requirement,
            state: resolveDocumentDisplayState(requirement, asOf),
          ),
      ]..sort(
        (left, right) =>
            left.requirement.type.index - right.requirement.type.index,
      );
  final required = [
    for (final entry in entries)
      if (!entry.requirement.optional) entry,
  ];
  return DocumentGroups(
    pending: [
      for (final entry in required)
        if (entry.state.needsAction) entry,
    ],
    sent: [
      for (final entry in required)
        if (!entry.state.needsAction) entry,
    ],
    optional: [
      for (final entry in entries)
        if (entry.requirement.optional) entry,
    ],
  );
}

List<VehicleDocumentGroups> groupVehicleDocuments(
  List<VehicleCompliance> vehicles,
  DateTime asOf, {
  String? onlyVehicleToken,
}) {
  final groups = [
    for (final vehicle in vehicles)
      if (onlyVehicleToken == null || vehicle.token == onlyVehicleToken)
        VehicleDocumentGroups(
          vehicle: vehicle,
          groups: groupDocuments(vehicle.requirements, asOf),
        ),
  ];
  return [
    ...groups.where((van) => !van.isUpToDate),
    ...groups.where((van) => van.isUpToDate),
  ];
}
