import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../data/medication_scheduler.dart';
import '../models/medication_task.dart';

/// Full-screen UI shown when a medication alarm fires.
/// Retrieves the persisted [MedicationTask] by alarm ID, displays
/// medication details + image, and lets the user dismiss.
class MedicationAlarmScreen extends StatefulWidget {
  final int alarmId;

  const MedicationAlarmScreen({super.key, required this.alarmId});

  @override
  State<MedicationAlarmScreen> createState() => _MedicationAlarmScreenState();
}

class _MedicationAlarmScreenState extends State<MedicationAlarmScreen> {
  MedicationTask? _task;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final task = await MedicationScheduler.getTaskByAlarmId(widget.alarmId);
    if (!mounted) return;
    setState(() {
      _task = task;
      _loading = false;
    });
  }

  Future<void> _markAsTaken() async {
    await Alarm.stop(widget.alarmId);
    await MedicationScheduler.removeTask(widget.alarmId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Could not load medication details.',
                style: GoogleFonts.lexend(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await Alarm.stop(widget.alarmId);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _task!.medicationDetail;
    final imageUrl = detail.fullImageUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              // Alarm icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm_on,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Time to take your medication',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // Medication image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                      : _imagePlaceholder(),
                ),
              ),
              const SizedBox(height: 24),

              // Medication name
              Text(
                detail.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Dosage
              _infoRow(Icons.medication, detail.dosage),
              const SizedBox(height: 8),

              // Notes
              _infoRow(Icons.notes, detail.notes),
              const Spacer(),

              // Mark as Taken button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _markAsTaken,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    'Mark as Taken',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(
        Icons.medication,
        size: 64,
        color: AppColors.primary,
      ),
    );
  }
}
