import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/localization/app_localizations.dart';

/// Tab for Store Manager to monitor total store products,
/// automatically flag "Low Stock" items, and send reorder requests to Stock Manager.
class InventoryLowStockTab extends StatefulWidget {
  const InventoryLowStockTab({Key? key}) : super(key: key);

  @override
  State<InventoryLowStockTab> createState() => _InventoryLowStockTabState();
}

class _InventoryLowStockTabState extends State<InventoryLowStockTab> {
  String _viewFilter = 'ALL'; // 'ALL', 'LOW_STOCK'
  String _selectedCategory = 'ALL';
  String _searchQuery = '';

  void _showReorderRequestDialog(BuildContext context, LiveStoreProduct product) {
    int requiredQuantity = 100;
    final qtyCtrl = TextEditingController(text: '100');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.card : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.neonCyan, width: 1.5),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.neonCyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Send Reorder Request to Stock Manager',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Summary Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                product.nameEn,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.card : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  product.code,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Barcode: ${product.barcode}  •  Category: ${product.category}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Current POS Stock: ${product.stock} units',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.rose,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '(Threshold: ${product.minThreshold})',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Required Quantity Input
                    Text(
                      'REQUIRED REORDER QUANTITY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          requiredQuantity = parsed;
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                      decoration: AppDecorations.searchField(
                        hint: 'Enter quantity (e.g. 100)',
                        prefixIcon: Icons.production_quantity_limits,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Workflow notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(isDark ? 0.08 : 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.neonCyan.withOpacity(isDark ? 0.2 : 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.neonCyan),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dispatches reorder request with status "Pending Approval/Denial". Stock Manager can approve or deny in warehouse console.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    ctx.tr('cancel'),
                    style: TextStyle(color: isDark ? AppColors.textMuted : const Color(0xFF64748B)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final success = PosStateManager.instance.sendStockReorderRequest(
                      barcode: product.barcode,
                      requiredQuantity: requiredQuantity,
                      requestedBy: 'Manager Tarek Mansour',
                    );
                    if (success) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reorder request for "${product.nameEn}" (${requiredQuantity}x) sent! Status: "Pending Approval/Denial".',
                          ),
                          backgroundColor: AppColors.neonCyanDark,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('SEND REQUEST TO STOCK MANAGER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.textOnCyan,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final totalProducts = state.products.length;
        final lowStockItems = state.products.where((p) => p.isLowStock).toList();
        final lowStockCount = lowStockItems.length;
        final pendingRequests =
            state.reorderRequests.where((r) => r.status.contains('Pending')).length;

        final categories = ['ALL', ...state.products.map((p) => p.category).toSet().toList()..sort()];

        final filteredProducts = state.products.where((p) {
          if (_viewFilter == 'LOW_STOCK' && !p.isLowStock) return false;
          if (_selectedCategory != 'ALL' && p.category != _selectedCategory) return false;
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            return p.nameEn.toLowerCase().contains(q) ||
                p.nameAr.contains(q) ||
                p.code.toLowerCase().contains(q) ||
                p.barcode.contains(q);
          }
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top KPI Summary Cards
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL CATALOG PRODUCTS',
                    value: '$totalProducts SKUs',
                    subvalue: 'Tracked in Store POS Database',
                    icon: Icons.inventory_2_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'LOW STOCK ALERTS',
                    value: '$lowStockCount Items Below Threshold',
                    subvalue: 'Requires immediate warehouse restock',
                    icon: Icons.warning_amber_rounded,
                    accentColor: AppColors.rose,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'REORDER REQUESTS PENDING',
                    value: '$pendingRequests Awaiting Approval',
                    subvalue: 'Status: Pending Approval/Denial',
                    icon: Icons.schedule_send_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Bar & Search
              Row(
                children: [
                  _buildFilterPill('ALL', '${context.tr('all')} ($totalProducts)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('LOW_STOCK', '⚠️ ${context.tr('low_stock')} ($lowStockCount)', isDark),
                  const SizedBox(width: 16),

                  // Category dropdown
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: categories.contains(_selectedCategory) ? _selectedCategory : categories.first,
                        dropdownColor: isDark ? AppColors.card : Colors.white,
                        style: TextStyle(
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          fontSize: 13,
                        ),
                        items: categories.toSet().map((cat) {
                          return DropdownMenuItem(value: cat, child: Text('Category: $cat'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Search field
                  SizedBox(
                    width: 280,
                    height: 42,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        fontSize: 13,
                      ),
                      decoration: AppDecorations.searchField(
                        hint: 'Search products by name/code...',
                        prefixIcon: Icons.search,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Store Inventory Table
              Container(
                decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith<Color>((states) {
                      return isDark ? AppColors.card : Colors.white;
                    }),
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: Text(context.tr('col_code'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_product'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_category'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_price'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_store_stock'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_status'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_actions'), style: const TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows: filteredProducts.map((p) {
                      final isLow = p.isLowStock;
                      // Check if already requested
                      final hasPendingRequest = state.reorderRequests.any(
                        (r) => r.productBarcode == p.barcode && r.status == 'Pending Approval/Denial',
                      );

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              p.code,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                fontWeight: FontWeight.w700,
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
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '${p.nameAr} • ${p.barcode}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              p.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                              ),
                            ),
                          ),
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
                              '${p.stock} units',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isLow ? AppColors.rose : AppColors.emerald,
                              ),
                            ),
                          ),
                          DataCell(
                            isLow
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: AppDecorations.badge(color: AppColors.rose),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.rose),
                                        const SizedBox(width: 4),
                                        Text(
                                          context.tr('low_stock'),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                            color: AppColors.rose,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: AppDecorations.badge(color: AppColors.emerald),
                                    child: Text(
                                      context.tr('healthy'),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: AppColors.emerald,
                                      ),
                                    ),
                                  ),
                          ),
                          DataCell(
                            hasPendingRequest
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: AppDecorations.badge(color: AppColors.amber),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.hourglass_empty_rounded, size: 13, color: AppColors.amber),
                                        const SizedBox(width: 6),
                                        Text(
                                          context.tr('pending').toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                            color: AppColors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : isLow
                                    ? ElevatedButton.icon(
                                        onPressed: () => _showReorderRequestDialog(context, p),
                                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                                        label: const Text('REQUEST STOCK'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.neonCyan,
                                          foregroundColor: AppColors.textOnCyan,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                        ),
                                      )
                                    : OutlinedButton(
                                        onPressed: () => _showReorderRequestDialog(context, p),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          side: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                          foregroundColor: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                        ),
                                        child: const Text('REORDER', style: TextStyle(fontSize: 11)),
                                      ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Reorder Requests Track Record Section
              Row(
                children: [
                  const Icon(Icons.mark_email_read_rounded, color: AppColors.neonCyan, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Dispatched Stock Reorder Requests (Status: Pending Approval/Denial)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                    ),
                    dataRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.card : Colors.white,
                    ),
                    columnSpacing: 24,
                    columns: [
                      DataColumn(label: Text(context.tr('col_req_id'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_product'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_store_stock'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_qty'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: const Text('REQUESTED BY', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_status'), style: const TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows: state.reorderRequests.map((req) {
                      final isPending = req.status.contains('Pending');
                      final isApproved = req.status == 'Approved';
                      final color = isPending
                          ? AppColors.amber
                          : isApproved
                              ? AppColors.emerald
                              : AppColors.rose;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              req.requestId,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  req.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '${req.productCode} • Barcode: ${req.productBarcode}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text('${req.currentStock} units', style: const TextStyle(color: AppColors.rose))),
                          DataCell(
                            Text(
                              '+${req.requiredQuantity} units',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              req.requestedBy,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppDecorations.badge(color: color),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPending
                                        ? Icons.hourglass_top_rounded
                                        : isApproved
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                    size: 13,
                                    color: color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    req.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: color,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(String key, String label, bool isDark) {
    final isSelected = _viewFilter == key;
    return InkWell(
      onTap: () => setState(() => _viewFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withOpacity(0.18)
              : (isDark ? AppColors.surface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan
                : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
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
        padding: const EdgeInsets.all(20),
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
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
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
                  subvalue,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
