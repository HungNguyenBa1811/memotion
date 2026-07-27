import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/onboarding_data.dart';

class Step5Builder extends ConsumerWidget {
  const Step5Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const config = OnboardingStep5Config();
    final painLevel = ref.watch(onboardingProvider).painLevel;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(context, config),
          const SizedBox(height: 24),
          _buildPainLevelInput(context, ref, painLevel),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingStep5Config config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        config.title,
        textAlign: config.titleAlignment.textAlign,
        style: GoogleFonts.lexend(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF221F1F),
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildPainLevelInput(
    BuildContext context,
    WidgetRef ref,
    int? painLevel,
  ) {
    return GestureDetector(
      onTap: () async {
        // Đóng bàn phím trước khi mở picker
        FocusScope.of(context).unfocus();
        final result = await showDialog<int>(
          context: context,
          builder: (context) => _PainLevelPicker(initialLevel: painLevel ?? 0),
        );
        if (result != null) {
          ref.read(onboardingProvider.notifier).setPainLevel(result);
        }
      },
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFBEBAB3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              painLevel != null
                  ? painLevel.toString()
                  : 'Select a number from 0 to 10',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: painLevel != null ? null : const Color(0xFF9E9A94),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}

/// Dialog picker cho mức độ đau (0-10), cùng kiểu với picker năm sinh
class _PainLevelPicker extends StatefulWidget {
  final int initialLevel;

  const _PainLevelPicker({required this.initialLevel});

  @override
  State<_PainLevelPicker> createState() => _PainLevelPickerState();
}

class _PainLevelPickerState extends State<_PainLevelPicker> {
  static const int _minLevel = 0;
  static const int _maxLevel = 10;

  late FixedExtentScrollController _scrollController;
  late int selectedLevel;

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.initialLevel.clamp(_minLevel, _maxLevel);
    _scrollController = FixedExtentScrollController(
      initialItem: selectedLevel - _minLevel,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select pain level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListWheelScrollView(
                controller: _scrollController,
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedLevel = _minLevel + index;
                  });
                },
                children: List.generate(
                  _maxLevel - _minLevel + 1,
                  (index) => Center(child: Text('${_minLevel + index}')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, selectedLevel),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
