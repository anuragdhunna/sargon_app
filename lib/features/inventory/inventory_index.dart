// Flutter & Material
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';

// Core
export 'package:hotel_manager/core/models/audit_log.dart';
export 'package:hotel_manager/core/services/audit_service.dart';
export 'package:hotel_manager/theme/app_design.dart';

// Components
export 'package:hotel_manager/component/badges/status_badge.dart';
export 'package:hotel_manager/component/states/empty_state.dart';
export 'package:hotel_manager/component/cards/app_card.dart';
export 'package:hotel_manager/component/cards/premium_info_card.dart';
export 'package:hotel_manager/component/inputs/app_text_field.dart';
export 'package:hotel_manager/component/inputs/premium_search_bar.dart';
export 'package:hotel_manager/component/buttons/premium_button.dart';
export 'package:hotel_manager/component/inputs/vendor_selection_dropdown.dart';
export 'package:hotel_manager/component/feedback/custom_snackbar.dart';

// Auth
export 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
export 'package:hotel_manager/features/auth/logic/auth_state.dart';

// Data
export 'package:hotel_manager/features/inventory/data/inventory_repository.dart';

// Stock Management
export 'package:hotel_manager/features/inventory/stock/data/inventory_model.dart';
export 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart';
export 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';

// Goods Receipt
export 'package:hotel_manager/features/inventory/goods_receipt/data/goods_receipt_model.dart';
export 'package:hotel_manager/features/inventory/goods_receipt/logic/goods_receipt_cubit.dart';
export 'package:hotel_manager/features/inventory/goods_receipt/logic/goods_receipt_state.dart';
export 'package:hotel_manager/features/inventory/goods_receipt/presentation/goods_receiving_screen.dart';
export 'package:hotel_manager/features/inventory/goods_receipt/presentation/grn_tracking_screen.dart';

// Purchase Orders
export 'package:hotel_manager/features/inventory/purchase_orders/data/purchase_order_model.dart';
export 'package:hotel_manager/features/inventory/purchase_orders/logic/purchase_order_cubit.dart';
export 'package:hotel_manager/features/inventory/purchase_orders/logic/purchase_order_state.dart';
export 'package:hotel_manager/features/inventory/purchase_orders/presentation/po_detail_screen.dart';
export 'package:hotel_manager/features/inventory/purchase_orders/presentation/purchase_orders_screen.dart';

// Vendors
export 'package:hotel_manager/features/inventory/vendors/data/vendor_model.dart';
export 'package:hotel_manager/features/inventory/vendors/logic/vendor_cubit.dart';
export 'package:hotel_manager/features/inventory/vendors/logic/vendor_state.dart';
export 'package:hotel_manager/features/inventory/vendors/presentation/widgets/create_vendor_dialog.dart';
export 'package:hotel_manager/features/inventory/vendors/presentation/vendor_payment_screen.dart';
