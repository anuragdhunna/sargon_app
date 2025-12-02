import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/incidents/logic/incident_cubit.dart';
import 'package:hotel_manager/features/performance/data/performance_model.dart';
import 'package:hotel_manager/features/performance/logic/performance_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';

class EmployeePerformanceScreen extends StatefulWidget {
  static const routeName = '/performance';

  const EmployeePerformanceScreen({super.key});

  @override
  State<EmployeePerformanceScreen> createState() =>
      _EmployeePerformanceScreenState();
}

class _EmployeePerformanceScreenState extends State<EmployeePerformanceScreen> {
  String _searchQuery = '';
  String _sortBy = 'score'; // score, name, attendance, tasks

  @override
  void initState() {
    super.initState();
    _loadPerformances();
  }

  void _loadPerformances() {
    final userState = context.read<UserCubit>().state;
    final checklistState = context.read<ChecklistCubit>().state;
    final incidentState = context.read<IncidentCubit>().state;

    if (userState is UserLoaded &&
        checklistState is ChecklistLoaded &&
        incidentState is IncidentLoaded) {
      context.read<PerformanceCubit>().loadPerformances(
        userState.users,
        checklistState.checklists,
        incidentState.incidents,
      );
    }
  }

  List<EmployeePerformance> _filterAndSort(
    List<EmployeePerformance> performances,
  ) {
    var filtered = performances.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.userRole.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortBy) {
      case 'score':
        filtered.sort((a, b) => b.overallScore.compareTo(a.overallScore));
        break;
      case 'name':
        filtered.sort((a, b) => a.userName.compareTo(b.userName));
        break;
      case 'attendance':
        filtered.sort((a, b) => b.attendanceRate.compareTo(a.attendanceRate));
        break;
      case 'tasks':
        filtered.sort(
          (a, b) => b.taskCompletionRate.compareTo(a.taskCompletionRate),
        );
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPerformances,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Sort by: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _SortChip(
                            label: 'Score',
                            value: 'score',
                            selected: _sortBy == 'score',
                            onSelected: () => setState(() => _sortBy = 'score'),
                          ),
                          _SortChip(
                            label: 'Name',
                            value: 'name',
                            selected: _sortBy == 'name',
                            onSelected: () => setState(() => _sortBy = 'name'),
                          ),
                          _SortChip(
                            label: 'Attendance',
                            value: 'attendance',
                            selected: _sortBy == 'attendance',
                            onSelected: () =>
                                setState(() => _sortBy = 'attendance'),
                          ),
                          _SortChip(
                            label: 'Tasks',
                            value: 'tasks',
                            selected: _sortBy == 'tasks',
                            onSelected: () => setState(() => _sortBy = 'tasks'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Performance List
          Expanded(
            child: BlocBuilder<PerformanceCubit, PerformanceState>(
              builder: (context, state) {
                if (state is PerformanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PerformanceError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is PerformanceLoaded) {
                  final filtered = _filterAndSort(state.performances);

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No employees found'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final performance = filtered[index];
                      return _PerformanceCard(
                        performance: performance,
                        rank: index + 1,
                      );
                    },
                  );
                }
                return const Center(child: Text('No data available'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final EmployeePerformance performance;
  final int rank;

  const _PerformanceCard({required this.performance, required this.rank});

  Color _getGradeColor() {
    if (performance.overallScore >= 80) return Colors.green;
    if (performance.overallScore >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to employee detail screen
          context.go('/performance/${performance.userId}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rank <= 3
                          ? Colors.amber.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performance.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      performance.userRole.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetricChip(
                          icon: Icons.calendar_today,
                          label:
                              '${(performance.attendanceRate * 100).toStringAsFixed(0)}%',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _MetricChip(
                          icon: Icons.task_alt,
                          label:
                              '${performance.tasksCompleted}/${performance.tasksAssigned}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Score Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gradeColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      performance.grade,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    Text(
                      performance.overallScore.toStringAsFixed(0),
                      style: TextStyle(fontSize: 12, color: gradeColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
