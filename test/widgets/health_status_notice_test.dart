import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:memotion/features/health_connect/providers/yesterday_health_summary_provider.dart';
import 'package:memotion/shared/widgets/health_status_notice.dart';

void main() {
  group('HealthStatusNoticeContent', () {
    test('home reports heart rate and overall task completion', () {
      final content = HealthStatusNoticeContent.hardcoded(
        HealthSummaryArea.home,
      );

      expect(content.message, contains('average heart rate was 74 bpm'));
      expect(content.message, contains('all 8 tasks'));
      expect(content.message, contains('keep the same routine'));
    });

    test('nutrition reports meals, lateness, and a reminder', () {
      final content = HealthStatusNoticeContent.hardcoded(
        HealthSummaryArea.nutrition,
      );

      expect(content.message, contains('ate 3 meals'));
      expect(content.message, contains('lunch was 25 minutes late'));
      expect(content.message, contains('earlier reminder'));
      expect(content.message, isNot(contains('bpm')));
    });

    test('workout reports exercise heart rate, calories, and lateness', () {
      final content = HealthStatusNoticeContent.hardcoded(
        HealthSummaryArea.workout,
      );

      expect(content.message, contains('exercise heart rate averaged 112 bpm'));
      expect(content.message, contains('240 kcal'));
      expect(content.message, contains('both workouts'));
      expect(content.message, contains('prepare early'));
    });

    test('medication reports doses, lateness, and improvement advice', () {
      final content = HealthStatusNoticeContent.hardcoded(
        HealthSummaryArea.medication,
      );

      expect(content.message, contains('all 3 doses'));
      expect(content.message, contains('evening dose was 30 minutes late'));
      expect(content.message, startsWith('Needs improvement'));
      expect(content.message, contains('set an alarm'));
    });
  });

  testWidgets('renders the detailed notice without overflowing on phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: HealthStatusNotice.nutrition(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('you ate 3 meals'), findsOneWidget);
    expect(find.textContaining('Good overall yesterday'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
