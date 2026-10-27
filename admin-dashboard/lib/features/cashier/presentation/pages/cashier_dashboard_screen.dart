import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/global_header_actions.dart';
import '../tabs/online_orders_tab.dart';
import '../tabs/offline_pos_tab.dart';
import '../tabs/previous_receipts_tab.dart';

/// Main Cashier Role Dashboard screen hosting 3 tabs:
/// 1. Online Orders (COD management, accept/reject, scan, dispatch)
/// 2. In-Store POS (barcode scan, cart, checkout, receipt)
/// 3. Previous Receipts (history with filter and reprint)
class CashierDashboardScreen extends StatefulWidget {
  final String cashierName;
  final String terminalId;
  final String shiftId;
  final VoidCallback onLogout;

  const CashierDashboardScreen({
    super.key,
    required this.cashierName,
    required this.terminalId,
    required this.shiftId,
    required this.onLogout,
  });

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'key': 'tab_online_orders', 'icon': Icons.language_rounded},
    {'key': 'tab_instore_pos', 'icon': Icons.point_of_sale_rounded},
    {'key': 'tab_previous_receipts', 'icon': Icons.receipt_long_rounded},
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
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF1F5F9),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(isDark),
                _buildCustomTabBar(isDark),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const OnlineOrdersTab(),
                      OfflinePosTab(
                        cashierName: widget.cashierName,
                        terminalId: widget.terminalId,
                      ),
                      const PreviousReceiptsTab(),
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

  Widget _buildTopAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // CYBORG Brand
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppGradients.neonCyan,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.35),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: AppColors.textOnCyan, size: 22),
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
                      letterSpacing: 2,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('cashier_desk'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'POS REGISTER — ${widget.terminalId}  •  SHIFT: ${widget.shiftId}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                ),
              ),
            ],
          ),
          const Spacer(),

          // Cashier Profile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceLight : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.emerald,
                  child: Icon(Icons.person, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.cashierName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '•  ${context.tr('role_cashier')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 13, color: AppColors.emerald),
                const SizedBox(width: 6),
                Text(
                  'ROLE: ${context.tr('role_cashier').toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Theme & Language Toggles
          const GlobalHeaderActions(compact: true),
          const SizedBox(width: 16),

          // Switch Role
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

  Widget _buildCustomTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final idx = entry.key;
          final tab = entry.value;
          final isActive = _selectedIndex == idx;
          final title = context.tr(tab['key'] as String);

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => _switchTab(idx),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark
                          ? AppColors.neonCyan.withOpacity(0.12)
                          : const Color(0xFF0098A6).withOpacity(0.12))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? (isDark
                            ? AppColors.neonCyan.withOpacity(0.5)
                            : const Color(0xFF0098A6).withOpacity(0.5))
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 16,
                      color: isActive
                          ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                          : (isDark ? AppColors.textMuted : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isActive
                            ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                            : (isDark ? AppColors.textMuted : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
