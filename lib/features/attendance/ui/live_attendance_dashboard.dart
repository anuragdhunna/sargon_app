import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/badges/status_badge.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/cards/stat_card.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
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
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: Text(
          'Live Attendance - ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
                        // Summary Cards using StatCard component
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Present',
                                value: presentCount.toString(),
                                icon: Icons.check_circle,
                                color: AppDesign.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Late',
                                value: lateCount.toString(),
                                icon: Icons.access_time,
                                color: AppDesign.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Absent',
                                value: absentCount.toString(),
                                icon: Icons.cancel,
                                color: AppDesign.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Employee List Header
                        Text(
                          'All Employees',
                          style: AppDesign.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Employee Cards
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

                            return _EmployeeCard(user: user, status: status);
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

/// Employee card widget using AppCard and StatusBadge components
class _EmployeeCard extends StatelessWidget {
  final User user;
  final AttendanceStatus status;

  const _EmployeeCard({required this.user, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case AttendanceStatus.present:
        return AppDesign.success;
      case AttendanceStatus.late:
        return AppDesign.warning;
      case AttendanceStatus.absent:
        return AppDesign.error;
      case AttendanceStatus.onLeave:
        return AppDesign.info;
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

  StatusBadge _getStatusBadge() {
    switch (status) {
      case AttendanceStatus.present:
        return StatusBadge.success(
          label: _getStatusText(),
          icon: _getStatusIcon(),
        );
      case AttendanceStatus.late:
        return StatusBadge.warning(
          label: _getStatusText(),
          icon: _getStatusIcon(),
        );
      case AttendanceStatus.absent:
        return StatusBadge.error(
          label: _getStatusText(),
          icon: _getStatusIcon(),
        );
      case AttendanceStatus.onLeave:
        return StatusBadge.info(
          label: _getStatusText(),
          icon: _getStatusIcon(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            radius: 24,
            child: Text(
              user.name[0].toUpperCase(),
              style: AppDesign.titleMedium.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role.name.toUpperCase(),
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral600,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          _getStatusBadge(),
        ],
      ),
    );
  }
}
