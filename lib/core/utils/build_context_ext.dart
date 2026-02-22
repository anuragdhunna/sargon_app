import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/logic/auth_cubit.dart';
import '../../features/auth/logic/auth_state.dart';

extension AuthContextExtension on BuildContext {
  /// Internal helper to ensure auth is verified.
  AuthVerified _requireVerifiedAuth() {
    // Use read instead of watch to avoid InheritedWidget lifecycle errors
    // when accessed in initState or provider creation blocks.
    final state = read<AuthCubit>().state;

    if (state is AuthVerified) {
      return state;
    }

    throw FlutterError.fromParts([
      ErrorSummary('AuthContextExtension: Auth not verified'),
      ErrorDescription(
        'Tried to access authenticated user data '
        '(hotelId/userId) while AuthState is $state.',
      ),
      ErrorHint(
        'Ensure this widget is rendered only after authentication '
        'is completed or guard access using auth state checks.',
      ),
    ]);
  }

  /// REQUIRED hotelId — throws if unavailable.
  String get hotelId => _requireVerifiedAuth().hotelId;

  /// OPTIONAL hotelId — safe nullable access.
  String? get hotelIdOrNull {
    final state = read<AuthCubit>().state;
    return state is AuthVerified ? state.hotelId : null;
  }

  /// REQUIRED userId — throws if unavailable.
  String get userId => _requireVerifiedAuth().userId;

  /// OPTIONAL userId — safe nullable access.
  String? get userIdOrNull {
    final state = read<AuthCubit>().state;
    return state is AuthVerified ? state.userId : null;
  }
}
