import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/checklists/data/checklist_model.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';

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
  ChecklistCubit() : super(ChecklistInitial()) {
    loadChecklists();
  }

  final List<Checklist> _mockChecklists = [
    Checklist(
      id: '1',
      title: 'Morning Lobby Cleaning',
      description: 'Ensure the main lobby is spotless before guests wake up.',
      type: ChecklistType.housekeeping,
      status: ChecklistStatus.pending,
      assignedRole: UserRole.housekeeping,
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      items: const [
        ChecklistItem(id: '1', task: 'Vacuum Rugs'),
        ChecklistItem(id: '2', task: 'Polish Front Desk'),
        ChecklistItem(id: '3', task: 'Empty Trash Bins'),
      ],
    ),
    Checklist(
      id: '2',
      title: 'Pool pH Check',
      description: 'Verify chemical levels in the swimming pool.',
      type: ChecklistType.maintenance,
      status: ChecklistStatus.completed,
      assignedRole: UserRole.maintenance,
      dueDate: DateTime.now().subtract(const Duration(hours: 1)),
      items: const [
        ChecklistItem(id: '1', task: 'Check Chlorine', isCompleted: true),
        ChecklistItem(id: '2', task: 'Check pH', isCompleted: true),
      ],
    ),
  ];

  void loadChecklists() {
    emit(ChecklistLoaded(List.from(_mockChecklists)));
  }

  void addChecklist(Checklist checklist) {
    _mockChecklists.add(checklist);
    emit(ChecklistLoaded(List.from(_mockChecklists)));
  }

  void toggleItem(String checklistId, String itemId, {
    String? reason,
    required String userId,
    required String userName,
    required String userRole,
  }) {
    final currentState = state as ChecklistLoaded;
    final updatedChecklists = currentState.checklists.map((checklist) {
      if (checklist.id == checklistId) {
        final updatedItems = checklist.items.map((item) {
          if (item.id == itemId) {
            // Audit log for task completion
            AuditService().log(
              userId: userId,
              userName: userName,
              userRole: userRole,
              action: item.isCompleted ? AuditAction.update : AuditAction.complete,
              entity: 'checklist_item',
              entityId: itemId,
              description: 'Toggled checklist item: ${item.task}${reason != null ? ' (Reason: $reason)' : ''}',
              metadata: {
                'checklistId': checklistId,
                'reason': reason,
              },
            );
            return ChecklistItem(id: item.id, task: item.task, isCompleted: !item.isCompleted);
          }
          return item;
        }).toList();

        // Auto-update status if all items are done
        final allDone = updatedItems.every((i) => i.isCompleted);
        final newStatus = allDone ? ChecklistStatus.completed : ChecklistStatus.inProgress;

        return checklist.copyWith(items: updatedItems, status: newStatus);
      }
      return checklist;
    }).toList();
    emit(ChecklistLoaded(updatedChecklists));
  }

  void updateChecklist(Checklist updatedChecklist) {
    final index = _mockChecklists.indexWhere((c) => c.id == updatedChecklist.id);
    if (index != -1) {
      _mockChecklists[index] = updatedChecklist;
      emit(ChecklistLoaded(List.from(_mockChecklists)));
      
      // Audit log
      AuditService().log(
        userId: 'current_user_id',
        userName: 'Current User',
        userRole: 'manager',
        action: AuditAction.update,
        entity: 'checklist',
        entityId: updatedChecklist.id,
        description: 'Updated checklist: ${updatedChecklist.title}',
      );
    }
  }
  void createCleaningChecklist({required String roomId, required String roomNumber}) {
    final newChecklist = Checklist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Clean Room $roomNumber',
      description: 'Post-checkout cleaning for Room $roomNumber',
      type: ChecklistType.housekeeping,
      status: ChecklistStatus.pending,
      assignedRole: UserRole.housekeeping,
      dueDate: DateTime.now().add(const Duration(minutes: 45)), // 45 min SLA
      items: const [
        ChecklistItem(id: '1', task: 'Change Bed Linens'),
        ChecklistItem(id: '2', task: 'Vacuum Floor'),
        ChecklistItem(id: '3', task: 'Sanitize Bathroom'),
        ChecklistItem(id: '4', task: 'Restock Amenities'),
        ChecklistItem(id: '5', task: 'Check Minibar'),
      ],
    );
    
    addChecklist(newChecklist);
    
    // Audit log
    AuditService().log(
      userId: 'system',
      userName: 'System',
      userRole: 'system',
      action: AuditAction.create,
      entity: 'checklist',
      entityId: newChecklist.id,
      description: 'Auto-created cleaning task for Room $roomNumber',
      metadata: {'roomId': roomId},
    );
  }
}
