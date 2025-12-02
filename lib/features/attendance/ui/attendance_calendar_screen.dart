import 'package:flutter/material.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  static const routeName = '/attendance/calendar';

  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  final AttendanceRepository _repository = AttendanceRepository();
  late DateTime _selectedMonth;
  Map<DateTime, AttendanceStatus>? _monthlyData;
  bool _isLoading = true;
  String? _userId;

  // Mock holidays (in a real app, this would come from a database)
  final Set<DateTime> _holidays = {
    DateTime(2024, 1, 26), // Republic Day
    DateTime(2024, 8, 15), // Independence Day
    DateTime(2024, 10, 2), // Gandhi Jayanti
    DateTime(2024, 12, 25), // Christmas
    DateTime(2025, 1, 26),
    DateTime(2025, 8, 15),
    DateTime(2025, 10, 2),
    DateTime(2025, 12, 25),
  };

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthVerified) {
      setState(() {
        _isLoading = true;
        _userId = authState.userId;
      });

      final data = await _repository.getMonthlyAttendance(
        authState.userId,
        _selectedMonth.year,
        _selectedMonth.month,
      );

      setState(() {
        _monthlyData = data;
        _isLoading = false;
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadCalendar();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadCalendar();
  }

  bool _isHoliday(DateTime date) {
    return _holidays.any((h) =>
        h.year == date.year && h.month == date.month && h.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() => _selectedMonth = DateTime.now());
              _loadCalendar();
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Navigation
                  _MonthNavigator(
                    selectedMonth: _selectedMonth,
                    onPrevious: _previousMonth,
                    onNext: _nextMonth,
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  if (_monthlyData != null) ...[
                    _SummarySection(
                      monthlyData: _monthlyData!,
                      holidays: _holidays,
                      selectedMonth: _selectedMonth,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Calendar Grid
                  _CalendarGrid(
                    selectedMonth: _selectedMonth,
                    monthlyData: _monthlyData ?? {},
                    holidays: _holidays,
                  ),

                  const SizedBox(height: 24),

                  // Legend
                  _Legend(),
                ],
              ),
            ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final Map<DateTime, AttendanceStatus> monthlyData;
  final Set<DateTime> holidays;
  final DateTime selectedMonth;

  const _SummarySection({
    required this.monthlyData,
    required this.holidays,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final presentDays = monthlyData.values.where((s) => s == AttendanceStatus.present).length;
    final lateDays = monthlyData.values.where((s) => s == AttendanceStatus.late).length;
    final absentDays = monthlyData.values.where((s) => s == AttendanceStatus.absent).length;
    
    final monthHolidays = holidays.where((h) =>
        h.year == selectedMonth.year && h.month == selectedMonth.month).length;

    final attendanceRate = monthlyData.isEmpty
        ? 0.0
        : ((presentDays + lateDays) / monthlyData.length * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Present',
                value: presentDays.toString(),
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Late',
                value: lateDays.toString(),
                color: Colors.orange,
                icon: Icons.access_time,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Absent',
                value: absentDays.toString(),
                color: Colors.red,
                icon: Icons.cancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Holidays',
                value: monthHolidays.toString(),
                color: Colors.blue,
                icon: Icons.event,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Rate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '${attendanceRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: attendanceRate >= 80 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime selectedMonth;
  final Map<DateTime, AttendanceStatus> monthlyData;
  final Set<DateTime> holidays;

  const _CalendarGrid({
    required this.selectedMonth,
    required this.monthlyData,
    required this.holidays,
  });

  bool _isHoliday(DateTime date) {
    return holidays.any((h) =>
        h.year == date.year && h.month == date.month && h.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Column(
      children: [
        // Weekday Headers
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar Days
        ...List.generate((daysInMonth + firstWeekday + 6) ~/ 7, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }

                final date = DateTime(selectedMonth.year, selectedMonth.month, dayNumber);
                final status = monthlyData[date] ?? AttendanceStatus.absent;
                final isHoliday = _isHoliday(date);
                final isToday = DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;

                return Expanded(
                  child: _DayCell(
                    day: dayNumber,
                    status: status,
                    isHoliday: isHoliday,
                    isToday: isToday,
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final AttendanceStatus status;
  final bool isHoliday;
  final bool isToday;

  const _DayCell({
    required this.day,
    required this.status,
    required this.isHoliday,
    required this.isToday,
  });

  Color _getBackgroundColor() {
    if (isHoliday) return Colors.blue.withOpacity(0.2);
    
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green.withOpacity(0.2);
      case AttendanceStatus.late:
        return Colors.orange.withOpacity(0.2);
      case AttendanceStatus.absent:
        return Colors.red.withOpacity(0.1);
      case AttendanceStatus.onLeave:
        return Colors.purple.withOpacity(0.2);
    }
  }

  Color _getBorderColor() {
    if (isToday) return Colors.blue;
    if (isHoliday) return Colors.blue.withOpacity(0.5);
    
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green.withOpacity(0.5);
      case AttendanceStatus.late:
        return Colors.orange.withOpacity(0.5);
      case AttendanceStatus.absent:
        return Colors.red.withOpacity(0.3);
      case AttendanceStatus.onLeave:
        return Colors.purple.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(
          color: _getBorderColor(),
          width: isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (isHoliday)
              const Icon(Icons.event, size: 12, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendItem(color: Colors.green, label: 'Present'),
            _LegendItem(color: Colors.orange, label: 'Late'),
            _LegendItem(color: Colors.red, label: 'Absent'),
            _LegendItem(color: Colors.blue, label: 'Holiday'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
