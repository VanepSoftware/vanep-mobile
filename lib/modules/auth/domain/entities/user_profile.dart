/// Authenticated user's profile as returned by the backend.
///
/// Abstract by design (constitution R04): the data layer's DTO implements it,
/// so presentation and domain depend on this contract, never on JSON shapes.
abstract class UserProfile {
  /// Opaque user token used as the stable identity of the account.
  String get token;

  /// Display name, when the backend has one.
  String? get name;

  /// E-mail address, when available.
  String? get email;
}
