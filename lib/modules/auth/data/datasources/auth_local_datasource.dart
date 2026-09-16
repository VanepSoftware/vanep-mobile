import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../dtos/auth_session_dto.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const String sessionKey = 'auth_session';
  static const String legacyHiveBoxName = 'auth';

  Future<void> saveSession(AuthSessionDto session) {
    return _storage.write(key: sessionKey, value: jsonEncode(session.toJson()));
  }

  Future<AuthSessionDto?> readSession() async {
    try {
      final raw = await _storage.read(key: sessionKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionDto.fromJson(json);
    } on FormatException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> clearSession() => _storage.delete(key: sessionKey);
}
