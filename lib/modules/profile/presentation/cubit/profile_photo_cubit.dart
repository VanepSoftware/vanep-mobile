import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/media/photo_picker.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/change_profile_photo.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_state.dart';

class ProfilePhotoCubit extends Cubit<ProfilePhotoState> {
  ProfilePhotoCubit({
    required this.photoPicker,
    required this.changeProfilePhoto,
  }) : super(const ProfilePhotoState());

  final PhotoPicker photoPicker;
  final ChangeProfilePhoto changeProfilePhoto;

  Future<void> changePhoto(ProfileSummary owner, PhotoSource source) async {
    if (state.isUploading) return;
    final picked = await photoPicker.pick(source);
    final photo = picked.valueOrNull;
    if (picked.isErr) {
      emit(
        ProfilePhotoState(
          status: ProfilePhotoStatus.failed,
          failure: picked.errorOrNull,
        ),
      );
      return;
    }
    if (photo == null) return;

    emit(const ProfilePhotoState(status: ProfilePhotoStatus.uploading));
    final result = await changeProfilePhoto(owner, photo);
    emit(
      result.fold(
        (failure) => ProfilePhotoState(
          status: ProfilePhotoStatus.failed,
          failure: failure,
        ),
        (_) => const ProfilePhotoState(status: ProfilePhotoStatus.uploaded),
      ),
    );
  }
}
