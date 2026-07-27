import '../../../auth/domain/entities/user_profile.dart';
import '../value_objects/assistant_status.dart';
import '../value_objects/driver_approval_status.dart';
import 'pending_invite.dart';

sealed class ProfileSummary {
  String get token;

  String? get photoUrl;

  UserProfile? get user;
}

abstract class ClientProfileSummary extends ProfileSummary {
  double? get rating;

  bool? get active;
}

abstract class DriverProfileSummary extends ProfileSummary {
  double? get rating;

  String? get city;

  DriverApprovalStatus? get approvalStatus;

  bool? get available;

  bool? get active;
}

abstract class AssistantProfileSummary extends ProfileSummary {
  AssistantStatus? get status;

  PendingInvite? get pendingInvite;
}
