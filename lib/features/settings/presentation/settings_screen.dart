import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/cards/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: AppDesign.headlineSmall.copyWith(
          color: AppDesign.neutral900,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppDesign.neutral900),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SettingsNavCard(
              title: 'Menu Management',
              description: 'Manage menu items, prices, and recipes.',
              icon: Icons.restaurant_menu,
              color: Colors.orange,
              onTap: () => context.push('/settings/menu'),
            ),
            const SizedBox(height: 16),
            _SettingsNavCard(
              title: 'Tax & Service Charges',
              description: 'Configure GST rules and service charges.',
              icon: Icons.account_balance,
              color: Colors.blue,
              onTap: () => context.push('/settings/tax'),
            ),
            const SizedBox(height: 16),
            _SettingsNavCard(
              title: 'Table Management',
              description: 'Add, edit, or remove tables.',
              icon: Icons.table_restaurant,
              color: Colors.green,
              onTap: () => context.push('/settings/tables'),
            ),
            const SizedBox(height: 16),
            _SettingsNavCard(
              title: 'Analytics & Logs',
              description: 'View audit logs and configuration history.',
              icon: Icons.analytics,
              color: Colors.purple,
              onTap: () => context.push('/settings/analytics'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsNavCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SettingsNavCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesign.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppDesign.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppDesign.bodyMedium.copyWith(
                        color: AppDesign.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
