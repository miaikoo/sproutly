import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/child_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/behaviour_log.dart';
import '../../../core/services/schedule_service.dart';
import '../widgets/child_progress_panel.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;

  int get _daysInMonth {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));
    return lastDay.day;
  }

  int get _firstWeekday {
    return DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(currentChildProvider);
    final childId = childAsync.valueOrNull?.id;

    if (childId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final logsAsync = ref.watch(logsForChildProvider(childId));
    final schedulesAsync = ref.watch(schedulesForChildProvider(childId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text('Kalender Aktivitas', style: AppTextStyles.headingL),
        centerTitle: true,
      ),
      body: SafeArea(
        child: logsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (logs) {
            final titlesById = {
              for (final schedule in schedulesAsync.value ?? [])
                for (final activity in schedule.activities) activity.id: activity.title,
            };

            // Find logs for the selected date
            final selectedLogs = _selectedDate == null
                ? <BehaviourLog>[]
                : logs.where((log) => _isSameDay(log.timestamp.toLocal(), _selectedDate!)).toList();

            return SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarHeader(),
                  AppSpacing.gapLG,
                  _buildCalendarGrid(logs),
                  AppSpacing.gapXXL,
                  if (_selectedDate != null) ...[
                    Text(
                      'Aktivitas tanggal ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: AppTextStyles.headingM,
                    ),
                    AppSpacing.gapMD,
                    if (selectedLogs.isEmpty)
                      const Text('Tidak ada aktivitas pada tanggal ini.', style: AppTextStyles.bodyM)
                    else
                      for (final log in selectedLogs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BehaviourLogRow(
                            log: log,
                            activityTitle: titlesById[log.activityId] ?? 'Aktivitas',
                          ),
                        ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
              _selectedDate = null;
            });
          },
        ),
        Text(
          '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
          style: AppTextStyles.headingL,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
              _selectedDate = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(List<BehaviourLog> logs) {
    final daysInMonth = _daysInMonth;
    final firstWeekday = _firstWeekday; // 1 = Monday, 7 = Sunday
    // Offset so Monday = 0
    final offset = firstWeekday - 1; 
    
    final totalCells = ((daysInMonth + offset) / 7).ceil() * 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
              .map((d) => Expanded(child: Center(child: Text(d, style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.bold)))))
              .toList(),
        ),
        AppSpacing.gapMD,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final day = index - offset + 1;
            if (day < 1 || day > daysInMonth) {
              return const SizedBox(); // Empty cell
            }

            final date = DateTime(_currentMonth.year, _currentMonth.month, day);
            final hasLogs = logs.any((log) => _isSameDay(log.timestamp.toLocal(), date));
            final isSelected = _selectedDate != null && _isSameDay(_selectedDate!, date);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.teal500
                      : (hasLogs ? AppColors.teal100 : Colors.transparent),
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: AppTextStyles.bodyM.copyWith(
                    color: isSelected ? Colors.white : (hasLogs ? AppColors.teal900 : AppColors.neutral900),
                    fontWeight: isSelected || hasLogs ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
