import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

part 'database/database_users.dart';
part 'database/database_orders.dart';
part 'database/database_rooms.dart';
part 'database/database_inventory.dart';
part 'database/database_checklists.dart';
part 'database/database_incidents.dart';
part 'database/database_menu.dart';
part 'database/database_customers.dart';
part 'database/database_tables.dart';
part 'database/database_billing.dart';
part 'database/database_audit.dart';
part 'database/database_utils.dart';

/// Firebase Realtime Database service
///
/// Provides CRUD operations and real-time listeners for all data collections.
/// Now broken down into part files for better maintainability.
class DatabaseService {
  final FirebaseDatabase _database;

  DatabaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Get database reference for a path
  DatabaseReference _ref(String path) => _database.ref(path);
}
