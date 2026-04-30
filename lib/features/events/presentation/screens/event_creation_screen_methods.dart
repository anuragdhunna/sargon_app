// ignore_for_file: invalid_use_of_protected_member

part of 'event_creation_screen.dart';

extension _EventCreationScreenMethods on _EventCreationScreenState {
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppDesign.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppDesign.primaryStart,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && mounted) {
          setState(() => _selectedDate = picked);
          _checkAvailability();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppDesign.neutral200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppDesign.primaryStart),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
              style: AppDesign.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeTile(
            'Start',
            _startTime,
            (t) => setState(() => _startTime = t),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimeTile(
            'End',
            _endTime,
            (t) => setState(() => _endTime = t),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTile(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onSelect(picked);
          _checkAvailability();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppDesign.neutral200),
        ),
        child: Column(
          children: [
            Text(label, style: AppDesign.bodySmall),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: AppDesign.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Conflict Detected: Selected halls already booked for this time.',
              style: AppDesign.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
