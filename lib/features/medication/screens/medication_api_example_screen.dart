import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';
import '../../../core/theme/theme.dart';

/// Example screen showing how to use the Medication API integration
///
/// This demonstrates:
/// 1. Loading medications from API
/// 2. Filtering by status
/// 3. Handling loading/error states
/// 4. Taking/skipping medications
class MedicationApiExampleScreen extends ConsumerWidget {
  const MedicationApiExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final medicationsAsync = ref.watch(
      filteredMedicationsProvider(selectedFilter),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication API Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data from API
              ref.invalidate(medicationsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter buttons
          _buildFilterButtons(ref, selectedFilter),

          // Medications list
          Expanded(
            child: medicationsAsync.when(
              data: (medications) => _buildMedicationsList(medications, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(WidgetRef ref, MedicationFilter selectedFilter) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedFilter == MedicationFilter.all,
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state =
                  MedicationFilter.all;
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Taken',
            isSelected: selectedFilter == MedicationFilter.taken,
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state =
                  MedicationFilter.taken;
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Missed',
            isSelected: selectedFilter == MedicationFilter.missed,
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state =
                  MedicationFilter.missed;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList(List<Medication> medications, WidgetRef ref) {
    if (medications.isEmpty) {
      return const Center(child: Text('No medications found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return _MedicationCard(medication: medication);
      },
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading medications',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _MedicationCard extends ConsumerWidget {
  final Medication medication;

  const _MedicationCard({required this.medication});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.dosage} • ${medication.frequency}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: medication.status),
              ],
            ),

            const SizedBox(height: 12),

            // Time info
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text('Time: ${medication.time}'),
                if (medication.remainingTime != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'In ${medication.remainingTime}',
                    style: const TextStyle(color: AppColors.tealAccent),
                  ),
                ],
              ],
            ),

            // Actions
            if (medication.status == MedicationStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final notifier = ref.read(
                          medicationNotifierProvider.notifier,
                        );
                        await notifier.takeMedication(medication.id);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Take'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final notifier = ref.read(
                          medicationNotifierProvider.notifier,
                        );
                        await notifier.skipMedication(medication.id);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Skip'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MedicationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case MedicationStatus.taken:
        color = Colors.green;
        text = 'Taken';
        break;
      case MedicationStatus.missed:
        color = Colors.red;
        text = 'Missed';
        break;
      case MedicationStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Provider for the medication notifier
// `medicationNotifierProvider` is defined in
// `lib/features/medication/providers/medication_provider.dart`.
// Do not redeclare it here to avoid duplicate definition errors.
