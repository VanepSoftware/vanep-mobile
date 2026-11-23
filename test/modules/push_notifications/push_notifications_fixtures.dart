import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';

const pushToken = 'fcm-token-1';

const refreshedPushToken = 'fcm-token-2';

const chatPushData = <String, Object?>{
  'type': 'chat',
  'conversationToken': 'conv-1',
  'counterpartName': 'Carlos',
};

const chatPushTarget = ChatPushTarget(
  conversationToken: 'conv-1',
  counterpartName: 'Carlos',
);

const chatPushMessage = PushMessage(
  title: 'Carlos',
  body: 'Chego em 5 minutos',
  data: chatPushData,
);

const silentPushMessage = PushMessage(data: chatPushData);
