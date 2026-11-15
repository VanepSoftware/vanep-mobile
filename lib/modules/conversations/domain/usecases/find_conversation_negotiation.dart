import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

typedef ListNegotiationRequests<R extends ServiceRequest> =
    Future<Result<NegotiationFailure, NegotiationPage<R>>> Function({
      required Set<ServiceRequestStatus> statuses,
      String? conversationToken,
      int page,
    });

typedef ListNegotiationVersions =
    Future<Result<NegotiationFailure, List<Proposal>>> Function(
      String serviceRequestToken,
    );

class FindConversationNegotiation<R extends ServiceRequest> {
  const FindConversationNegotiation({
    required this.listRequests,
    required this.listVersions,
  });

  final ListNegotiationRequests<R> listRequests;

  final ListNegotiationVersions listVersions;

  Future<Result<NegotiationFailure, ConversationNegotiation<R>?>> call(
    String conversationToken,
  ) async {
    final requestsResult = await listRequests(
      statuses: const {},
      conversationToken: conversationToken,
    );
    final requests = requestsResult.valueOrNull?.items;
    if (requests == null) return Err(requestsResult.errorOrNull!);
    if (requests.isEmpty) return const Ok(null);

    final latest = requests.first;
    final versionsResult = await listVersions(latest.token);
    return versionsResult.fold(
      Err.new,
      (versions) =>
          Ok(ConversationNegotiation(request: latest, versions: versions)),
    );
  }
}
