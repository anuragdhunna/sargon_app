import 'package:flutter/widgets.dart';
import 'package:hotel_manager/core/services/firebase_service.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/storage/secure_storage_service.dart';
import 'package:hotel_manager/core/services/session/session_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_cubit.dart';

/// Container for all initialized services and core cubits
class AppBootstrapResult {
  final AuthService authService;
  final DatabaseService databaseService;
  final SecureStorageService secureStorage;
  final SessionService sessionService;
  final AuthCubit authCubit;
  final ChecklistCubit checklistCubit;
  final TableCubit tableCubit;

  AppBootstrapResult({
    required this.authService,
    required this.databaseService,
    required this.secureStorage,
    required this.sessionService,
    required this.authCubit,
    required this.checklistCubit,
    required this.tableCubit,
  });
}

class AppBootstrap {
  /// Initializes all core services and returns an [AppBootstrapResult]
  static Future<AppBootstrapResult> bootstrap() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await FirebaseService.initialize();

    // Create core services
    final authService = AuthService();
    final databaseService = DatabaseService();

    // Enable offline persistence for mobile
    databaseService.enableOfflinePersistence();

    // Initialize Session Management
    final secureStorage = SecureStorageService();
    final sessionService = SessionService(storageService: secureStorage);
    await sessionService.initialize();

    // Initialize Auditing
    AuditService.init(databaseService, sessionService: sessionService);

    // Initialize Core Cubits
    final authCubit = AuthCubit(
      authService: authService,
      sessionService: sessionService,
    );
    final checklistCubit = ChecklistCubit(databaseService: databaseService);
    final tableCubit = TableCubit(databaseService: databaseService);

    return AppBootstrapResult(
      authService: authService,
      databaseService: databaseService,
      secureStorage: secureStorage,
      sessionService: sessionService,
      authCubit: authCubit,
      checklistCubit: checklistCubit,
      tableCubit: tableCubit,
    );
  }
}
