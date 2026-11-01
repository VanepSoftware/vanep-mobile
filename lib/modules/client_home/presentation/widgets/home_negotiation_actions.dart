import 'package:flutter/widgets.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

class HomeNegotiationActions {
  const HomeNegotiationActions({
    required this.onProposalTapped,
    required this.onChatTapped,
    required this.onFindVanTapped,
  });

  final void Function(ClientServiceRequest request) onProposalTapped;

  final void Function(ClientServiceRequest request) onChatTapped;

  final VoidCallback onFindVanTapped;
}
