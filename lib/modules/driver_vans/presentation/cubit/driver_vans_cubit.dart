import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/media/photo_picker.dart';
import '../../../../core/media/photo_source.dart';
import '../../domain/usecases/change_van_photo.dart';
import '../../domain/usecases/list_my_vans.dart';
import '../../domain/usecases/register_van.dart';
import '../../domain/value_objects/van_photo_target.dart';
import '../../domain/value_objects/van_registration.dart';
import 'driver_vans_state.dart';

class DriverVansCubit extends Cubit<DriverVansState> {
  DriverVansCubit({
    required this.listMyVans,
    required this.registerVan,
    required this.changeVanPhoto,
    required this.photoPicker,
  }) : super(const DriverVansState());

  final ListMyVans listMyVans;
  final RegisterVan registerVan;
  final ChangeVanPhoto changeVanPhoto;
  final PhotoPicker photoPicker;

  Future<void> loadVans() async {
    emit(state.copyWith(status: DriverVansStatus.loading));
    await refreshVans();
  }

  Future<void> refreshVans() async {
    final result = await listMyVans();
    emit(
      result.fold(
        (_) => state.copyWith(status: DriverVansStatus.loadFailed),
        (vans) => state.copyWith(status: DriverVansStatus.loaded, vans: vans),
      ),
    );
  }

  void updateDraft(VanField field, String value) {
    final remainingErrors = Map.of(state.fieldErrors)..remove(field);
    emit(
      state.copyWith(
        draft: state.draft.copyWithField(field, value),
        fieldErrors: remainingErrors,
      ),
    );
  }

  Future<void> register() async {
    if (state.isRegistering) return;
    final errors = state.draft.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors));
      return;
    }

    emit(state.copyWith(isRegistering: true, fieldErrors: const {}));
    final result = await registerVan(state.draft);
    emit(
      result.fold(
        (failure) => state.copyWith(
          isRegistering: false,
          notice: VanRegistrationFailedNotice(failure),
        ),
        (van) => state.copyWith(
          isRegistering: false,
          vans: [...state.vans, van],
          draft: const VanRegistration(),
          notice: const VanRegisteredNotice(),
        ),
      ),
    );
  }

  Future<void> changePhoto(VanPhotoTarget target, PhotoSource source) async {
    if (state.isUploading(target)) return;
    final picked = await photoPicker.pick(source);
    final pickFailure = picked.errorOrNull;
    if (pickFailure != null) {
      emit(state.copyWith(notice: VanPhotoFailedNotice(pickFailure)));
      return;
    }
    final photo = picked.valueOrNull;
    if (photo == null) return;

    emit(state.copyWith(uploadingPhotos: {...state.uploadingPhotos, target}));
    final result = await changeVanPhoto(target, photo);
    final remaining = {...state.uploadingPhotos}..remove(target);
    final uploadFailure = result.errorOrNull;
    if (uploadFailure != null) {
      emit(
        state.copyWith(
          uploadingPhotos: remaining,
          notice: VanPhotoFailedNotice(uploadFailure),
        ),
      );
      return;
    }
    emit(state.copyWith(uploadingPhotos: remaining));
    await refreshVans();
  }

  void clearNotice() {
    if (state.notice == null) return;
    emit(state.copyWith());
  }
}
