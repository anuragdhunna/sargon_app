import 'base_entity.dart';

/// Hotel Model for Multi-tenancy
class Hotel extends BaseEntity {
  final String name;
  final String address;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? taxId;
  final bool isChannelManagerEnabled;
  final Map<String, dynamic>? settings;

  const Hotel({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.email,
    this.website,
    this.logoUrl,
    this.taxId,
    this.isChannelManagerEnabled = false,
    this.settings,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    address,
    phoneNumber,
    email,
    website,
    logoUrl,
    taxId,
    isChannelManagerEnabled,
    settings,
  ];

  Hotel copyWith({
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    String? website,
    String? logoUrl,
    String? taxId,
    bool? isChannelManagerEnabled,
    Map<String, dynamic>? settings,
  }) {
    return Hotel(
      id: id,
      hotelId: hotelId,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      taxId: taxId ?? this.taxId,
      isChannelManagerEnabled:
          isChannelManagerEnabled ?? this.isChannelManagerEnabled,
      settings: settings ?? this.settings,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'taxId': taxId,
      'isChannelManagerEnabled': isChannelManagerEnabled,
      'settings': settings,
    };
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      taxId: json['taxId'] as String?,
      isChannelManagerEnabled:
          json['isChannelManagerEnabled'] as bool? ?? false,
      settings: json['settings'] as Map<String, dynamic>?,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
