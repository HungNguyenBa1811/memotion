import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memotion/features/health_connect/providers/yesterday_health_summary_provider.dart';
import 'package:memotion/shared/widgets/health_status_notice.dart';

void main() {
  group('HealthStatusNoticeContent', () {
    test('home reports completion in a single sentence', () {
      const summary = YesterdayHealthSummary(
        averageHeartRate: 72,
        totalTasks: 4,
        completedTasks: 4,
      );

      final content = HealthStatusNoticeContent.fromSummary(
        HealthSummaryArea.home,
        summary,
      );

      expect(content.message, 'Yesterday you completed all 4 care tasks (avg 72 bpm).');
      expect('.'.allMatches(content.message).length, 1);
    });

    test('nutrition reports logged meals and calories in one sentence', () {
      const summary = YesterdayHealthSummary(
        averageHeartRate: 75,
        totalTasks: 3,
        completedTasks: 2,
        recordedCalories: 1200,
      );

      final content = HealthStatusNoticeContent.fromSummary(
        HealthSummaryArea.nutrition,
        summary,
      );

      expect(
        content.message,
        'Yesterday you logged 2 of 3 planned meals (1200 kcal).',
      );
    });

    test('workout marks calories as estimated', () {
      const summary = YesterdayHealthSummary(
        averageHeartRate: 83,
        totalTasks: 2,
        completedTasks: 2,
        recordedCalories: 180,
        caloriesAreEstimated: true,
      );

      final content = HealthStatusNoticeContent.fromSummary(
        HealthSummaryArea.workout,
        summary,
      );

      expect(
        content.message,
        'Yesterday you completed all 2 planned exercises (~180 kcal).',
      );
      expect(content.message, isNot(contains('bpm')));
    });

    test('medication reports doses without heart-rate data', () {
      const summary = YesterdayHealthSummary(
        averageHeartRate: null,
        totalTasks: 3,
        completedTasks: 2,
      );

      final content = HealthStatusNoticeContent.fromSummary(
        HealthSummaryArea.medication,
        summary,
      );

      expect(content.message, 'Yesterday you took 2 of 3 scheduled doses.');
      expect(content.message, isNot(contains('bpm')));
    });
  });

  testWidgets('renders a single sentence without overflowing on phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          yesterdayHealthSummaryProvider.overrideWith((ref, area) async {
            return const YesterdayHealthSummary(
              averageHeartRate: 76,
              totalTasks: 4,
              completedTasks: 2,
              recordedCalories: 1150,
            );
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: HealthStatusNotice.nutrition(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Yesterday you logged 2 of 4 planned meals (1150 kcal).'),
      findsOneWidget,
    );
    expect(find.textContaining('Suggestion:'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
