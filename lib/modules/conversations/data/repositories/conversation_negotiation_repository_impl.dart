import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_negotiation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

class ConversationNegotiationRepositoryImpl
    implements ConversationNegotiationRepository {
  const ConversationNegotiationRepositoryImpl({required this.dataSource});

  final ConversationNegotiationDataSource dataSource;

  @override
  Future<Result<ConversationFailure, ConversationNegotiation>> findNegotiation(
    String conversationToken,
  ) async {
    try {
      return Ok(await dataSource.findNegotiation(conversationToken));
    } on Object {
      return const Err(ConversationUnexpectedFailure());
    }
  }
}
