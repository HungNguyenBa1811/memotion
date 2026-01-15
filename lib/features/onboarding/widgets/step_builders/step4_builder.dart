import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_option_cell.dart';

/// Builder cho Step 4: Pain Locations
///
/// Hiển thị:
/// - Title: Vị trí đau
/// - Grid các vị trí đau (có thể chọn nhiều)
/// - Image minh họa
class Step4Builder extends ConsumerStatefulWidget {
  const Step4Builder({super.key});

  @override
  ConsumerState<Step4Builder> createState() => _Step4BuilderState();
}

class _Step4BuilderState extends ConsumerState<Step4Builder> {
  late final TextEditingController _adviceController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _adviceController = TextEditingController(text: state.doctorAdvice ?? '');
  }

  @override
  void dispose() {
    _adviceController.dispose();
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
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildContent(context, ref, onboardingState),
          const SizedBox(height: 20),
          _buildImage(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const config = OnboardingStep4Config();
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    OnboardingData state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: PainLocation.values.take(3).map((location) {
        final isSelected = state.selectedPainLocations.contains(location);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OnboardingOptionCell(
            text: location.displayName,
            isSelected: isSelected,
            onTap: () {
              ref
                  .read(onboardingProvider.notifier)
                  .togglePainLocation(location);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImage(BuildContext context) {
    const config = OnboardingStep4Config();
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          config.imagePath ?? 'assets/images/placeholder.png',
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
      ),
    );
  }
}
