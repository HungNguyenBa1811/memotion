import 'package:flutter/material.dart';
import '../../models/onboarding_data.dart';
import 'step1_builder.dart';
import 'step1_1_builder.dart';
import 'step2_builder.dart';
import 'step3_builder.dart';
import 'step4_builder.dart';
import 'step5_builder.dart';
import 'step6_builder.dart';
import 'step7_builder.dart';
import 'step8_builder.dart';
import 'step9_builder.dart';
import 'step10_builder.dart';
import 'step11_builder.dart';
import 'step12_builder.dart';
import 'step13_builder.dart';
import 'step14_builder.dart';
import 'step15_builder.dart';
import 'step16_builder.dart';
import 'step17_builder.dart';

/// Factory class để lấy step builder dựa trên bước hiện tại
///
/// Giúp quản lý việc tạo widget cho mỗi step một cách tập trung
/// Dễ mở rộng khi thêm step mới hoặc thay đổi logic
class StepBuilderFactory {
  static Widget buildStep(int step) {
    switch (step) {
      case 1:
        return const Step1Builder();
      case 2:
        return const Step1_1Builder(); // New: Username/Phone input
      case 3:
        return const Step2Builder();
      case 4:
        return const Step3Builder();
      case 5:
        return const Step4Builder();
      case 6:
        return const Step5Builder();
      case 7:
        return const Step6Builder();
      case 8:
        return const Step7Builder();
      case 9:
        return const Step8Builder();
      case 10:
        return const Step9Builder();
      case 11:
        return const Step10Builder();
      case 12:
        return const Step11Builder();
      case 13:
        return const Step12Builder();
      case 14:
        return const Step13Builder();
      case 15:
        return const Step14Builder();
      case 16:
        return const Step15Builder();
      case 17:
        return const Step16Builder();
      case 18:
        return const Step17Builder();
      default:
        throw ArgumentError('Invalid step: $step');
    }
  }

  /// Lấy tất cả các step builder (dùng cho testing hoặc preview)
  static List<Widget> buildAllSteps() {
    return List.generate(
      OnboardingConfig.totalSteps,
      (index) => buildStep(index + 1),
    );
  }
}
