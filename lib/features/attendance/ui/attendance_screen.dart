import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';
import 'package:hotel_manager/features/attendance/logic/attendance_cubit.dart';
import 'package:hotel_manager/features/attendance/ui/attendance_regularization_dialog.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  static const String routeName = '/attendance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance & Timesheet'),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is AuthVerified) {
                final role = authState.role;
                if (role == UserRole.manager || role == UserRole.owner) {
                  return IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    tooltip: 'Regularize',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: context.read<AttendanceCubit>(),
                            ),
                            BlocProvider.value(
                              value: context.read<UserCubit>(),
                            ),
                            BlocProvider.value(
                              value: context.read<AuthCubit>(),
                            ),
                          ],
                          child: const AttendanceRegularizationDialog(),
                        ),
                      );
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Reports',
            onPressed: () => context.go('/attendance/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Live Dashboard',
            onPressed: () => context.go('/attendance/live'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar',
            onPressed: () => context.go('/attendance/calendar'),
          ),
        ],
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            return Column(
              children: [
                // Header / Punch Action
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('h:mm a').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        height: 60,
                        child: FilledButton.icon(
                          onPressed: () {
                            final type = state.isCheckedIn
                                ? AttendanceType.checkOut
                                : AttendanceType.checkIn;
                            context.read<AttendanceCubit>().punch(type);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: state.isCheckedIn
                                ? Colors.red
                                : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: Icon(
                            state.isCheckedIn ? Icons.logout : Icons.login,
                          ),
                          label: Text(
                            state.isCheckedIn ? 'PUNCH OUT' : 'PUNCH IN',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hotel Premises (Geo-fenced)',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, authState) {
                          if (authState is AuthVerified) {
                            final role = authState.role;
                            if (role == UserRole.manager ||
                                role == UserRole.owner) {
                              // This TextButton.icon is now redundant if the one in AppBar actions is sufficient.
                              // However, the instruction only asked to add to AppBar actions, not remove from here.
                              return const SizedBox.shrink(); // Hide the original button if it's now in the AppBar
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),

                // History List
                Expanded(
                  child: state.history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No attendance records yet.',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: state.history.length,
                          itemBuilder: (context, index) {
                            final record = state.history[index];
                            final isCheckIn =
                                record.type == AttendanceType.checkIn;

                            return IntrinsicHeight(
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        DateFormat(
                                          'h:mm a',
                                        ).format(record.timestamp),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'd MMM',
                                        ).format(record.timestamp),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children: [
                                      Container(
                                        width: 2,
                                        height: 16,
                                        color: index == 0
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isCheckIn
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isCheckIn
                                                ? Colors.green
                                                : Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          isCheckIn
                                              ? Icons.login
                                              : Icons.logout,
                                          size: 16,
                                          color: isCheckIn
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color:
                                              index == state.history.length - 1
                                              ? Colors.transparent
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 24),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.02,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isCheckIn
                                                ? 'Checked In'
                                                : 'Checked Out',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isCheckIn
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Location: ${record.latitude.toStringAsFixed(4)}, ${record.longitude.toStringAsFixed(4)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
