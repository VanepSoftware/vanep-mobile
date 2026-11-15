import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';

String? resolveProposalVehicle(String? vehicleToken, List<DriverVan> vans) {
  if (vans.any((van) => van.token == vehicleToken)) return vehicleToken;
  return vans.length == 1 ? vans.single.token : null;
}

class ProposalComposerSetup extends Equatable {
  const ProposalComposerSetup({
    required this.request,
    required this.vans,
    required this.draft,
  });

  factory ProposalComposerSetup.from({
    required DriverServiceRequest request,
    required List<DriverVan> vans,
    Proposal? previousVersion,
  }) {
    final draft = previousVersion == null
        ? ProposalDraft.fromRequest(request)
        : ProposalDraft.fromProposal(previousVersion, request);
    return ProposalComposerSetup(
      request: request,
      vans: vans,
      draft: draft.withVehicle(
        resolveProposalVehicle(draft.vehicleToken, vans),
      ),
    );
  }

  final DriverServiceRequest request;

  final List<DriverVan> vans;

  final ProposalDraft draft;

  bool get hasNoVan => vans.isEmpty;

  ProposalComposerSetup withVans(List<DriverVan> vans) {
    return ProposalComposerSetup(
      request: request,
      vans: vans,
      draft: draft.withVehicle(
        resolveProposalVehicle(draft.vehicleToken, vans),
      ),
    );
  }

  ProposalComposerSetup withDraft(ProposalDraft draft) {
    return ProposalComposerSetup(request: request, vans: vans, draft: draft);
  }

  bool get choosesVan => vans.length > 1;

  @override
  List<Object?> get props => [request, vans, draft];
}
