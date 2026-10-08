import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_state.dart';

import '../../../core/media/media_mocks.dart';
import '../profile_fixtures.dart';
import '../profile_mocks.dart';

void main() {
  late MockPhotoPicker picker;
  late MockChangeProfilePhoto changeProfilePhoto;

  setUpAll(() {
    registerFallbackValue(testDriverSummaryDto);
    registerFallbackValue(testPickedPhoto);
  });

  setUp(() {
    picker = MockPhotoPicker();
    changeProfilePhoto = MockChangeProfilePhoto();
  });

  ProfilePhotoCubit buildCubit() => ProfilePhotoCubit(
    photoPicker: picker,
    changeProfilePhoto: changeProfilePhoto,
  );

  void stubPick(Result<PhotoFailure, PickedPhoto?> result) {
    when(
      () => picker.pick(PhotoSource.gallery),
    ).thenAnswer((_) async => result);
  }

  blocTest<ProfilePhotoCubit, ProfilePhotoState>(
    'uploads the picked photo',
    setUp: () {
      stubPick(const Ok(testPickedPhoto));
      when(
        () => changeProfilePhoto(testDriverSummaryDto, testPickedPhoto),
      ).thenAnswer((_) async => const Ok<PhotoFailure, void>(null));
    },
    build: buildCubit,
    act: (cubit) =>
        cubit.changePhoto(testDriverSummaryDto, PhotoSource.gallery),
    expect: () => const [
      ProfilePhotoState(status: ProfilePhotoStatus.uploading),
      ProfilePhotoState(status: ProfilePhotoStatus.uploaded),
    ],
  );

  blocTest<ProfilePhotoCubit, ProfilePhotoState>(
    'does nothing when the user cancels the picker',
    setUp: () => stubPick(const Ok(null)),
    build: buildCubit,
    act: (cubit) =>
        cubit.changePhoto(testDriverSummaryDto, PhotoSource.gallery),
    expect: () => const <ProfilePhotoState>[],
    verify: (_) => verifyNever(() => changeProfilePhoto(any(), any())),
  );

  blocTest<ProfilePhotoCubit, ProfilePhotoState>(
    'reports a denied permission without uploading',
    setUp: () => stubPick(const Err(PhotoFailure.permissionDenied)),
    build: buildCubit,
    act: (cubit) =>
        cubit.changePhoto(testDriverSummaryDto, PhotoSource.gallery),
    expect: () => const [
      ProfilePhotoState(
        status: ProfilePhotoStatus.failed,
        failure: PhotoFailure.permissionDenied,
      ),
    ],
  );

  blocTest<ProfilePhotoCubit, ProfilePhotoState>(
    'reports an upload the server refused',
    setUp: () {
      stubPick(const Ok(testPickedPhoto));
      when(
        () => changeProfilePhoto(testDriverSummaryDto, testPickedPhoto),
      ).thenAnswer(
        (_) async => const Err<PhotoFailure, void>(PhotoFailure.tooLarge),
      );
    },
    build: buildCubit,
    act: (cubit) =>
        cubit.changePhoto(testDriverSummaryDto, PhotoSource.gallery),
    expect: () => const [
      ProfilePhotoState(status: ProfilePhotoStatus.uploading),
      ProfilePhotoState(
        status: ProfilePhotoStatus.failed,
        failure: PhotoFailure.tooLarge,
      ),
    ],
  );
}
