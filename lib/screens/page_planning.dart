import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_interactions.dart';
import '../theme/theme_app.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final _dayLabels = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  @override
  Widget build(BuildContext context) {
    final currentProfile = UserProfileController.profile.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Mon Planning',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: StreamBuilder<Availability?>(
        stream: InteractionsService.getAvailability(currentProfile.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final availability = snapshot.data ?? Availability.empty(currentProfile.email);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.blue, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Définis tes créneaux de disponibilité pour les mentorés et investisseurs.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.blue.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_days.length, (index) {
                final day = _days[index];
                final dayLabel = _dayLabels[index];
                final schedule = availability.schedule[day];

                return _DayScheduleCard(
                  day: day,
                  dayLabel: dayLabel,
                  schedule: schedule,
                  onChanged: (newSchedule) => _updateSchedule(
                    availability,
                    day,
                    newSchedule,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateSchedule(
    Availability current,
    String day,
    DaySchedule newSchedule,
  ) async {
    final updated = Availability(
      userId: current.userId,
      schedule: {...current.schedule, day: newSchedule},
      lastUpdated: DateTime.now(),
    );
    await InteractionsService.updateAvailability(updated);
  }
}

class _DayScheduleCard extends StatefulWidget {
  final String day;
  final String dayLabel;
  final DaySchedule? schedule;
  final Function(DaySchedule) onChanged;

  const _DayScheduleCard({
    required this.day,
    required this.dayLabel,
    required this.schedule,
    required this.onChanged,
  });

  @override
  State<_DayScheduleCard> createState() => _DayScheduleCardState();
}

class _DayScheduleCardState extends State<_DayScheduleCard> {
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.schedule?.isAvailable ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.dayLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyDeep,
                  ),
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (v) {
                  setState(() => _isAvailable = v);
                  widget.onChanged(
                    DaySchedule(
                      day: widget.day,
                      isAvailable: v,
                      timeSlots: v ? widget.schedule?.timeSlots ?? [] : [],
                    ),
                  );
                },
              ),
            ],
          ),
          if (_isAvailable && (widget.schedule?.timeSlots.isEmpty ?? true)) ...[
            const SizedBox(height: 8),
            const Text(
              'Disponible toute la journée',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else if (_isAvailable) ...[
            const SizedBox(height: 8),
            ...widget.schedule!.timeSlots.map((slot) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 16, color: AppColors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '${slot.startTime} - ${slot.endTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDeep,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
