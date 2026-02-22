import 'base_entity.dart';

/// Global application settings per hotel
class AppSettings extends BaseEntity {
  final bool requiresPOApproval;

  const AppSettings({
    required super.id,
    required super.hotelId,
    this.requiresPOApproval = false,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  AppSettings copyWith({
    String? id,
    String? hotelId,
    bool? requiresPOApproval,
  }) {
    return AppSettings(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      requiresPOApproval: requiresPOApproval ?? this.requiresPOApproval,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  List<Object?> get props => [...super.props, requiresPOApproval];

  @override
  Map<String, dynamic> toJson() {
    return {...super.toAuditJson(), 'requiresPOApproval': requiresPOApproval};
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] as String? ?? 'global_settings',
      hotelId: json['hotelId'] as String,
      requiresPOApproval: json['requiresPOApproval'] as bool? ?? false,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
