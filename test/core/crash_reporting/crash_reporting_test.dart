import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/crash_reporting/crash_reporting.dart';

import '../../modules/push_notifications/push_notifications_mocks.dart';

void main() {
  late MockFirebaseCrashlytics crashlytics;

  setUp(() {
    crashlytics = MockFirebaseCrashlytics();
    when(() => crashlytics.setCrashlyticsCollectionEnabled(any()))
        .thenAnswer((_) async {});
    when(
      () => crashlytics.recordError(any(), any(), fatal: any(named: 'fatal')),
    ).thenAnswer((_) async {});
  });

  test('disabled collection leaves the error handlers untouched', () async {
    final flutterErrorHandler = FlutterError.onError;
    final platformErrorHandler = PlatformDispatcher.instance.onError;

    await startCrashReporting(crashlytics, collectionEnabled: false);

    verify(() => crashlytics.setCrashlyticsCollectionEnabled(false)).called(1);
    expect(FlutterError.onError, flutterErrorHandler);
    expect(PlatformDispatcher.instance.onError, platformErrorHandler);
  });

  test('enabled collection records Flutter and platform errors', () async {
    final flutterErrorHandler = FlutterError.onError;
    final platformErrorHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = flutterErrorHandler;
      PlatformDispatcher.instance.onError = platformErrorHandler;
    });

    await startCrashReporting(crashlytics, collectionEnabled: true);

    verify(() => crashlytics.setCrashlyticsCollectionEnabled(true)).called(1);
    expect(FlutterError.onError, isNot(flutterErrorHandler));
    final error = StateError('boom');
    final handled = PlatformDispatcher.instance.onError!(
      error,
      StackTrace.empty,
    );
    expect(handled, isTrue);
    verify(() => crashlytics.recordError(error, StackTrace.empty, fatal: true))
        .called(1);
  });
}
