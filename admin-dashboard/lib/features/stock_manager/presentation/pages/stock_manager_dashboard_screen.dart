import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/global_header_actions.dart';
import '../tabs/warehouse_dashboard_tab.dart';
import '../tabs/store_low_stock_requests_tab.dart';
import '../tabs/warehouse_low_stock_tab.dart';
import '../tabs/add_new_product_tab.dart';
import '../tabs/fulfill_store_requests_tab.dart';
import '../tabs/import_restock_tab.dart';
import '../tabs/audit_receipts_log_tab.dart';

/// Stock Manager Master Dashboard
/// Hosts 7 dedicated warehouse workflows:
/// 1. Warehouse Dashboard (overview of all inventory)
/// 2. Store Low Stock Requests (Manager reorder approvals/denials)
/// 3. Warehouse Low Stock (Request restock from Manager)
/// 4. Add New Product (Type/scan new barcode to warehouse)
/// 5. Fulfill Store Requests (Scan barcodes & log outbound delivery slip)
/// 6. Import/Restock (Inbound quantities entry)
/// 7. Audit & Receipts Log (History of all warehouse transactions)
class StockManagerDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const StockManagerDashboardScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<StockManagerDashboardScreen> createState() =>
      _StockManagerDashboardScreenState();
}

class _StockManagerDashboardScreenState
    extends State<StockManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'key': 'tab_wh_dashboard',
      'title': 'Warehouse Dashboard',
      'icon': Icons.warehouse_rounded,
    },
    {
      'key': 'tab_store_requests',
      'title': 'Store Low Stock Requests',
      'icon': Icons.assignment_late_rounded,
    },
    {
      'key': 'tab_wh_low_stock',
      'title': 'Warehouse Low Stock',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'key': 'tab_add_product',
      'title': 'Add New Product',
      'icon': Icons.add_box_rounded,
    },
    {
      'key': 'tab_fulfill_requests',
      'title': 'Fulfill Store Requests',
      'icon': Icons.local_shipping_rounded,
    },
    {
      'key': 'tab_import_restock',
      'title': 'Import / Restock',
      'icon': Icons.input_rounded,
    },
    {
      'key': 'tab_audit_log',
      'title': 'Audit & Receipts Log',
      'icon': Icons.receipt_long_rounded,
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
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      WarehouseDashboardTab(),
                      StoreLowStockRequestsTab(),
                      WarehouseLowStockTab(),
                      AddNewProductTab(),
                      FulfillStoreRequestsTab(),
                      ImportRestockTab(),
                      AuditReceiptsLogTab(),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.electricPurple,
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricPurple.withOpacity(0.35),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.warehouse_rounded, color: Colors.white, size: 22),
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
                      context.tr('warehouse_desk'),
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
                context.tr('system_tagline'),
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

          // Stock Manager Profile Badge
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
                Icon(Icons.shield, size: 14, color: AppColors.electricPurpleLight),
                SizedBox(width: 8),
                Text(
                  'Hossam El-Din  •  Stock Manager',
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

          // ── Theme & Language Toggles ─────────────────────────────
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
    final pendingReorders = state.reorderRequests
        .where((r) => r.status.contains('Pending'))
        .length;
    final lowWhItems = state.products
        .where((p) => p.warehouseStock <= p.minWarehouseThreshold)
        .length;
    final approvedToFulfill = state.reorderRequests
        .where((r) => r.status == 'Approved' && !r.isFulfilled)
        .length;

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

            // Compute dynamic badges for tabs
            int badgeCount = 0;
            Color badgeColor = AppColors.neonCyan;

            if (index == 1) {
              badgeCount = pendingReorders;
              badgeColor = AppColors.amber;
            } else if (index == 2) {
              badgeCount = lowWhItems;
              badgeColor = AppColors.rose;
            } else if (index == 4) {
              badgeCount = approvedToFulfill;
              badgeColor = AppColors.emerald;
            }

            final tabTitle = tab['key'] != null ? context.tr(tab['key'] as String) : (tab['title'] as String);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => _switchTab(index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
