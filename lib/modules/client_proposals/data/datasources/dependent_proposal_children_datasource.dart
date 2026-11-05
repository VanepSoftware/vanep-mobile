import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposal_children_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';

class ProposalChildrenUnavailable implements Exception {
  const ProposalChildrenUnavailable(this.failure);

  final DependentFailure failure;

  bool get isNetwork => failure is DependentNetworkFailure;
}

ProposalChild proposalChildFromDependent(Dependent dependent) {
  return ProposalChild(
    token: dependent.token,
    name: dependent.name,
    birthDate: dependent.birthDate,
  );
}

class DependentProposalChildrenDataSource
    implements ProposalChildrenDataSource {
  const DependentProposalChildrenDataSource({required this.findMyDependents});

  final FindMyDependents findMyDependents;

  @override
  Future<List<ProposalChild>> findChildren() async {
    final result = await findMyDependents();
    return result.fold(
      (failure) => throw ProposalChildrenUnavailable(failure),
      (dependents) => dependents.map(proposalChildFromDependent).toList(),
    );
  }
}
