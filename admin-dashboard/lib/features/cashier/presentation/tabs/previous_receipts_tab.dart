import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';

/// Previous Receipts Tab for Cashier Role.
/// Shows all receipts from PosStateManager.instance.unifiedReceipts.
/// Filter: All, In-Store, Online (COD).
/// Displays Customer Name, Phone, Email for online orders.
/// View receipt dialog with reprint option.
class PreviousReceiptsTab extends StatefulWidget {
  const PreviousReceiptsTab({super.key});

  @override
  State<PreviousReceiptsTab> createState() => _PreviousReceiptsTabState();
}

class _PreviousReceiptsTabState extends State<PreviousReceiptsTab> {
  String _filter = 'ALL'; // 'ALL', 'In-Store', 'Online'

  List<UnifiedReceiptRecord> _getFiltered(PosStateManager state) {
    final all = state.unifiedReceipts;
    if (_filter == 'ALL') return all;
    return all.where((r) => r.source == _filter).toList();
  }

  void _showReceiptDetail(UnifiedReceiptRecord receipt) {
    final isAr = AppController.instance.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan),
              const SizedBox(width: 10),
              Text(
                'Receipt: ${receipt.receiptNo}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: AppDecorations.badge(
                  color: receipt.isOnline ? AppColors.electricPurpleLight : AppColors.neonCyan,
                ),
                child: Text(
                  receipt.source,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: receipt.isOnline ? AppColors.electricPurpleLight : AppColors.neonCyan,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Metadata
                  _detailRow('Date', _formatDate(receipt.timestamp), isDark),
                  _detailRow('Cashier', receipt.cashierName, isDark),
                  _detailRow('Terminal', receipt.terminalId, isDark),
                  _detailRow('Payment', receipt.paymentMethod, isDark),
                  if (receipt.isOnline) ...[
                    Divider(color: isDark ? AppColors.border : const Color(0xFFCBD5E1), height: 20),
                    const Text(
                      'CUSTOMER DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.electricPurpleLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _detailRow('Name', receipt.customerName ?? '-', isDark),
                    _detailRow('Phone', receipt.customerPhone ?? '-', isDark),
                    _detailRow('Email', receipt.customerEmail ?? '-', isDark),
                    _detailRow('Address', receipt.customerAddress ?? '-', isDark),
                  ],
                  Divider(color: isDark ? AppColors.border : const Color(0xFFCBD5E1), height: 20),

                  // Items Table
                  Text(
                    'ITEMS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: [
                        // Header row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceLight : const Color(0xFFE2E8F0),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  '#  Product',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  'Qty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  'Price',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  'Total',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...receipt.items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? AppColors.border.withOpacity(0.5)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    '${idx + 1}. ${isAr ? item.nameAr : item.nameEn}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '${item.quantity}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    item.unitPrice.toStringAsFixed(2),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    item.lineTotal.toStringAsFixed(2),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Totals
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppDecorations.cyborgCard(
                      borderColor: AppColors.neonCyan,
                      glow: true,
                      isDark: isDark,
                    ),
                    child: Column(
                      children: [
                        _totalRow(context.tr('subtotal'), '${receipt.subtotal.toStringAsFixed(2)} EGP', isDark),
                        const SizedBox(height: 4),
                        _totalRow(context.tr('vat_tax'), '${receipt.tax.toStringAsFixed(2)} EGP', isDark),
                        Divider(
                          color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                          height: 16,
                        ),
                        _totalRow(context.tr('grand_total').toUpperCase(), '${receipt.total.toStringAsFixed(2)} EGP', isDark, isTotal: true),
                        if (receipt.tenderedAmount != null) ...[
                          const SizedBox(height: 6),
                          _totalRow('Tendered', '${receipt.tenderedAmount!.toStringAsFixed(2)} EGP', isDark),
                          _totalRow('Change', '${(receipt.changeAmount ?? 0).toStringAsFixed(2)} EGP', isDark),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.tr('close'),
                style: TextStyle(color: isDark ? AppColors.textMuted : const Color(0xFF64748B)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Receipt ${receipt.receiptNo} sent to printer.'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              },
              icon: const Icon(Icons.print_rounded, size: 16),
              label: Text(context.tr('reprint_receipt')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: AppColors.textOnCyan,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([state, AppController.instance]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final receipts = _getFiltered(state);
        final allCount = state.unifiedReceipts.length;
        final inStoreCount = state.unifiedReceipts.where((r) => r.source == 'In-Store').length;
        final onlineCount = state.unifiedReceipts.where((r) => r.source == 'Online').length;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Filter Bar & KPIs ──────────────────────────────
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL RECEIPTS',
                    value: '$allCount',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'IN-STORE',
                    value: '$inStoreCount',
                    icon: Icons.storefront_rounded,
                    color: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'ONLINE (COD)',
                    value: '$onlineCount',
                    icon: Icons.language_rounded,
                    color: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Tabs
              Row(
                children: [
                  _filterPill('ALL', '${context.tr('all')} ($allCount)', isDark),
                  const SizedBox(width: 8),
                  _filterPill('In-Store', 'In-Store ($inStoreCount)', isDark),
                  const SizedBox(width: 8),
                  _filterPill('Online', 'Online ($onlineCount)', isDark),
                ],
              ),
              const SizedBox(height: 16),

              // ── Receipts Table ─────────────────────────────────
              Expanded(
                child: receipts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 48,
                              color: AppColors.textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No receipts found',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: AppDecorations.cyborgCard(isDark: isDark),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 110,
                                    child: Text(
                                      'RECEIPT #',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'SOURCE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: Text(
                                      'DATE & TIME',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      context.tr('col_cashier'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      context.tr('payment_method').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      'ITEMS',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      context.tr('col_total'),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 60),
                                ],
                              ),
                            ),
                            // Table Rows
                            Expanded(
                              child: ListView.builder(
                                itemCount: receipts.length,
                                itemBuilder: (ctx, idx) {
                                  final r = receipts[idx];
                                  final isOnline = r.isOnline;
                                  return InkWell(
                                    onTap: () => _showReceiptDetail(r),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: isDark
                                                ? AppColors.border.withOpacity(0.4)
                                                : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 110,
                                            child: Text(
                                              r.receiptNo,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: AppDecorations.badge(
                                                  color: isOnline ? AppColors.electricPurpleLight : AppColors.neonCyan,
                                                ),
                                                child: Text(
                                                  r.source,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: isOnline ? AppColors.electricPurpleLight : AppColors.neonCyan,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 140,
                                            child: Text(
                                              _formatDate(r.timestamp),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              r.cashierName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Text(
                                              r.paymentMethod,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            child: Text(
                                              '${r.totalItemCount}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              '${r.total.toStringAsFixed(2)} EGP',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? AppColors.emerald : const Color(0xFF059669),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.chevron_right_rounded,
                                                color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: isTotal
                  ? (isDark ? AppColors.textWhite : const Color(0xFF0F172A))
                  : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: FontWeight.w900,
              color: isTotal
                  ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                  : (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill(String key, String label, bool isDark) {
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.neonCyan.withOpacity(0.15) : const Color(0xFF0098A6).withOpacity(0.12))
              : (isDark ? AppColors.surface : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
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
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.cyborgCard(isDark: isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} • ${dt.day}/${dt.month}';
  }
}
