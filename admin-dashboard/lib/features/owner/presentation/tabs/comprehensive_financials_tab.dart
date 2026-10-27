import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';

/// Tab 3: Comprehensive Financials Tab
/// Complete financial metrics dashboard calculating data across the system:
/// - Total Cost / Value of Available Goods (Store + Warehouse)
/// - Total Sales Revenue (sum of all accepted offline & online receipts)
/// - Current Cash in Drawer (actual money collected from Cash & COD orders)
/// - Estimated Profit Margin (Revenue minus Cost of Goods Sold)
/// - Total Value of Refunded / Damaged Goods
class ComprehensiveFinancialsTab extends StatelessWidget {
  const ComprehensiveFinancialsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([state, AppController.instance]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Core Financial Metrics
        final storeValuation = state.totalStoreInventoryValue;
        final whValuation = state.totalWarehouseInventoryValue;
        final totalCombinedValuation = state.totalCombinedInventoryValue;
        final costOfGoodsAvailable = state.totalCostOfAvailableGoods;

        final totalRevenue = state.totalSalesRevenue;
        final inStoreRev = state.inStoreRevenue;
        final onlineRev = state.onlineCodRevenue;

        final cashCollected = state.totalCashInDrawer;
        final estProfit = state.estimatedGrossProfit;
        final marginPct = state.estimatedProfitMarginPct;

        final refundsVal = state.totalRefundAmount;
        final damagesVal = state.totalDamagedGoodsLoss;
        final totalLosses = state.totalLossesAndDamages;

        final totalTxCount = state.unifiedReceipts.length;

        // Payment Method Breakdown
        final cashTotal = state.unifiedReceipts
            .where((r) => r.paymentMethod == 'CASH')
            .fold(0.0, (acc, r) => acc + r.total);
        final visaTotal = state.unifiedReceipts
            .where((r) => r.paymentMethod == 'VISA')
            .fold(0.0, (acc, r) => acc + r.total);
        final codTotal = state.unifiedReceipts
            .where((r) => r.paymentMethod == 'COD')
            .fold(0.0, (acc, r) => acc + r.total);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Executive Financial Header ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFF0FDF4), Color(0xFFEFF6FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.emerald.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: AppColors.emerald, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Consolidated Financial Audit & P&L Analysis',
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
                                  color: AppColors.emerald.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
                                ),
                                child: Text(
                                  'EST. GROSS MARGIN: ${marginPct.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.emerald,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time automated reconciliation of cashier sales, COD driver cash returns, physical asset value, and stock loss write-offs.',
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

              // ── 5 Core Required Metrics (Row 1) ───────────────────────────
              Row(
                children: [
                  _buildPrimaryMetricCard(
                    title: 'TOTAL VALUE OF GOODS',
                    value: '${totalCombinedValuation.toStringAsFixed(2)} EGP',
                    subvalue: 'Store (${storeValuation.toStringAsFixed(0)}) + WH (${whValuation.toStringAsFixed(0)})',
                    extraNote: 'Cost: ~${costOfGoodsAvailable.toStringAsFixed(2)} EGP',
                    icon: Icons.inventory_2_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildPrimaryMetricCard(
                    title: 'TOTAL SALES REVENUE',
                    value: '${totalRevenue.toStringAsFixed(2)} EGP',
                    subvalue: '$totalTxCount Accepted Orders (POS & Web)',
                    extraNote: 'Store: ${inStoreRev.toStringAsFixed(0)} • Web: ${onlineRev.toStringAsFixed(0)}',
                    icon: Icons.monetization_on_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildPrimaryMetricCard(
                    title: 'CASH IN DRAWER & COD',
                    value: '${cashCollected.toStringAsFixed(2)} EGP',
                    subvalue: 'Collected Cash & Driver COD Tenders',
                    extraNote: 'Cash: ${cashTotal.toStringAsFixed(0)} • COD: ${codTotal.toStringAsFixed(0)}',
                    icon: Icons.point_of_sale_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildPrimaryMetricCard(
                    title: 'EST. GROSS PROFIT',
                    value: '${estProfit.toStringAsFixed(2)} EGP',
                    subvalue: 'Revenue minus Cost of Goods Sold',
                    extraNote: 'Margin: ${marginPct.toStringAsFixed(1)}% of Revenue',
                    icon: Icons.trending_up_rounded,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildPrimaryMetricCard(
                    title: 'REFUNDED & DAMAGED',
                    value: '${totalLosses.toStringAsFixed(2)} EGP',
                    subvalue: 'Loss write-offs & customer refunds',
                    extraNote: 'Refunds: ${refundsVal.toStringAsFixed(0)} • Damaged: ${damagesVal.toStringAsFixed(0)}',
                    icon: Icons.assignment_return_rounded,
                    accentColor: AppColors.rose,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Three-Column Deep Financial Breakdown ──────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: Sales Channel & Payment Split
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.pie_chart_rounded, color: AppColors.neonCyan, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Revenue Channels & Tenders',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('In-Store POS Lanes:', '${inStoreRev.toStringAsFixed(2)} EGP', AppColors.neonCyan, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Online Delivery (Web/App):', '${onlineRev.toStringAsFixed(2)} EGP', AppColors.amber, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Physical Cash Tendered:', '${cashTotal.toStringAsFixed(2)} EGP', AppColors.emerald, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Card / Electronic (Visa):', '${visaTotal.toStringAsFixed(2)} EGP', AppColors.electricPurpleLight, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Cash on Delivery (COD):', '${codTotal.toStringAsFixed(2)} EGP', AppColors.amber, isDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Column 2: Inventory Asset Distribution
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_tree_rounded, color: AppColors.electricPurpleLight, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Inventory Asset Valuation',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Store Front Shelf Valuation:', '${storeValuation.toStringAsFixed(2)} EGP', AppColors.neonCyan, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Central Warehouse Pallets:', '${whValuation.toStringAsFixed(2)} EGP', AppColors.electricPurpleLight, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Total Combined Retail Asset:', '${totalCombinedValuation.toStringAsFixed(2)} EGP', AppColors.emerald, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Estimated Wholesale Cost (COGS):', '${costOfGoodsAvailable.toStringAsFixed(2)} EGP', isDark ? AppColors.textSecondary : Colors.black87, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Inventory Gross Unrealized Markup:', '${(totalCombinedValuation - costOfGoodsAvailable).toStringAsFixed(2)} EGP', AppColors.emerald, isDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Column 3: Loss, Waste & Shrinkage Breakdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: AppColors.rose, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Losses, Refunds & Shrinkage',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Returned Merchandise (${state.returns.length} orders):', '-${refundsVal.toStringAsFixed(2)} EGP', AppColors.rose, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Damaged / Expired Goods (${state.damagedGoods.length} items):', '-${damagesVal.toStringAsFixed(2)} EGP', AppColors.rose, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Total Operational Loss Value:', '-${totalLosses.toStringAsFixed(2)} EGP', AppColors.rose, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Loss Percentage of Gross Revenue:', totalRevenue > 0 ? '${((totalLosses / totalRevenue) * 100).toStringAsFixed(2)}%' : '0.00%', AppColors.amber, isDark),
                          const Divider(height: 18),
                          _buildDetailRow('Active Cash Safe Surplus (Base Capital):', '${state.baseCapital.toStringAsFixed(2)} EGP', AppColors.neonCyan, isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Recent Transaction Receipts Log (Audit) ───────────────────
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Latest Cashier Receipts Included in Financial Revenue (${state.unifiedReceipts.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                        headingRowHeight: 46,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 56,
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                        ),
                        dataRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.card : Colors.white,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('RECEIPT NO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('SOURCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('CASHIER / TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('PAYMENT TENDER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('ITEMS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('SUBTOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('14% VAT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('TOTAL REVENUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('TIMESTAMP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        ],
                        rows: state.unifiedReceipts.map((r) {
                          final isOnline = r.source == 'Online';

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  r.receiptNo,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neonCyan,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? AppColors.amber.withOpacity(0.14)
                                        : AppColors.emerald.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    r.source,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: isOnline ? AppColors.amber : AppColors.emerald,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text('${r.cashierName} (${r.terminalId})', style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Text(
                                  r.paymentMethod,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.electricPurpleLight),
                                ),
                              ),
                              DataCell(Text('${r.totalItemCount} items', style: const TextStyle(fontSize: 12))),
                              DataCell(Text('${r.subtotal.toStringAsFixed(2)} EGP', style: const TextStyle(fontSize: 12))),
                              DataCell(Text('${r.tax.toStringAsFixed(2)} EGP', style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Text(
                                  '${r.total.toStringAsFixed(2)} EGP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.emerald,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${r.timestamp.hour.toString().padLeft(2, "0")}:${r.timestamp.minute.toString().padLeft(2, "0")}',
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
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

  Widget _buildDetailRow(String label, String value, Color valueColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildPrimaryMetricCard({
    required String title,
    required String value,
    required String subvalue,
    required String extraNote,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppDecorations.cyborgCard(
          radius: 14,
          borderColor: accentColor.withOpacity(0.5),
          glow: isDark,
          isDark: isDark,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subvalue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              extraNote,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
