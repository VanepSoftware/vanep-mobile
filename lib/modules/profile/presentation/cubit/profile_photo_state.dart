import 'package:equatable/equatable.dart';

import '../../../../core/media/photo_failure.dart';

enum ProfilePhotoStatus { idle, uploading, uploaded, failed }

class ProfilePhotoState extends Equatable {
  const ProfilePhotoState({
    this.status = ProfilePhotoStatus.idle,
    this.failure,
  });

  final ProfilePhotoStatus status;
  final PhotoFailure? failure;

  bool get isUploading => status == ProfilePhotoStatus.uploading;

  @override
  List<Object?> get props => [status, failure];
}
