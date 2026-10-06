import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_target.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';

enum DriverVansStatus { loading, loaded, loadFailed }

sealed class DriverVansNotice extends Equatable {
  const DriverVansNotice();

  @override
  List<Object?> get props => [];
}

class VanRegisteredNotice extends DriverVansNotice {
  const VanRegisteredNotice();
}

class VanRegistrationFailedNotice extends DriverVansNotice {
  const VanRegistrationFailedNotice(this.failure);

  final DriverVanFailure failure;

  @override
  List<Object?> get props => [failure];
}

class VanPhotoFailedNotice extends DriverVansNotice {
  const VanPhotoFailedNotice(this.failure);

  final PhotoFailure failure;

  @override
  List<Object?> get props => [failure];
}

class DriverVansState extends Equatable {
  const DriverVansState({
    this.status = DriverVansStatus.loading,
    this.vans = const [],
    this.draft = const VanRegistration(),
    this.fieldErrors = const {},
    this.isRegistering = false,
    this.uploadingPhotos = const {},
    this.notice,
  });

  final DriverVansStatus status;
  final List<DriverVan> vans;
  final VanRegistration draft;
  final Map<VanField, VanFieldError> fieldErrors;
  final bool isRegistering;
  final Set<VanPhotoTarget> uploadingPhotos;
  final DriverVansNotice? notice;

  bool isUploading(VanPhotoTarget target) => uploadingPhotos.contains(target);

  DriverVansState copyWith({
    DriverVansStatus? status,
    List<DriverVan>? vans,
    VanRegistration? draft,
    Map<VanField, VanFieldError>? fieldErrors,
    bool? isRegistering,
    Set<VanPhotoTarget>? uploadingPhotos,
    DriverVansNotice? notice,
  }) {
    return DriverVansState(
      status: status ?? this.status,
      vans: vans ?? this.vans,
      draft: draft ?? this.draft,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isRegistering: isRegistering ?? this.isRegistering,
      uploadingPhotos: uploadingPhotos ?? this.uploadingPhotos,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    vans,
    draft,
    fieldErrors,
    isRegistering,
    uploadingPhotos,
    notice,
  ];
}
