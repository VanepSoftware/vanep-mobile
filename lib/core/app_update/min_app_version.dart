import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Remote Config parameter (String, e.g. "1.2.0"). Apps with a lower version
/// are blocked behind the upgrade wall. "0.0.0" (or empty) blocks nobody.
const minAppVersionKey = 'min_app_version';

/// Reads the minimum supported app version from Remote Config.
///
/// Never throws and never waits longer than [timeout]: on any failure it falls
/// back to the last activated value (or the default), so a flaky network can
/// not block startup nor lock users out.
Future<String?> loadMinAppVersion(
  FirebaseRemoteConfig remoteConfig, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: timeout,
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(minutes: 15),
      ),
    );
    await remoteConfig.setDefaults({minAppVersionKey: '0.0.0'});
    await remoteConfig.fetchAndActivate().timeout(timeout);
  } on Object catch (error) {
    debugPrint('min_app_version: using cached/default value ($error)');
  }
  final value = remoteConfig.getString(minAppVersionKey).trim();
  return value.isEmpty ? null : value;
}
