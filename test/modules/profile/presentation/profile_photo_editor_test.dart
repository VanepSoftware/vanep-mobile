import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/ui/vanep_editable_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_state.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/widgets/profile_photo_editor.dart';

import '../../../core/media/media_mocks.dart';
import '../profile_fixtures.dart';
import '../profile_mocks.dart';

Widget harness(ProfileSummaryCubit summary, ProfilePhotoCubit photo) {
  final loader = MockApiImageLoader();
  when(() => loader.loadBytes(any())).thenThrow(StateError('offline'));
  return RepositoryProvider<ApiImageLoader>.value(
    value: loader,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ProfileSummaryCubit>.value(value: summary),
            BlocProvider<ProfilePhotoCubit>.value(value: photo),
          ],
          child: const ProfilePhotoEditor(userType: UserType.driver),
        ),
      ),
    ),
  );
}

void main() {
  late MockProfileSummaryCubit summary;
  late MockProfilePhotoCubit photo;

  setUpAll(() {
    registerFallbackValue(testDriverSummaryDto);
    registerFallbackValue(PhotoSource.gallery);
    registerFallbackValue(UserType.driver);
  });

  setUp(() {
    summary = MockProfileSummaryCubit();
    photo = MockProfilePhotoCubit();
    whenListen(
      summary,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(
        status: ProfileSummaryStatus.loaded,
        summary: testDriverSummaryDto,
      ),
    );
    when(() => photo.changePhoto(any(), any())).thenAnswer((_) async {});
    when(() => summary.refresh(any())).thenAnswer((_) async {});
  });

  testWidgets('choosing the gallery sends the photo for this profile', (
    tester,
  ) async {
    whenListen(
      photo,
      const Stream<ProfilePhotoState>.empty(),
      initialState: const ProfilePhotoState(),
    );

    await tester.pumpWidget(harness(summary, photo));
    await tester.tap(find.text('Trocar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();

    verify(
      () => photo.changePhoto(testDriverSummaryDto, PhotoSource.gallery),
    ).called(1);
  });

  testWidgets('a new photo refreshes the profile everywhere', (tester) async {
    whenListen(
      photo,
      Stream.fromIterable(const [
        ProfilePhotoState(status: ProfilePhotoStatus.uploading),
        ProfilePhotoState(status: ProfilePhotoStatus.uploaded),
      ]),
      initialState: const ProfilePhotoState(),
    );

    await tester.pumpWidget(harness(summary, photo));
    await tester.pump();

    expect(find.text('Foto atualizada.'), findsOneWidget);
    verify(() => summary.refresh(UserType.driver)).called(1);
  });

  testWidgets('a failed upload explains why', (tester) async {
    whenListen(
      photo,
      Stream.fromIterable(const [
        ProfilePhotoState(
          status: ProfilePhotoStatus.failed,
          failure: PhotoFailure.unsupportedType,
        ),
      ]),
      initialState: const ProfilePhotoState(),
    );

    await tester.pumpWidget(harness(summary, photo));
    await tester.pump();

    expect(
      find.text('Formato não suportado. Use JPG, PNG ou WEBP.'),
      findsOneWidget,
    );
    verifyNever(() => summary.refresh(any()));
  });

  testWidgets('shows progress on the avatar while uploading', (tester) async {
    whenListen(
      photo,
      const Stream<ProfilePhotoState>.empty(),
      initialState: const ProfilePhotoState(
        status: ProfilePhotoStatus.uploading,
      ),
    );

    await tester.pumpWidget(harness(summary, photo));

    final avatar = tester.widget<VanepEditableAvatar>(
      find.byType(VanepEditableAvatar),
    );
    expect(avatar.isUploading, isTrue);
  });
}
