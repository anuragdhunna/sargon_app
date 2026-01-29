import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/models/models.dart';

// States
abstract class ChecklistState extends Equatable {
  const ChecklistState();
  @override
  List<Object?> get props => [];
}

class ChecklistInitial extends ChecklistState {}

class ChecklistLoading extends ChecklistState {}

class ChecklistLoaded extends ChecklistState {
  final List<Checklist> checklists;
  const ChecklistLoaded(this.checklists);
  @override
  List<Object?> get props => [checklists];
}

// Cubit
class ChecklistCubit extends Cubit<ChecklistState> {
  final DatabaseService _databaseService;
  StreamSubscription? _checklistsSubscription;

  ChecklistCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(ChecklistInitial()) {
    loadChecklists();
  }

  void loadChecklists() {
    emit(ChecklistLoading());
    _checklistsSubscription?.cancel();
    _checklistsSubscription = _databaseService.streamChecklists().listen(
      (checklists) {
        emit(ChecklistLoaded(checklists));
      },
      onError: (error) {
        emit(ChecklistError(error.toString()));
      },
    );
  }

  Future<void> addChecklist(Checklist checklist) async {
    await _databaseService.saveChecklist(checklist);
  }

  Future<void> updateChecklist(Checklist checklist) async {
    await addChecklist(checklist);
  }

  Future<void> toggleItem(
    String checklistId,
    String itemId, {
    String? reason,
    required String userId,
    required String userName,
    required UserRole userRole,
  }) async {
    final currentState = state;
    if (currentState is! ChecklistLoaded) return;

    final checklist = currentState.checklists.firstWhere(
      (c) => c.id == checklistId,
    );
    final updatedItems = checklist.items.map((item) {
      if (item.id == itemId) {
        final isNowCompleted = !item.isCompleted;

        // Audit log for task completion
        AuditService().log(
          userId: userId,
          userName: userName,
          userRole: userRole.name,
          action: isNowCompleted ? AuditAction.complete : AuditAction.update,
          entity: 'checklist_item',
          entityId: itemId,
          description:
              '${isNowCompleted ? 'Completed' : 'Unchecked'} checklist item: ${item.task}${reason != null ? ' (Reason: $reason)' : ''}',
          metadata: {'checklistId': checklistId, 'reason': reason},
        );

        return item.copyWith(
          isCompleted: isNowCompleted,
          completedAt: isNowCompleted ? DateTime.now() : null,
          completedBy: isNowCompleted ? userName : null,
        );
      }
      return item;
    }).toList();

    // Auto-update status if all items are done
    final allDone = updatedItems.every((i) => i.isCompleted);
    final newStatus = allDone
        ? ChecklistStatus.completed
        : ChecklistStatus.inProgress;

    final updatedChecklist = checklist.copyWith(
      items: updatedItems,
      status: newStatus,
      lastModifiedAt: DateTime.now(),
      completedBy: allDone ? userName : null,
    );

    await _databaseService.saveChecklist(updatedChecklist);

    // If fully completed and it's a cleaning task, update the entity status
    if (allDone) {
      if (checklist.metadata != null) {
        final String? tableId = checklist.metadata!['tableId'];
        final String? roomId = checklist.metadata!['roomId'];
        if (tableId != null) {
          await _databaseService.updateTableStatus(
            tableId,
            TableStatus.available,
          );
        }
        if (roomId != null) {
          // Assuming room status update logic exists or we can mark it available
          // await _databaseService.updateRoomStatus(roomId, RoomStatus.available);
        }
      }
    }
  }

  Future<void> createCleaningChecklist({
    required String roomId,
    required String roomNumber,
  }) async {
    final newChecklist = Checklist(
      id: 'clean_room_${roomNumber}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Clean Room $roomNumber',
      description: 'Post-checkout cleaning for Room $roomNumber',
      type: ChecklistType.housekeeping,
      status: ChecklistStatus.pending,
      assignedRole: UserRole.housekeeping,
      dueDate: DateTime.now().add(const Duration(minutes: 45)),
      items: const [
        ChecklistItem(id: '1', task: 'Change Bed Linens'),
        ChecklistItem(id: '2', task: 'Vacuum Floor'),
        ChecklistItem(id: '3', task: 'Sanitize Bathroom'),
        ChecklistItem(id: '4', task: 'Restock Amenities'),
        ChecklistItem(id: '5', task: 'Check Minibar'),
      ],
      metadata: {'roomId': roomId},
    );

    await addChecklist(newChecklist);
  }

  Future<void> createTableCleaningChecklist({
    required String tableId,
    required String tableCode,
  }) async {
    final newChecklist = Checklist(
      id: 'clean_table_${tableCode}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cleaning Table $tableCode',
      description: 'Clean and sanitize Table $tableCode for new guests.',
      type: ChecklistType.housekeeping,
      status: ChecklistStatus.pending,
      assignedRole: UserRole.housekeeping,
      dueDate: DateTime.now().add(const Duration(minutes: 15)),
      items: const [
        ChecklistItem(id: '1', task: 'Clear dishes and leftovers'),
        ChecklistItem(id: '2', task: 'Sanitize table surface'),
        ChecklistItem(id: '3', task: 'Reset cutlery and napkins'),
        ChecklistItem(id: '4', task: 'Check chair/sofa for crumbs'),
      ],
      metadata: {'tableId': tableId},
    );

    await addChecklist(newChecklist);
  }

  @override
  Future<void> close() {
    _checklistsSubscription?.cancel();
    return super.close();
  }
}

// Error state
class ChecklistError extends ChecklistState {
  final String message;
  const ChecklistError(this.message);
  @override
  List<Object?> get props => [message];
}
