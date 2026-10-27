import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/global_header_actions.dart';
import '../tabs/returns_tab.dart';
import '../tabs/damaged_goods_tab.dart';
import '../tabs/online_cashiers_tab.dart';
import '../tabs/employee_management_tab.dart';
import '../tabs/attendance_tab.dart';
import '../tabs/inventory_low_stock_tab.dart';
import '../tabs/stock_receiving_tab.dart';
import '../tabs/warehouse_requests_tab.dart';

/// Main Manager Role Dashboard screen hosting all 8 management tabs
/// including the Warehouse Requests authorization desk.
class ManagerDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ManagerDashboardScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'key': 'tab_returns',
      'icon': Icons.assignment_return_rounded,
    },
    {
      'key': 'tab_damaged',
      'icon': Icons.broken_image_outlined,
    },
    {
      'key': 'tab_online_cashiers',
      'icon': Icons.person_pin_circle_rounded,
    },
    {
      'key': 'tab_employees',
      'icon': Icons.badge_outlined,
    },
    {
      'key': 'tab_attendance',
      'icon': Icons.fingerprint_rounded,
    },
    {
      'key': 'tab_inventory',
      'icon': Icons.inventory_2_rounded,
    },
    {
      'key': 'tab_stock_receiving',
      'icon': Icons.local_shipping_rounded,
    },
    {
      'key': 'tab_warehouse_approvals',
      'icon': Icons.warehouse_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([AppController.instance, PosStateManager.instance]),
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
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      ReturnsTab(),
                      DamagedGoodsTab(),
                      OnlineCashiersTab(),
                      EmployeeManagementTab(),
                      AttendanceTab(),
                      InventoryLowStockTab(),
                      StockReceivingTab(),
                      WarehouseRequestsTab(),
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
          // Logo & Branding
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.neonCyan,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.35),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.storefront_rounded, color: AppColors.textOnCyan, size: 22),
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
                      letterSpacing: 1.5,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HELIOPOLIS BRANCH #01',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textSecondary : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('manager_desk'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.neonCyan,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Manager Profile Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceLight : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.neonCyan,
                  child: Icon(Icons.person, color: AppColors.textOnCyan, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tarek Mansour',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '• ${context.tr('role_manager')}',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Role Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonCyan.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, size: 13, color: AppColors.neonCyan),
                SizedBox(width: 6),
                Text(
                  'MANAGER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.neonCyan,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ── Theme & Language Toggles ───────────────────────────
          const GlobalHeaderActions(compact: true),
          const SizedBox(width: 16),

          // Logout / Switch Role Button
          OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: Text(context.tr('switch_role')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.rose,
              side: BorderSide(color: AppColors.rose.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(PosStateManager state, bool isDark) {
    final lowStockCount = state.products.where((p) => p.isLowStock).length;
    final lateAttendanceCount = state.attendanceLogs.where((a) => a.isLate).length;
    final pendingWarehouseRequests =
        state.warehouseRestockRequests.where((r) => r.status.contains('Awaiting')).length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = _selectedIndex == index;
            final title = context.tr(tab['key'] as String);

            // Dynamic Tab Badges
            Widget? badgeWidget;
            if (index == 4 && lateAttendanceCount > 0) {
              badgeWidget = _buildTabBadge('$lateAttendanceCount Late', AppColors.rose);
            } else if (index == 5 && lowStockCount > 0) {
              badgeWidget = _buildTabBadge('$lowStockCount Alert', AppColors.rose);
            } else if (index == 7 && pendingWarehouseRequests > 0) {
              badgeWidget = _buildTabBadge('$pendingWarehouseRequests New', AppColors.amber);
            }

            return InkWell(
              onTap: () => _switchTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.neonCyan : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? AppColors.neonCyan
                          : (isDark ? AppColors.textMuted : Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? (isDark ? AppColors.textWhite : const Color(0xFF0F172A))
                            : (isDark ? AppColors.textSecondary : Colors.black54),
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (badgeWidget != null) ...[
                      const SizedBox(width: 8),
                      badgeWidget,
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}
