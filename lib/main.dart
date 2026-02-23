import 'package:flutter/material.dart';
import 'package:hotel_manager/core/app/app_bootstrap.dart';
import 'package:hotel_manager/core/app/app_providers.dart';
import 'package:hotel_manager/core/app/app.dart';
import 'package:hotel_manager/core/navigation/app_router.dart';

void main() async {
  // Use bootstrap to initialize all services and core cubits
  final result = await AppBootstrap.bootstrap();

  // Create router with auth cubit for refresh
  final router = createRouter(result.authCubit);

  runApp(
    AppProviders(
      bootstrap: result,
      child: HotelManagerApp(router: router),
    ),
  );
}
