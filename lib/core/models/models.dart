/// Import this single file to access any model in the codebase.
/// Consolidated domain models for multi-tenancy support.
library;

// Base & Common
export 'base_entity.dart';
export 'audit_log.dart';
export 'payment_models.dart';
export 'app_settings_model.dart';
export 'hotel_model.dart';

// User & Auth
export 'user_model.dart';
export 'notification_model.dart';

// Dining & Restaurant (Consolidated)
export 'ordering_models.dart';
export 'restaurant_models.dart';
export 'recipe_model.dart';

// CRM & Promotions (Consolidated)
export 'crm_models.dart';
export 'promotion_models.dart';

// Billing
export 'billing_models.dart';

// Rooms & Bookings
export 'room_model.dart';
export 'booking_model.dart';

// Operations & Inventory
export 'inventory_models.dart';
export 'purchase_models.dart';
export 'operations_models.dart';
export 'hr_models.dart';

// Events
export 'event_models.dart';
