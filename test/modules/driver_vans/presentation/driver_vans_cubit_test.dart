import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_state.dart';

import '../../../core/media/media_mocks.dart';
import '../driver_vans_fixtures.dart';
import '../driver_vans_mocks.dart';

void main() {
  late MockListMyVans listMyVans;
  late MockRegisterVan registerVan;
  late MockChangeVanPhoto changeVanPhoto;
  late MockPhotoPicker picker;

  setUpAll(() {
    registerFallbackValue(validRegistration);
    registerFallbackValue(frontOfTestVan);
    registerFallbackValue(testPickedPhoto);
  });

  setUp(() {
    listMyVans = MockListMyVans();
    registerVan = MockRegisterVan();
    changeVanPhoto = MockChangeVanPhoto();
    picker = MockPhotoPicker();
  });

  DriverVansCubit buildCubit() => DriverVansCubit(
    listMyVans: listMyVans,
    registerVan: registerVan,
    changeVanPhoto: changeVanPhoto,
    photoPicker: picker,
  );

  void stubVans(List<DriverVan> vans) {
    when(
      () => listMyVans(),
    ).thenAnswer((_) async => Ok<DriverVanFailure, List<DriverVan>>(vans));
  }

  const loadedWithVan = DriverVansState(
    status: DriverVansStatus.loaded,
    vans: [testVan],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'loads the driver vans',
    setUp: () => stubVans(const [testVan]),
    build: buildCubit,
    act: (cubit) => cubit.loadVans(),
    expect: () => const [DriverVansState(), loadedWithVan],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'a failed load can be retried',
    setUp: () => when(() => listMyVans()).thenAnswer(
      (_) async => const Err<DriverVanFailure, List<DriverVan>>(
        DriverVanFailure.network,
      ),
    ),
    build: buildCubit,
    act: (cubit) => cubit.loadVans(),
    expect: () => const [
      DriverVansState(),
      DriverVansState(status: DriverVansStatus.loadFailed),
    ],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'an incomplete van is not sent',
    build: buildCubit,
    seed: () => const DriverVansState(status: DriverVansStatus.loaded),
    act: (cubit) => cubit.register(),
    expect: () => [
      DriverVansState(
        status: DriverVansStatus.loaded,
        fieldErrors: {
          for (final field in VanField.values) field: VanFieldError.required,
        },
      ),
    ],
    verify: (_) => verifyNever(() => registerVan(any())),
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'typing in a field clears only its error',
    build: buildCubit,
    seed: () => const DriverVansState(
      status: DriverVansStatus.loaded,
      fieldErrors: {
        VanField.plate: VanFieldError.invalid,
        VanField.color: VanFieldError.required,
      },
    ),
    act: (cubit) => cubit.updateDraft(VanField.plate, 'ABC1D23'),
    expect: () => const [
      DriverVansState(
        status: DriverVansStatus.loaded,
        draft: VanRegistration(plate: 'ABC1D23'),
        fieldErrors: {VanField.color: VanFieldError.required},
      ),
    ],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'a registered van replaces the form',
    setUp: () => when(
      () => registerVan(validRegistration),
    ).thenAnswer((_) async => const Ok<DriverVanFailure, DriverVan>(testVan)),
    build: buildCubit,
    seed: () => const DriverVansState(
      status: DriverVansStatus.loaded,
      draft: validRegistration,
    ),
    act: (cubit) => cubit.register(),
    expect: () => const [
      DriverVansState(
        status: DriverVansStatus.loaded,
        draft: validRegistration,
        isRegistering: true,
      ),
      DriverVansState(
        status: DriverVansStatus.loaded,
        vans: [testVan],
        notice: VanRegisteredNotice(),
      ),
    ],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'a refused van keeps the draft and says why',
    setUp: () => when(() => registerVan(validRegistration)).thenAnswer(
      (_) async => const Err<DriverVanFailure, DriverVan>(
        DriverVanFailure.duplicatePlate,
      ),
    ),
    build: buildCubit,
    seed: () => const DriverVansState(
      status: DriverVansStatus.loaded,
      draft: validRegistration,
    ),
    act: (cubit) => cubit.register(),
    skip: 1,
    expect: () => const [
      DriverVansState(
        status: DriverVansStatus.loaded,
        draft: validRegistration,
        notice: VanRegistrationFailedNotice(DriverVanFailure.duplicatePlate),
      ),
    ],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'a new van photo is uploaded and the van reloaded with its new url',
    setUp: () {
      when(
        () => picker.pick(PhotoSource.camera),
      ).thenAnswer((_) async => const Ok(testPickedPhoto));
      when(
        () => changeVanPhoto(frontOfTestVan, testPickedPhoto),
      ).thenAnswer((_) async => const Ok<PhotoFailure, void>(null));
      stubVans([
        testVan.copyWith(photoFrontUrl: '/api/vehicles/van-1/photo-front?v=2'),
      ]);
    },
    build: buildCubit,
    seed: () => loadedWithVan,
    act: (cubit) => cubit.changePhoto(frontOfTestVan, PhotoSource.camera),
    expect: () => [
      DriverVansState(
        status: DriverVansStatus.loaded,
        vans: const [testVan],
        uploadingPhotos: {frontOfTestVan},
      ),
      loadedWithVan,
      DriverVansState(
        status: DriverVansStatus.loaded,
        vans: [
          testVan.copyWith(
            photoFrontUrl: '/api/vehicles/van-1/photo-front?v=2',
          ),
        ],
      ),
    ],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'a refused van photo is reported and nothing is reloaded',
    setUp: () {
      when(
        () => picker.pick(PhotoSource.gallery),
      ).thenAnswer((_) async => const Ok(testPickedPhoto));
      when(() => changeVanPhoto(frontOfTestVan, testPickedPhoto)).thenAnswer(
        (_) async => const Err<PhotoFailure, void>(PhotoFailure.tooLarge),
      );
    },
    build: buildCubit,
    seed: () => loadedWithVan,
    act: (cubit) => cubit.changePhoto(frontOfTestVan, PhotoSource.gallery),
    skip: 1,
    expect: () => const [
      DriverVansState(
        status: DriverVansStatus.loaded,
        vans: [testVan],
        notice: VanPhotoFailedNotice(PhotoFailure.tooLarge),
      ),
    ],
    verify: (_) => verifyNever(() => listMyVans()),
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'cancelling the picker changes nothing',
    setUp: () => when(
      () => picker.pick(PhotoSource.gallery),
    ).thenAnswer((_) async => const Ok(null)),
    build: buildCubit,
    seed: () => loadedWithVan,
    act: (cubit) => cubit.changePhoto(frontOfTestVan, PhotoSource.gallery),
    expect: () => const <DriverVansState>[],
  );

  blocTest<DriverVansCubit, DriverVansState>(
    'a notice is shown once',
    build: buildCubit,
    seed: () => const DriverVansState(
      status: DriverVansStatus.loaded,
      notice: VanRegisteredNotice(),
    ),
    act: (cubit) => cubit.clearNotice(),
    expect: () => const [DriverVansState(status: DriverVansStatus.loaded)],
  );
}
