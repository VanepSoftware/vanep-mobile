import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/builders/profile_menu_builder.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_menu_id.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

List<ProfileMenuId> menuIds(List<ProfileMenuSection> sections) {
  return [
    for (final section in sections)
      for (final entry in section.entries) entry.id,
  ];
}

Map<ProfileMenuId, bool> enabledById(List<ProfileMenuSection> sections) {
  return {
    for (final section in sections)
      for (final entry in section.entries) entry.id: entry.enabled,
  };
}

void main() {
  test('client menu keeps only account management items', () {
    final menu = buildProfileMenu(UserType.client);
    final enabled = enabledById(menu);

    expect(menuIds(menu), [
      ProfileMenuId.personalData,
      ProfileMenuId.addresses,
      ProfileMenuId.paymentMethods,
      ProfileMenuId.settings,
      ProfileMenuId.privacySecurity,
      ProfileMenuId.signOut,
    ]);
    expect(enabled[ProfileMenuId.personalData], isTrue);
    expect(enabled[ProfileMenuId.signOut], isTrue);
    expect(enabled[ProfileMenuId.addresses], isFalse);
    expect(enabled[ProfileMenuId.paymentMethods], isFalse);
    expect(menu.map((section) => section.title).toList(), [
      ProfileMenuSectionTitle.account,
      ProfileMenuSectionTitle.preferences,
      null,
    ]);
  });

  test('driver menu keeps professional data under the account section', () {
    final menu = buildProfileMenu(UserType.driver);
    final enabled = enabledById(menu);

    expect(menuIds(menu), [
      ProfileMenuId.personalData,
      ProfileMenuId.professionalData,
      ProfileMenuId.settings,
      ProfileMenuId.privacySecurity,
      ProfileMenuId.signOut,
    ]);
    expect(enabled[ProfileMenuId.personalData], isTrue);
    expect(enabled[ProfileMenuId.professionalData], isFalse);
    expect(enabled[ProfileMenuId.signOut], isTrue);
    expect(menu.map((section) => section.title).toList(), [
      ProfileMenuSectionTitle.account,
      ProfileMenuSectionTitle.preferences,
      null,
    ]);
  });

  test('assistant menu includes invite item', () {
    final menu = buildProfileMenu(UserType.assistant);
    final ids = menuIds(menu);

    expect(ids, [
      ProfileMenuId.personalData,
      ProfileMenuId.assistantInvite,
      ProfileMenuId.settings,
      ProfileMenuId.privacySecurity,
      ProfileMenuId.signOut,
    ]);
    expect(enabledById(menu)[ProfileMenuId.assistantInvite], isFalse);
  });

  test('admin and null type get the base menu only', () {
    for (final type in [UserType.admin, null]) {
      final menu = buildProfileMenu(type);
      expect(menuIds(menu), [
        ProfileMenuId.personalData,
        ProfileMenuId.settings,
        ProfileMenuId.privacySecurity,
        ProfileMenuId.signOut,
      ]);
    }
  });
}
