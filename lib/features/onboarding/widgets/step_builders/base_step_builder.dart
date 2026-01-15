import 'package:flutter/material.dart';
import '../../models/onboarding_data.dart';

/// Base class cho các step builder
///
/// Mỗi step builder là một Widget dừng lại để tạo content cho một bước onboarding
/// Cấp subclass để dễ mở rộng và maintain
abstract class BaseStepBuilder extends StatelessWidget {
  final OnboardingStepConfig config;

  const BaseStepBuilder({super.key, required this.config});

  /// Build phần chính của step (dưới title/subtitle)
  Widget buildContent(BuildContext context);

  /// Build header (title + subtitle)
  Widget buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: config.titleAlignment.crossAxisAlignment,
      children: [
        if (config.title.isNotEmpty)
          Text(
            config.title,
            textAlign: config.titleAlignment.textAlign,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
        if (config.subtitle != null && config.subtitle!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            config.subtitle!,
            textAlign: config.titleAlignment.textAlign,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  /// Build image nếu có
  Widget buildImage(BuildContext context) {
    if (config.imagePath == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        config.imagePath!,
        width: 240,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        buildHeader(context),
        const SizedBox(height: 24),
        buildContent(context),
      ],
    );
  }
}
