import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';

/// Tab 2: Warehouse Inventory Dashboard Tab
/// A read-only, real-time view of all products and quantities currently
/// located in the central Warehouse (fetching data from the Stock Manager state).
class WarehouseInventoryTab extends StatefulWidget {
  const WarehouseInventoryTab({Key? key}) : super(key: key);

  @override
  State<WarehouseInventoryTab> createState() => _WarehouseInventoryTabState();
}

class _WarehouseInventoryTabState extends State<WarehouseInventoryTab> {
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  String _statusFilter = 'ALL';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([state, AppController.instance]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Categories list
        final categories = <String>{'ALL', ...state.products.map((p) => p.category)};

        // Filter products
        final filteredProducts = state.products.where((p) {
          final query = _searchQuery.toLowerCase();
          final matchesSearch = query.isEmpty ||
              p.nameEn.toLowerCase().contains(query) ||
              p.nameAr.contains(query) ||
              p.barcode.contains(query) ||
              p.code.toLowerCase().contains(query);

          final matchesCategory =
              _selectedCategory == 'ALL' || p.category == _selectedCategory;

          bool matchesStatus = true;
          if (_statusFilter == 'HEALTHY') matchesStatus = !p.isWarehouseLowStock && p.warehouseStock > 0;
          if (_statusFilter == 'LOW') matchesStatus = p.isWarehouseLowStock && p.warehouseStock > 0;
          if (_statusFilter == 'OUT') matchesStatus = p.warehouseStock <= 0;

          return matchesSearch && matchesCategory && matchesStatus;
        }).toList();

        final totalSkus = state.products.length;
        final totalWhUnits = state.totalWarehouseStockUnits;
        final totalWhValuation = state.totalWarehouseInventoryValue;
        final lowWhCount = state.products.where((p) => p.isWarehouseLowStock).length;
        final outWhCount = state.products.where((p) => p.warehouseStock <= 0).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Executive Header Banner ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFF5F3FF), Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.electricPurple.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warehouse_rounded, color: AppColors.electricPurpleLight, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Central Warehouse Inventory (Reserve Pallets Live View)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.electricPurple.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.electricPurple.withOpacity(0.4)),
                                ),
                                child: const Text(
                                  'CENTRAL LOGISTICS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.electricPurpleLight,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Central distribution stock levels maintained across warehouse bays, incoming vendor pallets, and store transfers.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── KPI Summary Cards ─────────────────────────────────────────
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL WAREHOUSE SKUS',
                    value: '$totalSkus SKUs',
                    subvalue: 'Catalogued in central logistics',
                    icon: Icons.inventory_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'RESERVE UNITS IN BAYS',
                    value: '$totalWhUnits Units',
                    subvalue: 'Inbound warehouse stock',
                    icon: Icons.layers_rounded,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'WAREHOUSE RESERVE VALUE',
                    value: '${totalWhValuation.toStringAsFixed(2)} EGP',
                    subvalue: 'Total reserve asset valuation',
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'LOW IN WAREHOUSE',
                    value: '$lowWhCount Low  •  $outWhCount Depleted',
                    subvalue: 'Requires vendor PO requisition',
                    icon: Icons.warning_rounded,
                    accentColor: lowWhCount > 0 ? AppColors.amber : AppColors.emerald,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Search & Filter Controls ──────────────────────────────────
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: TextStyle(color: isDark ? AppColors.textWhite : const Color(0xFF0F172A), fontSize: 13),
                      decoration: AppDecorations.searchField(
                        hint: 'Search warehouse products by name, barcode or SKU code...',
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Category Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: isDark ? AppColors.card : Colors.white,
                        style: TextStyle(
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat == 'ALL' ? 'All Categories' : cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Status Filter Pills
                  _buildFilterPill('ALL', 'All (${state.products.length})', isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('HEALTHY', 'Healthy (${state.products.length - lowWhCount})', isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('LOW', 'Low WH ($lowWhCount)', isDark, color: AppColors.amber),
                  const SizedBox(width: 8),
                  _buildFilterPill('OUT', 'Depleted ($outWhCount)', isDark, color: AppColors.rose),
                ],
              ),
              const SizedBox(height: 20),

              // ── Products Data Table ───────────────────────────────────────
              Container(
                decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: DataTable(
                        headingRowHeight: 48,
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 64,
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                        ),
                        dataRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.card : Colors.white,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('CODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('BARCODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('PRODUCT NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('UNIT PRICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('WH RESERVE STOCK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('WH SAFE MIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('RESERVE VALUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('WH STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        ],
                        rows: filteredProducts.map((p) {
                          Color statusColor = AppColors.emerald;
                          String statusText = 'HEALTHY';
                          if (p.warehouseStock <= 0) {
                            statusColor = AppColors.rose;
                            statusText = 'DEPLETED';
                          } else if (p.isWarehouseLowStock) {
                            statusColor = AppColors.amber;
                            statusText = 'LOW STOCK';
                          }

                          final reserveValue = p.warehouseStock * p.price;

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.code,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.electricPurpleLight,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(p.barcode, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      p.nameEn,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      p.nameAr,
                                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(p.category, style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Text(
                                  '${p.price.toStringAsFixed(2)} EGP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${p.warehouseStock} units',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: p.isWarehouseLowStock ? AppColors.rose : AppColors.emerald,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text('≤ ${p.minWarehouseThreshold}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : Colors.black54)),
                              ),
                              DataCell(
                                Text(
                                  '${reserveValue.toStringAsFixed(2)} EGP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.electricPurpleLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: statusColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(String key, String label, bool isDark, {Color? color}) {
    final isSelected = _statusFilter == key;
    final accent = color ?? AppColors.electricPurpleLight;

    return InkWell(
      onTap: () => setState(() => _statusFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(isDark ? 0.22 : 0.14)
              : (isDark ? AppColors.surface : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? accent
                : (isDark ? AppColors.textSecondary : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subvalue,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subvalue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondary : Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
