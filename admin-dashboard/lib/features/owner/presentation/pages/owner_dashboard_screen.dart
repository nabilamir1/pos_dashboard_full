import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/global_header_actions.dart';
import '../tabs/store_inventory_tab.dart';
import '../tabs/warehouse_inventory_tab.dart';
import '../tabs/comprehensive_financials_tab.dart';
import '../tabs/manager_management_tab.dart';
import '../tabs/global_staff_reports_tab.dart';
import '../tabs/capital_system_override_tab.dart';

/// Owner Master Dashboard
/// Hosts 6 dedicated executive workflows:
/// 1. Store Inventory Dashboard (read-only real-time shelf view)
/// 2. Warehouse Inventory Dashboard (read-only real-time warehouse view)
/// 3. Comprehensive Financials (total goods value, sales revenue, cash in drawer, profit margin, losses)
/// 4. Manager Management (add, edit, relieve Store Managers)
/// 5. Global Staff Daily Reports (all staff status + tailored Today's Report)
/// 6. Capital & System Override (base capital, bulk store & warehouse stock override)
class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const OwnerDashboardScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'key': 'tab_owner_store_inventory',
      'title': 'Store Inventory',
      'icon': Icons.storefront_rounded,
    },
    {
      'key': 'tab_owner_wh_inventory',
      'title': 'Warehouse Inventory',
      'icon': Icons.warehouse_rounded,
    },
    {
      'key': 'tab_owner_financials',
      'title': 'Comprehensive Financials',
      'icon': Icons.account_balance_rounded,
    },
    {
      'key': 'tab_owner_managers',
      'title': 'Manager Management',
      'icon': Icons.admin_panel_settings_rounded,
    },
    {
      'key': 'tab_owner_staff_reports',
      'title': 'Global Staff Daily Reports',
      'icon': Icons.badge_rounded,
    },
    {
      'key': 'tab_owner_override',
      'title': 'Capital & System Override',
      'icon': Icons.tune_rounded,
    },
  ];

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([AppController.instance, state]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF1F5F9),
          body: SafeArea(
            child: Column(
              children: [
                // Top Master Header
                _buildTopAppBar(context, isDark),

                // Tab Navigation Bar
                _buildCustomTabBar(state, isDark),

                // Tab Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: const [
                      StoreInventoryTab(),
                      WarehouseInventoryTab(),
                      ComprehensiveFinancialsTab(),
                      ManagerManagementTab(),
                      GlobalStaffReportsTab(),
                      CapitalSystemOverrideTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Executive Logo & Crown Badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.electricPurple,
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricPurple.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.tr('app_title'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.electricPurple.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.electricPurple.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      context.tr('owner_executive_suite'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.electricPurpleLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('owner_tagline'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textMuted : Colors.black54,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Owner Profile Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.electricPurple.withOpacity(0.15)
                  : AppColors.electricPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.electricPurple.withOpacity(0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.military_tech_rounded, size: 16, color: AppColors.electricPurpleLight),
                SizedBox(width: 8),
                Text(
                  'Dr. Nabil  •  Founder & Owner',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.electricPurpleLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Theme & Language Toggles
          const GlobalHeaderActions(compact: true),
          const SizedBox(width: 16),

          // Logout / Switch Role Button
          OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, size: 16),
            label: Text(context.tr('switch_role')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neonCyan,
              side: const BorderSide(color: AppColors.borderCyan),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(PosStateManager state, bool isDark) {
    final lowStockCount = state.products.where((p) => p.isLowStock).length;
    final lowWhCount = state.products.where((p) => p.isWarehouseLowStock).length;
    final totalStaff = state.employees.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : const Color(0xFFE2E8F0),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = _selectedIndex == index;

            // Badges
            int badgeCount = 0;
            Color badgeColor = AppColors.neonCyan;

            if (index == 0 && lowStockCount > 0) {
              badgeCount = lowStockCount;
              badgeColor = AppColors.amber;
            } else if (index == 1 && lowWhCount > 0) {
              badgeCount = lowWhCount;
              badgeColor = AppColors.rose;
            } else if (index == 4) {
              badgeCount = totalStaff;
              badgeColor = AppColors.emerald;
            }

            final tabTitle = tab['key'] != null ? context.tr(tab['key'] as String) : (tab['title'] as String);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                key: Key('owner_tab_$index'),
                onTap: () => _switchTab(index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.surface : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.electricPurpleLight
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.electricPurple.withOpacity(isDark ? 0.25 : 0.1),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 17,
                        color: isSelected
                            ? AppColors.electricPurpleLight
                            : (isDark ? AppColors.textMuted : Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tabTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.textWhite : const Color(0xFF0F172A))
                              : (isDark ? AppColors.textMuted : Colors.black54),
                        ),
                      ),
                      if (badgeCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
