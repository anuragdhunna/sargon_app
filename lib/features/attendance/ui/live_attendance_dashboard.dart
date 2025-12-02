import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:intl/intl.dart';

class LiveAttendanceDashboard extends StatefulWidget {
  static const routeName = '/attendance/live';

  const LiveAttendanceDashboard({super.key});

  @override
  State<LiveAttendanceDashboard> createState() =>
      _LiveAttendanceDashboardState();
}

class _LiveAttendanceDashboardState extends State<LiveAttendanceDashboard> {
  final AttendanceRepository _repository = AttendanceRepository();
  Map<String, AttendanceStatus>? _attendanceData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    final data = await _repository.getAllUsersAttendanceToday();
    setState(() {
      _attendanceData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Attendance - ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendance,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                if (userState is! UserLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = userState.users;
                final presentCount =
                    _attendanceData?.values
                        .where((s) => s == AttendanceStatus.present)
                        .length ??
                    0;
                final lateCount =
                    _attendanceData?.values
                        .where((s) => s == AttendanceStatus.late)
                        .length ??
                    0;
                final absentCount =
                    _attendanceData?.values
                        .where((s) => s == AttendanceStatus.absent)
                        .length ??
                    0;

                return RefreshIndicator(
                  onRefresh: _loadAttendance,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: 'Present',
                                count: presentCount,
                                color: Colors.green,
                                icon: Icons.check_circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Late',
                                count: lateCount,
                                color: Colors.orange,
                                icon: Icons.access_time,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Absent',
                                count: absentCount,
                                color: Colors.red,
                                icon: Icons.cancel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Employee List
                        Text(
                          'All Employees',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final status =
                                _attendanceData?[user.id] ??
                                AttendanceStatus.absent;

                            return _EmployeeCard(
                              user: user,
                              status: status,
                              onRefresh: _loadAttendance,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final User user;
  final AttendanceStatus status;
  final VoidCallback onRefresh;

  const _EmployeeCard({
    required this.user,
    required this.status,
    required this.onRefresh,
  });

  Color _getStatusColor() {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.onLeave:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.onLeave:
        return 'On Leave';
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.onLeave:
        return Icons.event_busy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            user.name[0].toUpperCase(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          user.role.name.toUpperCase(),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getStatusIcon(), size: 16, color: statusColor),
              const SizedBox(width: 6),
              Text(
                _getStatusText(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
