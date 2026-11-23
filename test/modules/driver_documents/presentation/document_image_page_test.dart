import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_image_page.dart';

final page = MemoryImage(Uint8List(0));

void main() {
  Future<void> pumpViewer(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: DocumentImagePage(
          title: 'CNH',
          images: [page, page],
          initialPage: 1,
        ),
      ),
    );
  }

  ScrollPhysics? pagingOf(WidgetTester tester) =>
      tester.widget<PageView>(find.byType(PageView)).physics;

  testWidgets('opens on the chosen page', (tester) async {
    await pumpViewer(tester);

    expect(
      tester.widget<PageView>(find.byType(PageView)).controller?.initialPage,
      1,
    );
  });

  testWidgets('a zoomed page pans instead of turning the page', (tester) async {
    await pumpViewer(tester);
    expect(pagingOf(tester), isNull);

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    viewer.transformationController!.value = Matrix4.diagonal3Values(2, 2, 1);
    viewer.onInteractionEnd!(ScaleEndDetails());
    await tester.pump();
    expect(pagingOf(tester), isA<NeverScrollableScrollPhysics>());

    viewer.transformationController!.value = Matrix4.identity();
    viewer.onInteractionEnd!(ScaleEndDetails());
    await tester.pump();
    expect(pagingOf(tester), isNull);
  });
}
