import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

const environment = Environment(
  authBaseUrl: 'http://localhost:8080',
  oauthClientId: 'vanep-mobile',
);

const conversationJson = <String, dynamic>{
  'token': 'conversation-1',
  'driverToken': 'driver-1',
  'driverName': 'Carlos',
  'clientName': 'Maria',
  'lastMessageAt': '2026-10-12T09:00:00Z',
};

const messageJson = <String, dynamic>{
  'token': 'message-1',
  'body': 'Tem vaga?',
  'sender': 'CLIENT',
  'sentAt': '2026-10-12T09:00:00Z',
};

Response<T> okResponse<T>(T data) =>
    Response<T>(requestOptions: RequestOptions(), data: data, statusCode: 200);

void main() {
  late MockDio dio;
  late ConversationRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = ConversationRemoteDataSource(dio: dio, environment: environment);
  });

  test('openConversation posts the driver token', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        'http://localhost:8080/api/conversations',
        data: {'driverToken': 'driver-1'},
      ),
    ).thenAnswer((_) async => okResponse(conversationJson));

    final conversation = await remote.openConversation('driver-1');

    expect(conversation.token, 'conversation-1');
  });

  test('listMyConversations reads the driver list', () async {
    when(
      () =>
          dio.get<List<dynamic>>('http://localhost:8080/api/conversations/me'),
    ).thenAnswer((_) async => okResponse<List<dynamic>>([conversationJson]));

    final conversations = await remote.listMyConversations();

    expect(conversations.single.clientName, 'Maria');
  });

  test('listMessages asks for the page with the page size', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        'http://localhost:8080/api/conversations/conversation-1/messages',
        queryParameters: {'page': 2, 'size': conversationHistoryPageSize},
      ),
    ).thenAnswer(
      (_) async => okResponse(<String, dynamic>{
        'content': [messageJson],
        'number': 2,
        'totalPages': 3,
      }),
    );

    final page = await remote.listMessages(
      conversationToken: 'conversation-1',
      page: 2,
    );

    expect(page.messages.single.token, 'message-1');
    expect(page.hasMore, isFalse);
  });

  test('sendMessage posts the body', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        'http://localhost:8080/api/conversations/conversation-1/messages',
        data: {'body': 'Tem vaga?'},
      ),
    ).thenAnswer((_) async => okResponse(messageJson));

    final message = await remote.sendMessage(
      conversationToken: 'conversation-1',
      body: 'Tem vaga?',
    );

    expect(message.body, 'Tem vaga?');
  });

  test('an empty payload is a format error', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        'http://localhost:8080/api/conversations',
        data: {'driverToken': 'driver-1'},
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(),
        statusCode: 200,
      ),
    );

    expect(() => remote.openConversation('driver-1'), throwsFormatException);
  });
}
