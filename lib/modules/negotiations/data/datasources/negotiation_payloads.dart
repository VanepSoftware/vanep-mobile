import 'package:vanep_mobile/modules/negotiations/data/dtos/negotiation_json.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/proposal_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

String negotiationPath(String endpoint, String token, [String? action]) {
  final path = '$endpoint/${Uri.encodeComponent(token)}';
  return action == null ? path : '$path/$action';
}

Map<String, Object?> listQuery({
  required Set<ServiceRequestStatus> statuses,
  String? conversationToken,
  required int page,
}) {
  final sortedStatuses = [...statuses]
    ..sort((first, second) => first.index.compareTo(second.index));
  return {
    if (sortedStatuses.isNotEmpty)
      'status': sortedStatuses.map((status) => status.apiName).join(','),
    'conversationToken': ?conversationToken,
    'page': page,
  };
}

Map<String, Object?> requireJsonObject(Object? payload) {
  if (payload is! Map<String, dynamic>) {
    throw FormatException('Unreadable negotiation payload.', payload);
  }
  return Map<String, Object?>.from(payload);
}

List<T> readEachJsonObject<T>(
  Object? payload,
  T Function(Map<String, Object?> json) read,
) {
  if (payload is! List) {
    throw FormatException('Unreadable negotiation list.', payload);
  }
  return [for (final entry in payload) read(requireJsonObject(entry))];
}

T readOne<T>(
  Map<String, dynamic>? payload,
  T Function(Map<String, Object?> json) read,
) {
  return read(requireJsonObject(payload));
}

NegotiationPage<T> readPage<T>(
  Map<String, dynamic>? payload,
  T Function(Map<String, Object?> json) read,
) {
  final body = requireJsonObject(payload);
  final isLast = body['last'];
  if (isLast is! bool) throw FormatException('Unreadable page end.', body);
  return NegotiationPage(
    items: readEachJsonObject(body['content'], read),
    isLast: isLast,
    totalElements: readInt(body['totalElements']),
  );
}

List<Proposal> readProposalVersions(List<dynamic>? payload) {
  return readEachJsonObject(payload, ProposalDto.fromJson);
}
