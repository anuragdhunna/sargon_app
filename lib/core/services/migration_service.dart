import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Migration version tracking
///
/// Each migration is identified by a version number and a description.
/// Migrations are run in order on first app launch after an update.
class Migration {
  final int version;
  final String description;
  final Future<void> Function(DatabaseReference db) migrate;

  const Migration({
    required this.version,
    required this.description,
    required this.migrate,
  });
}

/// Migration service for handling schema changes
///
/// This service tracks which migrations have been run and executes
/// any pending migrations on app startup.
class MigrationService {
  final DatabaseReference _migrationsRef;
  final DatabaseReference _rootRef;

  MigrationService({
    DatabaseReference? migrationsRef,
    DatabaseReference? rootRef,
  }) : _migrationsRef =
           migrationsRef ?? FirebaseDatabase.instance.ref('_migrations'),
       _rootRef = rootRef ?? FirebaseDatabase.instance.ref();

  /// Current schema version
  static const int currentSchemaVersion = 1;

  /// List of all migrations
  ///
  /// Add new migrations here when model schemas change.
  /// Each migration should:
  /// 1. Have a unique version number (incrementing)
  /// 2. Have a clear description
  /// 3. Handle both old and new data formats gracefully
  /// 4. Be idempotent (safe to run multiple times)
  static final List<Migration> _migrations = [
    Migration(
      version: 1,
      description: 'Initial schema - add schemaVersion to all records',
      migrate: _migrationV1,
    ),
    // Add future migrations here:
    // Migration(
    //   version: 2,
    //   description: 'Add email field to users',
    //   migrate: _migrationV2,
    // ),
  ];

  /// Run all pending migrations
  Future<void> runMigrations() async {
    try {
      final lastVersion = await _getLastMigrationVersion();
      final pendingMigrations =
          _migrations.where((m) => m.version > lastVersion).toList()
            ..sort((a, b) => a.version.compareTo(b.version));

      if (pendingMigrations.isEmpty) {
        debugPrint('✅ No pending migrations');
        return;
      }

      debugPrint('📦 Running ${pendingMigrations.length} migration(s)...');

      for (final migration in pendingMigrations) {
        debugPrint('  ➡️ V${migration.version}: ${migration.description}');

        try {
          await migration.migrate(_rootRef);
          await _saveMigrationVersion(migration.version);
          debugPrint('  ✅ V${migration.version} completed');
        } catch (e) {
          debugPrint('  ❌ V${migration.version} failed: $e');
          // In production, you might want to handle this differently
          // (e.g., retry, rollback, or alert)
          rethrow;
        }
      }

      debugPrint('✅ All migrations completed');
    } catch (e) {
      debugPrint('❌ Migration error: $e');
      rethrow;
    }
  }

  /// Get the last completed migration version
  Future<int> _getLastMigrationVersion() async {
    try {
      final snapshot = await _migrationsRef.child('lastVersion').get();
      if (!snapshot.exists) return 0;
      return snapshot.value as int? ?? 0;
    } catch (e) {
      debugPrint('⚠️ Could not get last migration version: $e');
      return 0;
    }
  }

  /// Save the completed migration version
  Future<void> _saveMigrationVersion(int version) async {
    await _migrationsRef.update({
      'lastVersion': version,
      'lastRunAt': DateTime.now().toIso8601String(),
    });
  }

  /// Check if migrations are needed
  Future<bool> hasPendingMigrations() async {
    final lastVersion = await _getLastMigrationVersion();
    return _migrations.any((m) => m.version > lastVersion);
  }

  // =========================================================================
  // MIGRATION IMPLEMENTATIONS
  // =========================================================================

  /// Migration V1: Add schemaVersion to all existing records
  static Future<void> _migrationV1(DatabaseReference db) async {
    // This migration adds _schemaVersion field to all existing records
    // It's safe to run multiple times as it only adds if missing

    final collections = [
      'users',
      'orders',
      'rooms',
      'bookings',
      'inventory',
      'vendors',
      'purchaseOrders',
      'goodsReceipts',
      'checklists',
      'incidents',
      'menuItems',
    ];

    for (final collection in collections) {
      final snapshot = await db.child(collection).get();
      if (!snapshot.exists) continue;

      final data = snapshot.value;
      if (data is! Map) continue;

      final updates = <String, dynamic>{};

      for (final entry in data.entries) {
        final key = entry.key.toString();
        final value = entry.value;

        if (value is Map && !value.containsKey('_schemaVersion')) {
          updates['$collection/$key/_schemaVersion'] = 1;
        }
      }

      if (updates.isNotEmpty) {
        await db.update(updates);
        debugPrint('    Updated ${updates.length} records in $collection');
      }
    }
  }

  // Example future migration:
  // static Future<void> _migrationV2(DatabaseReference db) async {
  //   // Example: Add default email to users without email
  //   final usersSnapshot = await db.child('users').get();
  //   if (!usersSnapshot.exists) return;
  //
  //   final users = Map<String, dynamic>.from(usersSnapshot.value as Map);
  //   final updates = <String, dynamic>{};
  //
  //   for (final entry in users.entries) {
  //     final userData = Map<String, dynamic>.from(entry.value as Map);
  //     if (!userData.containsKey('email')) {
  //       updates['users/${entry.key}/email'] = null;
  //       updates['users/${entry.key}/_schemaVersion'] = 2;
  //     }
  //   }
  //
  //   if (updates.isNotEmpty) {
  //     await db.update(updates);
  //   }
  // }
}

/// Migration helper for transforming data
class MigrationHelper {
  /// Safely get a value from a map with a default
  static T getValue<T>(Map<String, dynamic> data, String key, T defaultValue) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is T) return value;

    // Handle type conversions
    if (T == double && value is num) return value.toDouble() as T;
    if (T == int && value is num) return value.toInt() as T;
    if (T == String) return value.toString() as T;

    return defaultValue;
  }

  /// Transform enum values (handle renamed/removed enums)
  static T transformEnum<T>(
    String? value,
    List<T> values,
    Map<String, T>? renames,
    T defaultValue,
  ) {
    if (value == null) return defaultValue;

    // Check for renamed values first
    if (renames != null && renames.containsKey(value)) {
      return renames[value]!;
    }

    // Try to find by name
    try {
      return values.firstWhere(
        (v) => (v as dynamic).name == value,
        orElse: () => defaultValue,
      );
    } catch (e) {
      return defaultValue;
    }
  }
}
