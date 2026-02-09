import 'package:equatable/equatable.dart';

/// Global application settings
class AppSettings extends Equatable {
  final bool requiresPOApproval;

  const AppSettings({this.requiresPOApproval = false});

  AppSettings copyWith({bool? requiresPOApproval}) {
    return AppSettings(
      requiresPOApproval: requiresPOApproval ?? this.requiresPOApproval,
    );
  }

  @override
  List<Object?> get props => [requiresPOApproval];

  Map<String, dynamic> toJson() {
    return {'requiresPOApproval': requiresPOApproval};
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      requiresPOApproval: json['requiresPOApproval'] as bool? ?? false,
    );
  }
}
