import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

abstract class ProposalChildrenDataSource {
  Future<List<ProposalChild>> findChildren();
}
