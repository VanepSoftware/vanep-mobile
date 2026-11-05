import 'dart:async';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:vanep_mobile/core/network/access_token_source.dart';
import 'package:vanep_mobile/modules/conversations/data/dtos/conversation_message_dto.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';

typedef StompClientFactory =
    StompClient Function({required StompConfig config});

String conversationTopic(String conversationToken) =>
    '/topic/conversations/$conversationToken';

class ConversationRealtimeDataSource {
  ConversationRealtimeDataSource({
    required this.webSocketUrl,
    required this.accessTokens,
    this.createStompClient = StompClient.new,
    this.reconnectDelay = const Duration(seconds: 5),
  });

  final String webSocketUrl;
  final AccessTokenSource accessTokens;
  final StompClientFactory createStompClient;
  final Duration reconnectDelay;

  Stream<ConversationRealtimeEvent> watchConversation(
    String conversationToken,
  ) {
    final events = StreamController<ConversationRealtimeEvent>();
    final connection = ConversationRealtimeConnection(
      dataSource: this,
      conversationToken: conversationToken,
      events: events,
    );
    events
      ..onListen = connection.start
      ..onCancel = connection.stop;
    return events.stream;
  }
}

// Reconnection is driven here instead of by StompClient because its handshake
// headers are fixed at construction: every attempt needs the current token.
class ConversationRealtimeConnection {
  ConversationRealtimeConnection({
    required this.dataSource,
    required this.conversationToken,
    required this.events,
  });

  final ConversationRealtimeDataSource dataSource;
  final String conversationToken;
  final StreamController<ConversationRealtimeEvent> events;

  StompClient? client;
  Timer? reconnectTimer;
  bool stopped = false;
  bool hasConnectedBefore = false;
  bool connectedInThisAttempt = false;
  bool thisAttemptRefreshedToken = false;
  bool refreshTokenOnNextAttempt = false;

  void start() => unawaited(connect());

  Future<void> connect() async {
    final refresh = refreshTokenOnNextAttempt;
    refreshTokenOnNextAttempt = false;
    final token = refresh
        ? await dataSource.accessTokens.refreshAccessToken()
        : await dataSource.accessTokens.readAccessToken();
    if (stopped) return;
    thisAttemptRefreshedToken = refresh;
    connectedInThisAttempt = false;
    final attempt = dataSource.createStompClient(
      config: StompConfig(
        url: dataSource.webSocketUrl,
        reconnectDelay: Duration.zero,
        webSocketConnectHeaders: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        onConnect: subscribeToConversation,
        onWebSocketError: (_) => handleConnectionLost(),
        onWebSocketDone: handleConnectionLost,
      ),
    );
    client = attempt;
    attempt.activate();
  }

  void subscribeToConversation(StompFrame connectedFrame) {
    connectedInThisAttempt = true;
    client?.subscribe(
      destination: conversationTopic(conversationToken),
      callback: emitReceivedMessage,
    );
    if (hasConnectedBefore) {
      events.add(const ConversationRealtimeReconnected());
    }
    hasConnectedBefore = true;
  }

  void emitReceivedMessage(StompFrame frame) {
    final message = tryReadConversationMessageFrame(frame.body);
    if (message != null) {
      events.add(ConversationMessageReceived(message));
    }
  }

  void handleConnectionLost() {
    if (stopped || (reconnectTimer?.isActive ?? false)) return;
    if (!connectedInThisAttempt && !thisAttemptRefreshedToken) {
      refreshTokenOnNextAttempt = true;
    }
    client?.deactivate();
    reconnectTimer = Timer(
      dataSource.reconnectDelay,
      () => unawaited(connect()),
    );
  }

  void stop() {
    stopped = true;
    reconnectTimer?.cancel();
    client?.deactivate();
  }
}
