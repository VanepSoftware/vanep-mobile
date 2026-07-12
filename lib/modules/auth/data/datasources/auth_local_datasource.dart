import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../dtos/auth_session_dto.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._box);

  final Box<String> _box;

  static const String boxName = 'auth';
  static const String _sessionKey = 'session';

  Future<void> saveSession(AuthSessionDto session) {
    return _box.put(_sessionKey, jsonEncode(session.toJson()));
  }

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

  Future<void> clearSession() => _box.delete(_sessionKey);
}
