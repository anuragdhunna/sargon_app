import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';
import 'package:hotel_manager/features/attendance/logic/attendance_cubit.dart';
import 'package:intl/intl.dart';

class AttendanceReportsScreen extends StatelessWidget {
  static const routeName = '/attendance/reports';

  const AttendanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance Report'),
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is! AttendanceLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = state.history;
          final totalPunches = history.length;
          // Count unique days
          final uniqueDays = history.map((r) => DateFormat('yyyy-MM-dd').format(r.timestamp)).toSet().length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Filter (Mock)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Last 30 Days',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Summary Cards
                Row(
                  children: [
                    Expanded(child: _SummaryCard(title: 'Days Present', value: uniqueDays.toString(), color: Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _SummaryCard(title: 'Total Punches', value: totalPunches.toString(), color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 32),

                // Detailed List
                Text('Punch History', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    final isCheckIn = record.type == AttendanceType.checkIn;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCheckIn ? Colors.green.shade50 : Colors.red.shade50,
                          child: Icon(isCheckIn ? Icons.login : Icons.logout, color: isCheckIn ? Colors.green : Colors.red, size: 20),
                        ),
                        title: Text(isCheckIn ? 'Punch In' : 'Punch Out', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('MMM d, yyyy').format(record.timestamp)),
                        trailing: Text(
                          DateFormat('h:mm a').format(record.timestamp),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.color});

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
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }
}
