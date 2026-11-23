abstract class SessionLifecycleObserver {
  Future<void> onSessionStarted();

  /// Runs while the session's access token is still valid, before sign-out
  /// revokes it.
  Future<void> onSessionEnding();
}
