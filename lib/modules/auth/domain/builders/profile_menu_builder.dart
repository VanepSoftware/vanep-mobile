import '../value_objects/profile_menu_id.dart';
import '../value_objects/user_type.dart';

enum ProfileMenuSectionTitle {
  account,
  services,
  preferences,
}

class ProfileMenuEntry {
  const ProfileMenuEntry({required this.id, required this.enabled});

  final ProfileMenuId id;
  final bool enabled;
}

class ProfileMenuSection {
  const ProfileMenuSection(this.entries, {this.title});

  final ProfileMenuSectionTitle? title;
  final List<ProfileMenuEntry> entries;
}

List<ProfileMenuSection> buildProfileMenu(UserType? type) {
  return switch (type) {
    UserType.client => _clientMenu,
    UserType.driver => _driverMenu,
    UserType.assistant => _assistantMenu,
    UserType.admin || null => _baseMenu,
  };
}

const _enabledPersonalData = ProfileMenuEntry(
  id: ProfileMenuId.personalData,
  enabled: true,
);

const _enabledSignOut = ProfileMenuEntry(
  id: ProfileMenuId.signOut,
  enabled: true,
);

const _settingsSection = ProfileMenuSection(
  [
    ProfileMenuEntry(id: ProfileMenuId.settings, enabled: false),
    ProfileMenuEntry(id: ProfileMenuId.privacySecurity, enabled: false),
  ],
  title: ProfileMenuSectionTitle.preferences,
);

const _signOutSection = ProfileMenuSection([_enabledSignOut]);

const _baseMenu = [
  ProfileMenuSection(
    [_enabledPersonalData],
    title: ProfileMenuSectionTitle.account,
  ),
  _settingsSection,
  _signOutSection,
];

const _clientMenu = [
  ProfileMenuSection(
    [
      _enabledPersonalData,
      ProfileMenuEntry(id: ProfileMenuId.addresses, enabled: false),
      ProfileMenuEntry(id: ProfileMenuId.paymentMethods, enabled: false),
    ],
    title: ProfileMenuSectionTitle.account,
  ),
  ProfileMenuSection(
    [
      ProfileMenuEntry(id: ProfileMenuId.dependents, enabled: false),
      ProfileMenuEntry(id: ProfileMenuId.vans, enabled: false),
      ProfileMenuEntry(id: ProfileMenuId.contracts, enabled: false),
    ],
    title: ProfileMenuSectionTitle.services,
  ),
  _settingsSection,
  _signOutSection,
];

const _driverMenu = [
  ProfileMenuSection(
    [_enabledPersonalData],
    title: ProfileMenuSectionTitle.account,
  ),
  ProfileMenuSection(
    [
      ProfileMenuEntry(id: ProfileMenuId.vans, enabled: false),
      ProfileMenuEntry(id: ProfileMenuId.contracts, enabled: false),
      ProfileMenuEntry(id: ProfileMenuId.professionalData, enabled: false),
    ],
    title: ProfileMenuSectionTitle.services,
  ),
  _settingsSection,
  _signOutSection,
];

const _assistantMenu = [
  ProfileMenuSection(
    [_enabledPersonalData],
    title: ProfileMenuSectionTitle.account,
  ),
  ProfileMenuSection(
    [
      ProfileMenuEntry(id: ProfileMenuId.assistantInvite, enabled: false),
    ],
    title: ProfileMenuSectionTitle.services,
  ),
  _settingsSection,
  _signOutSection,
];
