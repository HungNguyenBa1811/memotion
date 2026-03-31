import 'package:flutter/material.dart';

class AudioWaveform extends StatelessWidget {
  const AudioWaveform({
    super.key,
    required this.samples,
    this.maxHeight = 84,
    this.minHeight = 10,
    this.barCount = 36,
    this.barColor = const Color(0xFF4DB6AC),
  });

  final List<double> samples;
  final double maxHeight;
  final double minHeight;
  final int barCount;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeSamples(samples, barCount);

    return SizedBox(
      height: maxHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = (constraints.maxWidth / (barCount * 1.9)).clamp(
            3.0,
            8.0,
          );

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(normalized.length, (index) {
              final value = normalized[index].clamp(0.0, 1.0);
              final targetHeight =
                  minHeight + ((maxHeight - minHeight) * value);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                width: barWidth,
                height: targetHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [barColor.withValues(alpha: 0.55), barColor],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  List<double> _normalizeSamples(List<double> input, int size) {
    if (input.isEmpty) {
      return List<double>.filled(size, 0.08);
    }

    if (input.length == size) {
      return input;
    }

    if (input.length > size) {
      return input.sublist(input.length - size);
    }

    final missing = size - input.length;
    return [...List<double>.filled(missing, 0.08), ...input];
  }
}
