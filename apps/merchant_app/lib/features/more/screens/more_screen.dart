import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import '../../products/providers/product_providers.dart';
import '../../suppliers/providers/supplier_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for badge counts
    final lowStockAsync = ref.watch(lowStockProductsProvider);
    final suppliersAsync = ref.watch(suppliersProvider);

    // Calculate badge counts
    int? lowStockCount;
    int? payableSuppliersCount;

    lowStockAsync.whenData((data) {
      final products = data['products'] as List?;
      lowStockCount = products?.length;
    });

    suppliersAsync.whenData((data) {
      final summary = data['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        payableSuppliersCount = summary['payableSuppliers'] as int?;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Business Management Section
          _SectionHeader(title: 'Business Management'),
          _FeatureListTile(
            icon: Icons.inventory_2,
            title: 'Inventory',
            subtitle: 'Manage products & stock',
            color: AppColors.info,
            badge: lowStockCount != null && lowStockCount! > 0
                ? '$lowStockCount Low'
                : null,
            badgeColor: AppColors.error,
            showNewTag: true,
            onTap: () => context.pushNamed('productList'),
          ),
          const Divider(height: 1, indent: 72),
          _FeatureListTile(
            icon: Icons.store,
            title: 'Suppliers',
            subtitle: 'Manage supplier accounts',
            color: AppColors.creditRed,
            badge: payableSuppliersCount != null && payableSuppliersCount! > 0
                ? '$payableSuppliersCount Due'
                : null,
            badgeColor: AppColors.creditRed,
            showNewTag: true,
            onTap: () => context.pushNamed('supplierList'),
          ),
          const Divider(height: 1, indent: 72),
          _FeatureListTile(
            icon: Icons.shopping_cart,
            title: 'Purchases',
            subtitle: 'Purchase history & records',
            color: AppColors.advanceYellow,
            showNewTag: true,
            onTap: () => context.pushNamed('purchaseList'),
          ),
          const Divider(height: 1, indent: 72),
          _FeatureListTile(
            icon: Icons.assessment,
            title: 'Advanced Reports',
            subtitle: 'Detailed analytics & insights',
            color: AppColors.debitGreen,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Advanced reports coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // System & Settings Section
          _SectionHeader(title: 'System & Settings'),
          _FeatureListTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Alerts & reminders',
            color: AppColors.primary,
            onTap: () => context.pushNamed('notifications'),
          ),
          const Divider(height: 1, indent: 72),
          _FeatureListTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences & configuration',
            color: AppColors.gray600,
            onTap: () => context.pushNamed('settings'),
          ),
          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'Fonepay Khata Book',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.gray600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FeatureListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final Color? badgeColor;
  final bool showNewTag;
  final VoidCallback onTap;

  const _FeatureListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    this.badgeColor,
    this.showNewTag = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showNewTag) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'NEW',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.gray600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: badgeColor ?? AppColors.error,
                  width: 1,
                ),
              ),
              child: Text(
                badge!,
                style: AppTypography.labelSmall.copyWith(
                  color: badgeColor ?? AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.chevron_right,
            color: AppColors.gray400,
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
