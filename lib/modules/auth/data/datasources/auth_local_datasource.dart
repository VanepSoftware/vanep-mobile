import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../dtos/auth_session_dto.dart';

/// Persists the authenticated session in a Hive box as a JSON string, so the
/// user stays signed in across app launches.
class AuthLocalDataSource {
  AuthLocalDataSource(this._box);

  final Box<String> _box;

  static const String boxName = 'auth';
  static const String _sessionKey = 'session';

  /// Stores (or replaces) the current session.
  Future<void> saveSession(AuthSessionDto session) {
    return _box.put(_sessionKey, jsonEncode(session.toJson()));
  }

  /// Reads the persisted session, or `null` when none is stored (or the stored
  /// payload is unreadable — treated as "no session").
  AuthSessionDto? readSession() {
    final raw = _box.get(_sessionKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionDto.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  /// Removes any persisted session.
  Future<void> clearSession() => _box.delete(_sessionKey);
}
