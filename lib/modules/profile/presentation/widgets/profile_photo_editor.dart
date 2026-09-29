import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/photo_failure_label.dart';
import '../../../../core/ui/vanep_editable_avatar.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_photo_source_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/value_objects/user_type.dart';
import '../../domain/entities/profile_summary.dart';
import '../cubit/profile_photo_cubit.dart';
import '../cubit/profile_photo_state.dart';
import '../cubit/profile_summary_cubit.dart';

class ProfilePhotoEditor extends StatelessWidget {
  const ProfilePhotoEditor({required this.userType, super.key});

  final UserType userType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfilePhotoCubit, ProfilePhotoState>(
      listener: (context, photoState) =>
          presentProfilePhotoOutcome(context, l10n, photoState, userType),
      builder: (context, photoState) {
        final summary = context.watch<ProfileSummaryCubit>().state.summary;
        final changePhoto = summary == null
            ? null
            : () => pickAndChangeProfilePhoto(context, l10n, summary);

        return Center(
          child: Column(
            children: [
              VanepEditableAvatar(
                semanticLabel: l10n.profilePhotoChange,
                photoUrl: summary?.photoUrl,
                isUploading: photoState.isUploading,
                onTap: changePhoto,
              ),
              TextButton(
                onPressed: photoState.isUploading ? null : changePhoto,
                child: Text(l10n.profilePhotoChange),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> pickAndChangeProfilePhoto(
  BuildContext context,
  AppLocalizations l10n,
  ProfileSummary owner,
) async {
  final cubit = context.read<ProfilePhotoCubit>();
  final source = await showVanepPhotoSourceSheet(
    context,
    galleryLabel: l10n.photoSourceGallery,
    cameraLabel: l10n.photoSourceCamera,
  );
  if (source == null) return;
  await cubit.changePhoto(owner, source);
}

void presentProfilePhotoOutcome(
  BuildContext context,
  AppLocalizations l10n,
  ProfilePhotoState photoState,
  UserType userType,
) {
  final failure = photoState.failure;
  switch (photoState.status) {
    case ProfilePhotoStatus.uploaded:
      VanepFeedback.showInfo(context, l10n.profilePhotoUpdated);
      context.read<ProfileSummaryCubit>().refresh(userType);
    case ProfilePhotoStatus.failed when failure != null:
      VanepFeedback.showError(context, photoFailureLabel(l10n, failure));
    case ProfilePhotoStatus.idle ||
        ProfilePhotoStatus.uploading ||
        ProfilePhotoStatus.failed:
      break;
  }
}
