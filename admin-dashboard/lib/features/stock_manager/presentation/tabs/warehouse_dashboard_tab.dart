import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab 1: Warehouse Dashboard Tab
/// Complete overview of all inventory in the warehouse with KPI metrics,
/// category filters, live search, and warehouse stock status indicators.
class WarehouseDashboardTab extends StatefulWidget {
  const WarehouseDashboardTab({super.key});

  @override
  State<WarehouseDashboardTab> createState() => _WarehouseDashboardTabState();
}

class _WarehouseDashboardTabState extends State<WarehouseDashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'Beverages',
    'Dairy',
    'Bakery',
    'Fruits',
    'Meat',
    'Snacks',
    'Grocery',
    'Cleaning',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final allProducts = state.products;

        final query = _searchController.text.trim().toLowerCase();
        final filteredProducts = allProducts.where((p) {
          final matchesCategory = _selectedCategory == 'ALL' ||
              p.category.toLowerCase() == _selectedCategory.toLowerCase();
          final matchesQuery = query.isEmpty ||
              p.nameEn.toLowerCase().contains(query) ||
              p.nameAr.contains(query) ||
              p.barcode.contains(query) ||
              p.code.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        }).toList();

        final totalSkus = allProducts.length;
        final totalWarehouseUnits = allProducts.fold<int>(
            0, (acc, p) => acc + p.warehouseStock);
        final lowWarehouseCount = allProducts
            .where((p) => p.warehouseStock <= p.minWarehouseThreshold)
            .length;
        final outOfStockCount =
            allProducts.where((p) => p.warehouseStock <= 0).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top KPI Overview Cards ─────────────────────────────────────
              Row(
                children: [
                  _buildKpiCard(
                    title: 'TOTAL WAREHOUSE SKUS',
                    value: '$totalSkus SKUs',
                    subtitle: 'Catalog synchronized with POS',
                    icon: Icons.inventory_2_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildKpiCard(
                    title: 'TOTAL WAREHOUSE UNITS',
                    value: '$totalWarehouseUnits Units',
                    subtitle: 'Across all warehouse bays',
                    icon: Icons.layers_rounded,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildKpiCard(
                    title: 'LOW WAREHOUSE STOCK',
                    value: '$lowWarehouseCount Items',
                    subtitle: 'Requires supplier replenishment',
                    icon: Icons.warning_amber_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildKpiCard(
                    title: 'OUT OF STOCK (WH)',
                    value: '$outOfStockCount Items',
                    subtitle: 'Zero inventory in warehouse',
                    icon: Icons.error_outline_rounded,
                    accentColor: AppColors.rose,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Filter & Search Toolbar ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.cyborgCard(
                  radius: 14,
                  isDark: isDark,
                ),
                child: Row(
                  children: [
                    // Search bar
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          color: isDark ? AppColors.textWhite : Colors.black87,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by Product Name, Barcode, or SKU Code...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.textMuted
                                : Colors.black.withOpacity(0.4),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.neonCyan,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark
                              ? AppColors.surface
                              : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.neonCyan,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Category dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor:
                              isDark ? AppColors.card : Colors.white,
                          icon: const Icon(
                            Icons.filter_list_rounded,
                            color: AppColors.neonCyan,
                            size: 20,
                          ),
                          style: TextStyle(
                            color: isDark ? AppColors.textWhite : Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(
                                cat == 'ALL' ? 'All Categories' : cat,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Results counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neonCyan.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Showing ${filteredProducts.length} of $totalSkus',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Inventory Data Table ───────────────────────────────────────
              Container(
                decoration: AppDecorations.cyborgCard(
                  radius: 14,
                  isDark: isDark,
                ),
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
                        headingRowColor: MaterialStateProperty.all(
                          isDark
                              ? AppColors.surface
                              : const Color(0xFFF8FAFC),
                        ),
                        dataRowColor: MaterialStateProperty.all(
                          isDark ? AppColors.card : Colors.white,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('CODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('BARCODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('PRODUCT NAME (EN / AR)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('PRICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('STORE POS STOCK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('WH STOCK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('WH THRESHOLD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                          DataColumn(label: Text('WH STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                        ],
                        rows: filteredProducts.map((p) {
                          final isWhLow = p.warehouseStock <= p.minWarehouseThreshold;
                          final isWhOut = p.warehouseStock <= 0;

                          Color statusColor = AppColors.emerald;
                          String statusLabel = 'HEALTHY';
                          if (isWhOut) {
                            statusColor = AppColors.rose;
                            statusLabel = 'OUT OF STOCK';
                          } else if (isWhLow) {
                            statusColor = AppColors.amber;
                            statusLabel = 'LOW STOCK';
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Text(
                                    p.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: AppColors.neonCyan,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.barcode,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: isDark ? AppColors.textMuted : Colors.black54,
                                  ),
                                ),
                              ),
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
                                        color: isDark ? AppColors.textWhite : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      p.nameAr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSecondary : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricPurple.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.electricPurple.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    p.category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.electricPurpleLight,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${p.price.toStringAsFixed(2)} EGP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: isDark ? AppColors.textWhite : Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${p.stock} units',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: p.stock <= p.minThreshold
                                        ? AppColors.rose
                                        : (isDark ? AppColors.textSecondary : Colors.black54),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${p.warehouseStock} units',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: statusColor,
                                      ),
                                    ),
                                    if (isWhLow) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.priority_high_rounded,
                                        size: 14,
                                        color: statusColor,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '≤ ${p.minWarehouseThreshold} units',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textMuted : Colors.black45,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(isDark ? 0.12 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondary : Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
