// ignore_for_file: file_names

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ExpertSystem.dart';

class PlantJourneyWidget extends StatelessWidget {
  const PlantJourneyWidget({
    super.key,
    required this.selectedPlant,
    required this.profile,
    required this.currentDay,
    required this.mission,
    required this.startedAt,
    required this.busy,
    required this.onPlantChanged,
    required this.onStart,
    required this.onComplete,
  });

  final String selectedPlant;
  final PlantProfile profile;
  final int? currentDay;
  final DailyMission? mission;
  final DateTime? startedAt;
  final bool busy;
  final ValueChanged<String> onPlantChanged;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  bool get isActive => currentDay != null && mission != null;

  @override
  Widget build(BuildContext context) {
    final day = currentDay ?? 1;
    final progress = isActive
        ? (day / profile.harvestDays).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perjalanan Tanaman',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      isActive
                          ? '$selectedPlant dimulai ${_date(startedAt!)}'
                          : 'Pilih tanaman lalu mulai permainan',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Hari $day' : 'Belum mulai',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isActive) ...[
            const Text(
              'Pilih tanaman',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpertSystem.supportedPlants.map((plant) {
                final selected = plant == selectedPlant;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => onPlantChanged(plant),
                  avatar: Icon(
                    Icons.local_florist_rounded,
                    size: 17,
                    color: selected ? Colors.white : const Color(0xFF0F766E),
                  ),
                  label: Text(plant),
                  selectedColor: const Color(0xFF0F766E),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF334155),
                    fontWeight: FontWeight.w800,
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            isActive ? 'Hari' : 'Preview Hari',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _DayTimeline(
            currentDay: isActive ? day : null,
            harvestDays: profile.harvestDays,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: mission?.harvestReady == true
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF16A34A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}% / ${profile.harvestDays} hari',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (mission != null) _MissionCard(mission: mission!),
          if (!isActive)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: busy ? null : onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Mulai Menanam $selectedPlant'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                ),
              ),
            )
          else if (mission!.harvestReady)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: busy ? null : onComplete,
                icon: const Icon(Icons.emoji_events_rounded),
                label: const Text('Selesaikan Panen'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: const Color(0xFF422006),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Panen terkunci. ${profile.harvestDays - day} hari lagi menuju kisaran panen.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _date(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({required this.currentDay, required this.harvestDays});

  final int? currentDay;
  final int harvestDays;

  @override
  Widget build(BuildContext context) {
    final activeDay = currentDay ?? 1;
    final start = currentDay == null ? 1 : math.max(1, activeDay - 1);
    final end = math.min(harvestDays, start + 3);
    final days = [for (var day = start; day <= end; day++) day];

    return SizedBox(
      height: 84,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final nodeSize = math.min(
            66.0,
            (constraints.maxWidth - 12) / days.length,
          );
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 28,
                right: 28,
                top: 39,
                child: Container(height: 4, color: const Color(0xFFCBD5E1)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((day) {
                  final isCurrent = currentDay == day;
                  final isPassed = currentDay != null && day < activeDay;
                  final color = isCurrent
                      ? const Color(0xFF15803D)
                      : isPassed
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFA8B0BD);
                  return Container(
                    width: nodeSize,
                    height: nodeSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Text(
                      '$day',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final DailyMission mission;

  @override
  Widget build(BuildContext context) {
    final color = mission.harvestReady
        ? const Color(0xFFF59E0B)
        : mission.fertilizerToday
        ? const Color(0xFF7C3AED)
        : const Color(0xFF0F766E);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${mission.title} | ${mission.phase}',
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...mission.tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(task, style: const TextStyle(height: 1.35)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
