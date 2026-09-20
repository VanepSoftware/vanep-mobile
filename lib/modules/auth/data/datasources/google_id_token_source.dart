import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleIdTokenSource {
  Future<String?> requestIdToken();

  Future<void> signOut();
}

class GoogleIdTokenException extends Equatable implements Exception {
  const GoogleIdTokenException(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}

class GoogleSignInIdTokenSource implements GoogleIdTokenSource {
  GoogleSignInIdTokenSource({
    required this.googleSignIn,
    required this.serverClientId,
  });

  final GoogleSignIn googleSignIn;
  final String serverClientId;
  Future<void>? _initialization;

  @override
  Future<String?> requestIdToken() async {
    if (serverClientId.isEmpty) {
      throw const GoogleIdTokenException('missing_server_client_id');
    }
    try {
      await initializeOnce();
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const GoogleIdTokenException('missing_id_token');
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw GoogleIdTokenException(error.code.name);
    } on PlatformException catch (error) {
      throw GoogleIdTokenException(error.code);
    }
  }

  @override
  Future<void> signOut() async {
    if (_initialization == null) return;
    await googleSignIn.signOut();
  }

  Future<void> initializeOnce() {
    return _initialization ??= googleSignIn.initialize(
      serverClientId: serverClientId,
    );
  }
}
