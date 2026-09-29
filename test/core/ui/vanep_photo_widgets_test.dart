import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_cover_background.dart';
import 'package:vanep_mobile/core/ui/vanep_editable_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_edit_badge.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_slot.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_source_sheet.dart';

import '../media/media_mocks.dart';

Widget harness(Widget child, {ApiImageLoader? loader}) {
  return RepositoryProvider<ApiImageLoader>.value(
    value: loader ?? MockApiImageLoader(),
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('a plain avatar offers no edit badge', (tester) async {
    await tester.pumpWidget(harness(const VanepAvatar(size: 72)));

    expect(find.byType(VanepPhotoEditBadge), findsNothing);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('an editable avatar shows the badge and reacts to taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(
        VanepEditableAvatar(semanticLabel: 'Trocar', onTap: () => taps++),
      ),
    );

    await tester.tap(find.byType(VanepEditableAvatar));

    expect(find.byType(VanepPhotoEditBadge), findsOneWidget);
    expect(taps, 1);
  });

  testWidgets('an uploading avatar shows progress and ignores taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(
        VanepEditableAvatar(
          semanticLabel: 'Trocar',
          isUploading: true,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byType(VanepEditableAvatar));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(VanepPhotoEditBadge), findsNothing);
    expect(taps, 0);
  });

  testWidgets('a read-only photo slot shows the placeholder and label', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const SizedBox(
          width: 160,
          child: VanepPhotoSlot(
            label: 'Frente',
            placeholderIcon: Icons.airport_shuttle_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Frente'), findsOneWidget);
    expect(find.byIcon(Icons.airport_shuttle_outlined), findsOneWidget);
    expect(find.byType(VanepPhotoEditBadge), findsNothing);
  });

  testWidgets('an editable photo slot loads its photo and reacts to taps', (
    tester,
  ) async {
    final loader = MockApiImageLoader();
    when(() => loader.loadBytes(any())).thenThrow(StateError('offline'));
    var taps = 0;
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 160,
          child: VanepPhotoSlot(
            photoUrl: '/api/vehicles/van-1/photo-front?v=1',
            onTap: () => taps++,
          ),
        ),
        loader: loader,
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(VanepPhotoSlot));

    verify(
      () => loader.loadBytes('/api/vehicles/van-1/photo-front?v=1'),
    ).called(1);
    expect(find.byType(VanepPhotoEditBadge), findsOneWidget);
    expect(taps, 1);
  });

  testWidgets('the source sheet returns what the user picks', (tester) async {
    PhotoSource? picked;
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showVanepPhotoSourceSheet(
              context,
              galleryLabel: 'Galeria',
              cameraLabel: 'Câmera',
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Câmera'));
    await tester.pumpAndSettle();

    expect(picked, PhotoSource.camera);
  });

  testWidgets('a cover without photo keeps the plain background', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(const VanepCoverBackground(child: Text('Carlos'))),
    );

    expect(find.text('Carlos'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(VanepCoverScrim), findsNothing);
  });

  testWidgets('a cover with photo loads it behind a scrim', (tester) async {
    final loader = MockApiImageLoader();
    when(() => loader.loadBytes(any())).thenThrow(StateError('offline'));

    await tester.pumpWidget(
      harness(
        const VanepCoverBackground(
          photoUrl: '/api/vehicles/van-9/photo-front?v=1',
          child: Text('Carlos'),
        ),
        loader: loader,
      ),
    );
    await tester.pump();

    expect(find.text('Carlos'), findsOneWidget);
    expect(find.byType(VanepCoverScrim), findsOneWidget);
    verify(
      () => loader.loadBytes('/api/vehicles/van-9/photo-front?v=1'),
    ).called(1);
  });
}
