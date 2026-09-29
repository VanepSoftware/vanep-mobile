import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/media/photo_picker.dart';
import '../../../../core/media/photo_source.dart';
import '../../domain/entities/profile_summary.dart';
import '../../domain/usecases/change_profile_photo.dart';
import 'profile_photo_state.dart';

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
