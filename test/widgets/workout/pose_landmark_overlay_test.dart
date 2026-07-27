import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/workout/data/pose_overlay_controller.dart';
import 'package:memotion/features/workout/models/pose_landmark_model.dart';
import 'package:memotion/features/workout/widgets/pose_landmark_overlay.dart';

void main() {
  testWidgets('overlay updates repaint without rebuilding its parent', (
    tester,
  ) async {
    final controller = PoseOverlayController(startFreshnessTimer: false);
    addTearDown(controller.dispose);
    var parentBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: _BuildCounter(
          onBuild: () => parentBuilds++,
          child: SizedBox(
            width: 320,
            height: 480,
            child: PoseLandmarkOverlay(controller: controller),
          ),
        ),
      ),
    );
    expect(parentBuilds, 1);
    expect(
      find.descendant(
        of: find.byType(PoseLandmarkOverlay),
        matching: find.byWidgetPredicate(
          (widget) => widget is IgnorePointer && widget.ignoring,
        ),
      ),
      findsOneWidget,
    );

    for (var frame = 0; frame < 100; frame++) {
      controller.ingest([
        NormalizedPoseLandmark(
          index: 11,
          x: frame / 100,
          y: 0.5,
          visibility: 0.9,
        ),
      ], connections: const []);
    }
    await tester.pump();

    expect(parentBuilds, 1);
  });
}

class _BuildCounter extends StatelessWidget {
  const _BuildCounter({required this.onBuild, required this.child});

  final VoidCallback onBuild;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return child;
  }
}
