import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/nutrition_task.dart';
import '../../providers/nutrition_provider.dart';
import '../../../workout/widgets/calendar_day_picker.dart';
import '../../../workout/models/workout_model.dart';
import '../../../voice_command/widgets/voice_command_fab.dart';

/// Nutrition screen for PATIENT (Elderly) role.
/// Displays one large vertical card per meal task in a PageView.
class PatientNutritionScreenContent extends ConsumerStatefulWidget {
  const PatientNutritionScreenContent({super.key});

  @override
  ConsumerState<PatientNutritionScreenContent> createState() =>
      _PatientNutritionScreenContentState();
}

class _PatientNutritionScreenContentState
    extends ConsumerState<PatientNutritionScreenContent> {
  final PageController _pageController = PageController();
  late int _selectedDayIndex;
  late List<CalendarDay> _calendarDays;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildCalendarDays();
  }

  void _rebuildCalendarDays() {
    final dayCount = ResponsiveUtils.dateSelectorDays(context);
    final offset = dayCount ~/ 2;
    final now = DateTime.now();
    _calendarDays = List.generate(dayCount, (i) {
      final date = now.add(Duration(days: i - offset));
      return CalendarDay(
        date: date,
        dayOfWeek: '',
        month: '',
        isSelected: i == offset,
      );
    });
    _selectedDayIndex = offset;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(nutritionFilterProvider);
    final nutritionTasksAsync = ref.watch(
      filteredNutritionTasksProvider(selectedFilter),
    );

    final displayTasks = nutritionTasksAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 16),
              CalendarDayPicker(
                days: _calendarDays,
                selectedIndex: _selectedDayIndex,
                scale: ResponsiveUtils.isTabletOrLarger(context)
                    ? (ResponsiveUtils.isLargeTablet(context) ? 2.3 : 2.0)
                    : 1.0,
                onDaySelected: (index) {
                  setState(() => _selectedDayIndex = index);
                  ref.read(nutritionSelectedDateProvider.notifier).state =
                      _calendarDays[index].date;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: _buildPagedCards(
                  context,
                  displayTasks,
                  isLoading: nutritionTasksAsync.isLoading,
                  apiError: nutritionTasksAsync.hasError
                      ? nutritionTasksAsync.error
                      : null,
                ),
              ),
              SizedBox(height: ResponsiveUtils.bottomNavPadding(context) * 20),
            ],
          ),
        ),
      ),
      floatingActionButton: const VoiceCommandFAB(),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    // Mimic the font scale from medication screen
    final fontScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: Container(
              width: isLarge ? 92.0 : isTablet ? 80.0 : 40.0,
              height: isLarge ? 92.0 : isTablet ? 80.0 : 40.0,
              decoration: const BoxDecoration(
                color: Color(0xFF00695C),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: isLarge ? 36.0 : isTablet ? 32.0 : 18.0),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Nutrition Plan',
                style: GoogleFonts.lexend(
                  // Match Medication screen size on tablet, but keep mobile original size
                  fontSize: 18 * textScale * (isTablet ? fontScale * 0.7 : 1.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Your daily meals',
                style: GoogleFonts.lexend(
                  fontSize: 12 * textScale * (isTablet ? fontScale * 0.7 : 1.0),
                  color: const Color(0xFFD87659),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(width: isLarge ? 92.0 : isTablet ? 80.0 : 40.0),
        ],
      ),
    );
  }



  Widget _buildPagedCards(
    BuildContext context,
    List<NutritionTask> tasks, {
    bool isLoading = false,
    Object? apiError,
  }) {
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final fontScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;

    return Column(
      children: [
        // Inline API state: loading spinner or error banner
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                color: AppColors.secondary,
                backgroundColor: Colors.transparent,
              ),
            ),
          )
        else if (apiError != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.horizontalPadding(context), 0,
              ResponsiveUtils.horizontalPadding(context), 8 * fontScale,
            ),
            child: Row(
              children: [
                Icon(
                  apiError is PatientProfileNotFoundException
                      ? Icons.person_off
                      : Icons.error_outline,
                  size: 16 * fontScale,
                  color: apiError is PatientProfileNotFoundException
                      ? AppColors.primary
                      : Colors.red.shade300,
                ),
                SizedBox(width: 6 * fontScale),
                Expanded(
                  child: Text(
                    apiError is PatientProfileNotFoundException
                        ? 'No patient profile — showing demo meal.'
                        : 'Could not load meals — showing demo.',
                    style: GoogleFonts.lexend(
                        fontSize: 12 * fontScale, color: Colors.grey[600]),
                  ),
                ),
                if (apiError is! PatientProfileNotFoundException)
                  GestureDetector(
                    onTap: () => ref.invalidate(nutritionTasksProvider),
                    child: Icon(Icons.refresh,
                        size: 16 * fontScale, color: AppColors.primary),
                  ),
              ],
            ),
          ),

        // PageView with large cards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: tasks.length,
            onPageChanged: (_) {},
            itemBuilder: (context, index) => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.horizontalPadding(context),
                ),
                child: _PatientNutritionCard(
                  task: tasks[index],
                  onTap: () => context.push(
                    AppRoutes.nutritionDetail,
                    extra: {'taskId': tasks[index].id},
                  ),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

}

// ─── Full-width patient card — same layout as Keto Salad, scaled to screen ───

class _PatientNutritionCard extends StatelessWidget {
  final NutritionTask task;
  final VoidCallback? onTap;

  const _PatientNutritionCard({required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = ResponsiveUtils.textScaleFactor(context);
          // Image fills ~75% of card width, but capped so the card
          // never exceeds the available height (prevents bottom clipping).
          final contentReserve = 130 * scale; // text + paddings below image
          final maxByHeight = constraints.maxHeight - contentReserve;
          final imageSize = (constraints.maxWidth * 0.75).clamp(0.0, maxByHeight.clamp(120.0, double.infinity));
          // Image overlaps ~45% above the card top edge
          final imageOverlap = imageSize * 0.45;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Non-positioned element defines Stack size
              Padding(
                padding: EdgeInsets.only(top: imageOverlap),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70 * scale),
                      topRight: Radius.circular(70 * scale),
                      bottomLeft: Radius.circular(27 * scale),
                      bottomRight: Radius.circular(27 * scale),
                    ),
                  ),
                  // Padding inside the white card
                  padding: EdgeInsets.only(
                    top: (imageSize - imageOverlap) + (24 * scale), // push text below image
                    left: 28 * scale,
                    right: 28 * scale,
                    bottom: 28 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Wrap content height
                    children: [
                      Text(
                        task.name,
                        style: GoogleFonts.lexend(
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B4332),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2 * scale),
                      if (task.description != null &&
                          task.description!.isNotEmpty)
                        Text(
                          task.description!,
                          style: GoogleFonts.lexend(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF1B4332),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 8 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task.calories != null
                                ? '${task.calories} Kcal'
                                : '',
                            style: GoogleFonts.lexend(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4332),
                            ),
                          ),
                          Icon(
                            Icons.favorite_outline,
                            size: 28 * scale,
                            color:
                                const Color(0xFF4DB6AC).withOpacity(0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Circular image — positioned at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: -0.194,
                    child: Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(child: _buildImage(imageSize)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(double size) {
    if (task.imagePath != null && task.imagePath!.isNotEmpty) {
      return Image.network(
        '${ApiConstants.baseUrl}${task.imagePath}',
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildPlaceholder(size),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: task.mealColor,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      color: task.mealColor.withOpacity(0.1),
      child: Icon(task.mealIcon, size: size * 0.4, color: task.mealColor),
    );
  }
}
