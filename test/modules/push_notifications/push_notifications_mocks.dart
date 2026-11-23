import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/push_device_remote_datasource.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/local_notification_display.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_device_repository.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_messaging_gateway.dart';

class MockPushMessagingGateway extends Mock implements PushMessagingGateway {}

class MockPushDeviceRepository extends Mock implements PushDeviceRepository {}

class MockLocalNotificationDisplay extends Mock
    implements LocalNotificationDisplay {}

class MockPushDeviceRemoteDataSource extends Mock
    implements PushDeviceRemoteDataSource {}

class MockDio extends Mock implements Dio {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}
