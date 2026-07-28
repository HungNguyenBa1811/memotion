import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/workout/models/pose_detection_model.dart';
import 'package:memotion/features/workout/screens/workout_training_complete_screen.dart';

void main() {
  testWidgets('shows final scores and translates Vietnamese backend grades', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const results = PoseSessionResults(
      sessionId: 'pose-1',
      exerciseName: 'Arm raise',
      durationSeconds: 75,
      totalScore: 87.5,
      romScore: 90,
      stabilityScore: 84,
      flowScore: 88.5,
      grade: 'XUAT SAC',
      gradeColor: 'green',
      totalReps: 8,
      fatigueLevel: 'MILD',
      calibratedJoints: [],
      repScores: [],
      recommendations: ['Keep a steady pace'],
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorkoutTrainingCompleteScreen(
            workoutId: 'workout-1',
            results: results,
          ),
        ),
      ),
    );

    expect(find.text('Arm raise'), findsOneWidget);
    expect(find.text('87.5'), findsOneWidget);
    expect(find.text('Excellent'), findsOneWidget);
    expect(find.text('XUAT SAC'), findsNothing);
    expect(find.text('01:15'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('84%'), findsOneWidget);
    expect(find.text('88.5%'), findsOneWidget);
    expect(find.text('Keep a steady pace'), findsOneWidget);
    expect(find.text('92%'), findsNothing);
    expect(find.text('45'), findsNothing);
  });
}
