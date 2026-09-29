import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';

Widget skeletonHarness(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

const stubPlaceholderHeight = 40.0;

class StubPlaceholder extends StatelessWidget {
  const StubPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: stubPlaceholderHeight,
      child: Bone.text(words: 2),
    );
  }
}

Widget buildStubPlaceholder(BuildContext context) {
  return const StubPlaceholder();
}

Finder findSkeletonizer({required bool enabled}) {
  return find.byWidgetPredicate(
    (widget) => widget is Skeletonizer && widget.enabled == enabled,
  );
}

void main() {
  testWidgets('shades its child while enabled', (tester) async {
    await tester.pumpWidget(
      skeletonHarness(const VanepSkeleton(child: Bone.text(words: 2))),
    );

    expect(findSkeletonizer(enabled: true), findsOneWidget);
  });

  testWidgets('leaves the child unshaded once disabled', (tester) async {
    await tester.pumpWidget(
      skeletonHarness(
        const VanepSkeleton(enabled: false, child: Text('Marina Alves')),
      ),
    );

    expect(findSkeletonizer(enabled: false), findsOneWidget);
    expect(find.text('Marina Alves'), findsOneWidget);
  });

  testWidgets('repeats the placeholder once per requested item', (
    tester,
  ) async {
    await tester.pumpWidget(
      skeletonHarness(
        const VanepSkeletonList(
          count: 4,
          buildPlaceholder: buildStubPlaceholder,
        ),
      ),
    );

    expect(find.byType(StubPlaceholder), findsNWidgets(4));
  });

  testWidgets('spaces every placeholder except the last', (tester) async {
    const spacing = 12.0;
    await tester.pumpWidget(
      skeletonHarness(
        const VanepSkeletonList(
          count: 3,
          spacing: spacing,
          buildPlaceholder: buildStubPlaceholder,
        ),
      ),
    );

    final placeholders = find.byType(StubPlaceholder);
    final firstTop = tester.getTopLeft(placeholders.at(0)).dy;
    final secondTop = tester.getTopLeft(placeholders.at(1)).dy;
    final thirdTop = tester.getTopLeft(placeholders.at(2)).dy;

    expect(secondTop - firstTop, stubPlaceholderHeight + spacing);
    expect(thirdTop - secondTop, stubPlaceholderHeight + spacing);
    expect(
      tester.getSize(find.byType(VanepSkeletonList)).height,
      stubPlaceholderHeight * 3 + spacing * 2,
    );
  });
}
