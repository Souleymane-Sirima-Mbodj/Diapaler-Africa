import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../services/service_authentification.dart';
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
    final currentUid = AuthService.currentUid ?? '';

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
        stream: InteractionsService.getAvailability(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            );
          }

          final availability = snapshot.data ?? Availability.empty(currentUid);

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
    try {
      await InteractionsService.updateAvailability(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planning mis à jour ✓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : impossible de sauvegarder. $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );
    }
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
  late List<TimeSlot> _slots;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.schedule?.isAvailable ?? true;
    _slots = List<TimeSlot>.from(widget.schedule?.timeSlots ?? const []);
  }

  @override
  void didUpdateWidget(covariant _DayScheduleCard old) {
    super.didUpdateWidget(old);
    // Resync depuis Firebase si le snapshot change pendant qu'on est sur la page.
    final next = widget.schedule;
    if (next != null && next != old.schedule) {
      _isAvailable = next.isAvailable;
      _slots = List<TimeSlot>.from(next.timeSlots);
    }
  }

  void _emit() {
    widget.onChanged(
      DaySchedule(
        day: widget.day,
        isAvailable: _isAvailable,
        timeSlots: _isAvailable ? _slots : const [],
      ),
    );
  }

  Future<void> _addSlot() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Heure de début',
    );
    if (start == null || !mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (start.hour + 1).clamp(0, 23), minute: start.minute),
      helpText: 'Heure de fin',
    );
    if (end == null) return;

    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    if (endMin <= startMin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'heure de fin doit être après l\'heure de début.')),
      );
      return;
    }
    setState(() {
      _slots.add(TimeSlot(
        startHour: start.hour,
        startMinute: start.minute,
        endHour: end.hour,
        endMinute: end.minute,
      ));
      _slots.sort((a, b) =>
          (a.startHour * 60 + a.startMinute).compareTo(b.startHour * 60 + b.startMinute));
    });
    _emit();
  }

  void _removeSlot(int index) {
    setState(() => _slots.removeAt(index));
    _emit();
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
                  setState(() {
                    _isAvailable = v;
                    if (!v) _slots = [];
                  });
                  _emit();
                },
              ),
            ],
          ),
          if (_isAvailable) ...[
            const SizedBox(height: 8),
            if (_slots.isEmpty)
              const Text(
                'Disponible toute la journée',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...List.generate(_slots.length, (i) {
                final slot = _slots[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 16, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${slot.startTime} – ${slot.endTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyDeep,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeSlot(i),
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addSlot,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Ajouter un créneau'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 32),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
