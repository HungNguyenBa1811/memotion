import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../data/medication_scheduler.dart';

/// Sample payload matching the API contract in context.md.
const Map<String, dynamic> _sampleApiResponse = {
  'code': '200',
  'data': [
    {
      'task_id': 'c9640785-9dc7-4059-9cd4-972125b0201b',
      'task_duedate': '2026-02-10T08:00:00',
      'medication_detail': {
        'name': 'Paracetamol 500mg',
        'dosage': '1 vien',
        'notes': 'Uong sau an',
        'image_path': '/images/meds/paracetamol.png',
      },
    },
  ],
};

class MedicationReminderScreen extends ConsumerStatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  ConsumerState<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState
    extends ConsumerState<MedicationReminderScreen> {
  String _status = 'Idle';

  Future<void> _simulateSync() async {
    setState(() => _status = 'Syncing...');
    try {
      final count = await MedicationScheduler.syncTasks(_sampleApiResponse);
      if (!mounted) return;
      setState(() => _status = 'Scheduled $count alarm(s)');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Medication Reminders',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.alarm,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Medication Alarm Scheduler',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap below to parse the sample API response, '
                'save tasks locally, and schedule alarms.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _simulateSync,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Simulate API Sync',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _status,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
