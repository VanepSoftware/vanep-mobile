import 'package:flutter/material.dart';

import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

typedef DriverRequestCallback = Future<void> Function(
  DriverServiceRequest request,
);

class DriverNegotiationActions {
  const DriverNegotiationActions({
    required this.onChat,
    required this.onDecline,
  });

  final DriverRequestCallback onChat;
  final Future<RequestDeclineOutcome?> Function(DriverServiceRequest request)
  onDecline;

  VoidCallback? chatWith(DriverServiceRequest request) {
    if (request.conversationToken == null) return null;
    return () => onChat(request);
  }
}

Future<void> declineAndLeave(
  BuildContext context, {
  required DriverNegotiationActions actions,
  required DriverServiceRequest request,
  required Future<void> Function() reload,
}) async {
  final navigator = Navigator.of(context);
  switch (await actions.onDecline(request)) {
    case RequestDeclineOutcome.declined:
      navigator.pop(true);
    case RequestDeclineOutcome.outdated:
      await reload();
    case null:
      return;
  }
}
