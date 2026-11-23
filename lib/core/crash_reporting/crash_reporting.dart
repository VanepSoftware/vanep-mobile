import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future<void> startCrashReporting(
  FirebaseCrashlytics crashlytics, {
  required bool collectionEnabled,
}) async {
  await crashlytics.setCrashlyticsCollectionEnabled(collectionEnabled);
  if (!collectionEnabled) return;
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    crashlytics.recordError(error, stackTrace, fatal: true);
    return true;
  };
}
