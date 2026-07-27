import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';

class Step2Builder extends ConsumerStatefulWidget {
  const Step2Builder({super.key});

  @override
  ConsumerState<Step2Builder> createState() => _Step2BuilderState();
}

class _Step2BuilderState extends ConsumerState<Step2Builder> {
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late FocusNode _nameFocus;
  late FocusNode _heightFocus;
  late FocusNode _weightFocus;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _nameController = TextEditingController(text: state.fullName ?? '');
    _heightController = TextEditingController(
      text: state.height != null ? state.height.toString() : '',
    );
    _weightController = TextEditingController(
      text: state.weight != null ? state.weight.toString() : '',
    );
    _nameFocus = FocusNode();
    _heightFocus = FocusNode();
    _weightFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _nameFocus.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 24),
          // Tên - full width, height 54 theo Figma
          _buildNameInput(),
          const SizedBox(height: 16),
          // Năm sinh (trái) + Giới tính (phải) theo Figma layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBirthYearInput(onboardingState)),
              const SizedBox(width: 12),
              Expanded(child: _buildGenderInput(onboardingState)),
            ],
          ),
          const SizedBox(height: 16),
          // Chiều cao (trái) + Cân nặng (phải)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildHeightInput()),
              const SizedBox(width: 12),
              Expanded(child: _buildWeightInput()),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    const config = OnboardingStep2Config();
    return Text(
      config.title,
      textAlign: config.titleAlignment.textAlign,
      style: GoogleFonts.lexend(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: Theme.of(context).textTheme.headlineSmall?.color,
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name of the person receiving care',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 54, // Figma height
          child: TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            decoration: InputDecoration(
              hintText: 'Full name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              ref.read(onboardingProvider.notifier).setFullName(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBirthYearInput(OnboardingData state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth year',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await showDialog<int>(
              context: context,
              builder: (context) =>
                  _BirthYearPicker(initialYear: state.birthYear ?? 1960),
            );
            if (result != null) {
              ref.read(onboardingProvider.notifier).setBirthYear(result);
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
                  state.birthYear != null
                      ? state.birthYear.toString()
                      : 'Select',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderInput(OnboardingData state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 54,
          child: DropdownButtonFormField<Gender>(
            value: state.gender,
            items: Gender.values
                .map(
                  (g) => DropdownMenuItem(value: g, child: Text(g.displayName)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(onboardingProvider.notifier).setGender(value);
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Height (cm)',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 54,
          child: TextField(
            controller: _heightController,
            focusNode: _heightFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '160',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              final height = double.tryParse(value);
              if (height != null) {
                ref.read(onboardingProvider.notifier).setHeight(height);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight (kg)',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 54,
          child: TextField(
            controller: _weightController,
            focusNode: _weightFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '70',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFBEBAB3)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              final weight = double.tryParse(value);
              if (weight != null) {
                ref.read(onboardingProvider.notifier).setWeight(weight);
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Dialog picker cho chọn năm sinh
class _BirthYearPicker extends StatefulWidget {
  final int initialYear;

  const _BirthYearPicker({required this.initialYear});

  @override
  State<_BirthYearPicker> createState() => _BirthYearPickerState();
}

class _BirthYearPickerState extends State<_BirthYearPicker> {
  late FixedExtentScrollController _scrollController;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
    final startYear = 1920;
    final index = selectedYear - startYear;
    _scrollController = FixedExtentScrollController(initialItem: index);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endYear = now.year;

    return Dialog(
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select birth year',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListWheelScrollView(
                controller: _scrollController,
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedYear = 1920 + index;
                  });
                },
                children: List.generate(
                  endYear - 1920 + 1, // inclusive of the current year
                  (index) => Center(child: Text('${1920 + index}')),
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
                    onPressed: () => Navigator.pop(context, selectedYear),
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
