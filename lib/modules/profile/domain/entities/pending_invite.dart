abstract class PendingInviteDriver {
  String? get name;

  String? get photoUrl;

  String? get city;

  double? get rating;
}

abstract class PendingInvite {
  String get token;

  String? get expiresAt;

  PendingInviteDriver? get driver;
}
