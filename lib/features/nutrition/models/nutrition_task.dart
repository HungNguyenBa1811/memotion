import 'package:flutter/material.dart';

/// Nutrition task model for UI consumption
class NutritionTask {
  final String id;
  final String name;
  final String? description;
  final int? calories;
  final String mealType;
  final String time;
  final DateTime scheduledDate;
  final NutritionStatus status;
  final String? imagePath;
  final String? remainingTime;

  const NutritionTask({
    required this.id,
    required this.name,
    this.description,
    this.calories,
    required this.mealType,
    required this.time,
    required this.scheduledDate,
    this.status = NutritionStatus.pending,
    this.imagePath,
    this.remainingTime,
  });

  NutritionTask copyWith({
    String? id,
    String? name,
    String? description,
    int? calories,
    String? mealType,
    String? time,
    DateTime? scheduledDate,
    NutritionStatus? status,
    String? imagePath,
    String? remainingTime,
  }) {
    return NutritionTask(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      time: time ?? this.time,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  /// Get icon based on meal type
  IconData get mealIcon {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  /// Get color based on meal type
  Color get mealColor {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFF9800);
      case 'lunch':
        return const Color(0xFF4CAF50);
      case 'dinner':
        return const Color(0xFF2196F3);
      case 'snack':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF00695C);
    }
  }
}

/// Status of a nutrition task
enum NutritionStatus {
  pending,
  completed,
  missed;

  String get displayText {
    switch (this) {
      case NutritionStatus.pending:
        return 'Pending';
      case NutritionStatus.completed:
        return 'Completed';
      case NutritionStatus.missed:
        return 'Missed';
    }
  }

  static NutritionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return NutritionStatus.completed;
      case 'missed':
        return NutritionStatus.missed;
      default:
        return NutritionStatus.pending;
    }
  }
}

/// Filter options for nutrition tasks
enum NutritionFilter {
  all,
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayText {
    switch (this) {
      case NutritionFilter.all:
        return 'All';
      case NutritionFilter.breakfast:
        return 'Breakfast';
      case NutritionFilter.lunch:
        return 'Lunch';
      case NutritionFilter.dinner:
        return 'Dinner';
      case NutritionFilter.snack:
        return 'Snack';
    }
  }
}
