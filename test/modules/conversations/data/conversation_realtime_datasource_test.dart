import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:vanep_mobile/core/network/access_token_source.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';

class FakeStompClient implements StompClient {
  FakeStompClient({required this.config});

  @override
  final StompConfig config;

  bool activated = false;
  bool deactivated = false;
  final Map<String, StompFrameCallback> callbacksByDestination = {};

  @override
  void activate() => activated = true;

  @override
  void deactivate() => deactivated = true;

  @override
  StompUnsubscribe subscribe({
    required String destination,
    required StompFrameCallback callback,
    Map<String, String>? headers,
  }) {
    callbacksByDestination[destination] = callback;
    return ({Map<String, String>? unsubscribeHeaders}) {};
  }

  void connect() => config.onConnect(StompFrame(command: 'CONNECTED'));

  void deliver(String destination, String body) {
    callbacksByDestination[destination]!(
      StompFrame(command: 'MESSAGE', body: body),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const topic = '/topic/conversations/conversation-1';

final messageBody = jsonEncode({
  'token': 'message-1',
  'body': 'Tem vaga?',
  'sender': 'CLIENT',
  'sentAt': '2026-10-12T09:00:00Z',
});

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  late List<FakeStompClient> clients;
  late String currentToken;
  late int refreshCount;
  late ConversationRealtimeDataSource dataSource;

  setUp(() {
    clients = [];
    currentToken = 'token-1';
    refreshCount = 0;
    dataSource = ConversationRealtimeDataSource(
      webSocketUrl: 'ws://localhost:8080/api/ws',
      accessTokens: AccessTokenSource(
        readAccessToken: () async => currentToken,
        refreshAccessToken: () async {
          refreshCount++;
          return 'refreshed';
        },
      ),
      createStompClient: ({required StompConfig config}) {
        final client = FakeStompClient(config: config);
        clients.add(client);
        return client;
      },
      reconnectDelay: Duration.zero,
    );
  });

  test('connects to the WebSocket URL with the current token', () async {
    final subscription = dataSource
        .watchConversation('conversation-1')
        .listen((_) {});
    await settle();

    final client = clients.single;
    expect(client.config.url, 'ws://localhost:8080/api/ws');
    expect(client.config.webSocketConnectHeaders, {
      'Authorization': 'Bearer token-1',
    });
    expect(client.activated, isTrue);
    await subscription.cancel();
  });

  test('emits the messages received on the conversation topic', () async {
    final events = <ConversationRealtimeEvent>[];
    final subscription = dataSource
        .watchConversation('conversation-1')
        .listen(events.add);
    await settle();

    clients.single
      ..connect()
      ..deliver(topic, messageBody);
    await settle();

    final received = events.single as ConversationMessageReceived;
    expect(received.message.token, 'message-1');
    await subscription.cancel();
  });

  test('a frame that is not a message is ignored', () async {
    final events = <ConversationRealtimeEvent>[];
    final subscription = dataSource
        .watchConversation('conversation-1')
        .listen(events.add);
    await settle();

    clients.single
      ..connect()
      ..deliver(topic, 'not json')
      ..deliver(topic, '{"token": 1}');
    await settle();

    expect(events, isEmpty);
    await subscription.cancel();
  });

  test('a lost connection reconnects with the current token', () async {
    final events = <ConversationRealtimeEvent>[];
    final subscription = dataSource
        .watchConversation('conversation-1')
        .listen(events.add);
    await settle();
    clients.single.connect();

    currentToken = 'token-2';
    clients.single.config.onWebSocketDone();
    await settle();

    expect(clients, hasLength(2));
    expect(clients.first.deactivated, isTrue);
    expect(clients.last.config.webSocketConnectHeaders, {
      'Authorization': 'Bearer token-2',
    });
    expect(events, isEmpty);

    clients.last.connect();
    await settle();

    expect(events, [const ConversationRealtimeReconnected()]);
    await subscription.cancel();
  });

  test('a failure before connecting refreshes the token once', () async {
    final subscription = dataSource
        .watchConversation('conversation-1')
        .listen((_) {});
    await settle();

    clients.single.config.onWebSocketError(Exception('not upgraded'));
    await settle();

    expect(refreshCount, 1);
    expect(clients.last.config.webSocketConnectHeaders, {
      'Authorization': 'Bearer refreshed',
    });

    clients.last.config.onWebSocketError(Exception('not upgraded'));
    await settle();

    expect(refreshCount, 1);
    expect(clients.last.config.webSocketConnectHeaders, {
      'Authorization': 'Bearer token-1',
    });
    await subscription.cancel();
  });

  test('cancelling stops the client and any reconnection', () async {
    final subscription = dataSource
        .watchConversation('conversation-1')
        .listen((_) {});
    await settle();
    clients.single.connect();

    await subscription.cancel();
    clients.single.config.onWebSocketDone();
    await settle();

    expect(clients.single.deactivated, isTrue);
    expect(clients, hasLength(1));
  });
}
