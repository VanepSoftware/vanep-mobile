import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

class ProposalDetail extends Equatable {
  const ProposalDetail({
    required this.request,
    this.proposal,
    this.versions = const [],
  });

  final ClientServiceRequest request;

  final Proposal? proposal;

  final List<Proposal> versions;

  @override
  List<Object?> get props => [request, proposal, versions];
}
