import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/localization/app_localizations.dart';

/// Tab for Store Manager to monitor active online cashiers,
/// view live sales performance, and inspect the FULL details of every receipt
/// exactly as the Cashier sees it (items, quantities, unit prices, VAT, totals).
class OnlineCashiersTab extends StatefulWidget {
  const OnlineCashiersTab({super.key});

  @override
  State<OnlineCashiersTab> createState() => _OnlineCashiersTabState();
}

class _OnlineCashiersTabState extends State<OnlineCashiersTab> {
  OnlineCashierStats? _selectedCashier;

  @override
  void initState() {
    super.initState();
    final state = PosStateManager.instance;
    if (state.onlineCashiers.isNotEmpty) {
      _selectedCashier = state.onlineCashiers.first;
    }
  }

  void _inspectCashier(OnlineCashierStats cashier) {
    setState(() => _selectedCashier = cashier);
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  void _showFullReceiptModal(BuildContext context, UnifiedReceiptRecord receipt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ctx.tr('receipt_title'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${receipt.receiptNo}  •  ${receipt.source}',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.neonCyan),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Header Information Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: [
                        _receiptMetaRow('Timestamp:', receipt.timestamp.toString().substring(0, 19), isDark),
                        const SizedBox(height: 4),
                        _receiptMetaRow('Cashier:', receipt.cashierName, isDark),
                        const SizedBox(height: 4),
                        _receiptMetaRow('Register Terminal:', receipt.terminalId, isDark),
                        const SizedBox(height: 4),
                        _receiptMetaRow('Payment Method:', receipt.paymentMethod, isDark, isHighlight: true),
                        if (receipt.customerName != null) ...[
                          const Divider(height: 12),
                          _receiptMetaRow('Customer:', '${receipt.customerName} (${receipt.customerPhone ?? ""})', isDark),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Itemized Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceLight : const Color(0xFFE2E8F0),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 4, child: Text('ITEM / PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
                        SizedBox(width: 50, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
                        SizedBox(width: 75, child: Text('PRICE', textAlign: TextAlign.end, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
                        SizedBox(width: 85, child: Text('TOTAL', textAlign: TextAlign.end, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
                      ],
                    ),
                  ),

                  // Itemized Rows
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                      border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: receipt.items.map((line) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: isDark ? AppColors.border : const Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.nameEn,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      '${line.nameAr} • ${line.barcode}',
                                      style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMuted : Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  '${line.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  '${line.unitPrice.toStringAsFixed(2)} EGP',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : Colors.black87),
                                ),
                              ),
                              SizedBox(
                                width: 85,
                                child: Text(
                                  '${line.lineTotal.toStringAsFixed(2)} EGP',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.neonCyan),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Financial Totals
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(ctx.tr('subtotal'), '${receipt.subtotal.toStringAsFixed(2)} EGP', isDark),
                        const SizedBox(height: 6),
                        _summaryRow(ctx.tr('vat_tax'), '${receipt.tax.toStringAsFixed(2)} EGP', isDark),
                        const Divider(height: 14),
                        _summaryRow(ctx.tr('grand_total'), '${receipt.total.toStringAsFixed(2)} EGP', isDark, isTotal: true),
                        if (receipt.paymentMethod == 'CASH' && receipt.tenderedAmount != null) ...[
                          const SizedBox(height: 6),
                          _summaryRow(ctx.tr('cash_paid'), '${receipt.tenderedAmount!.toStringAsFixed(2)} EGP', isDark),
                          const SizedBox(height: 4),
                          _summaryRow(ctx.tr('change_due'), '${(receipt.changeAmount ?? 0.0).toStringAsFixed(2)} EGP', isDark, color: AppColors.emerald),
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
              child: Text(ctx.tr('close'), style: const TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Duplicate receipt ${receipt.receiptNo} sent to thermal printer.'),
                    backgroundColor: AppColors.neonCyan,
                  ),
                );
              },
              icon: const Icon(Icons.print_rounded, size: 16),
              label: Text(ctx.tr('reprint_receipt')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _receiptMetaRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isHighlight ? AppColors.neonCyan : (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String val, bool isDark, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: isTotal ? 16 : 12,
            fontWeight: FontWeight.w900,
            color: color ?? (isTotal ? AppColors.neonCyan : (isDark ? AppColors.textWhite : const Color(0xFF0F172A))),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final totalStoreSales =
            state.onlineCashiers.fold<double>(0.0, (acc, c) => acc + c.totalSales);
        final totalStoreTransactions =
            state.onlineCashiers.fold<int>(0, (acc, c) => acc + c.transactionCount);
        final totalActiveCashiers =
            state.onlineCashiers.where((c) => c.status != 'Offline').length;

        final cashier = _selectedCashier ?? (state.onlineCashiers.isNotEmpty ? state.onlineCashiers.first : null);
        final cashierReceipts = cashier != null
            ? state.getReceiptsForCashier(cashier.name, cashier.terminalId)
            : <UnifiedReceiptRecord>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Shift Overview Cards
              Row(
                children: [
                  _buildMetricCard(
                    title: context.tr('kpi_active_cashiers'),
                    value: '$totalActiveCashiers Working',
                    subvalue: '4 Terminals Synchronized',
                    icon: Icons.person_pin_circle_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: context.tr('kpi_total_sales'),
                    value: '${totalStoreSales.toStringAsFixed(2)} EGP',
                    subvalue: 'Today across all active lanes',
                    icon: Icons.monetization_on_outlined,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: context.tr('kpi_transactions'),
                    value: '$totalStoreTransactions Completed',
                    subvalue: 'Avg Basket: ${(totalStoreTransactions == 0 ? 0 : totalStoreSales / totalStoreTransactions).toStringAsFixed(2)} EGP',
                    icon: Icons.receipt_long_rounded,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Split View: Active Cashiers Grid (Left) + Selected Cashier Live Sales (Right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Active Cashiers List
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.point_of_sale_rounded, color: AppColors.neonCyan, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Active Cashier Lanes & Terminals',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Click any cashier to view real-time sales performance, transactions & itemized receipts',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // Cashier Cards
                        ...state.onlineCashiers.map((c) {
                          final isSelected = _selectedCashier?.cashierId == c.cashierId;
                          final isOnline = c.status == 'Active' || c.status == 'In Transaction';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: AppDecorations.cyborgCard(
                              radius: 14,
                              borderColor: isSelected ? AppColors.neonCyan : null,
                              glow: isSelected,
                              isDark: isDark,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () => _inspectCashier(c),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar with live status pulse
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                            child: Icon(
                                              Icons.person_rounded,
                                              color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.textSecondary : Colors.black54),
                                              size: 26,
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: isOnline ? AppColors.emerald : AppColors.amber,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isDark ? AppColors.card : Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),

                                      // Cashier details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  c.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                                  ),
                                                  child: Text(
                                                    c.terminalId,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.neonCyan,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Shift: ${_formatDuration(c.shiftDuration)}  •  ${c.transactionCount} receipts',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? AppColors.textMuted : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Sales revenue badge
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${c.totalSales.toStringAsFixed(2)} EGP',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isOnline ? AppColors.emerald.withOpacity(0.12) : AppColors.amber.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              c.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                color: isOnline ? AppColors.emerald : AppColors.amber,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Right: Selected Cashier Live Sales & Full Detailed Receipts Stream
                  Expanded(
                    flex: 6,
                    child: cashier == null
                        ? Container()
                        : Container(
                            padding: const EdgeInsets.all(22),
                            decoration: AppDecorations.cyborgCard(
                              radius: 16,
                              borderColor: AppColors.neonCyan,
                              glow: true,
                              isDark: isDark,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cashier Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.neonCyan,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.analytics_rounded, color: AppColors.textOnCyan, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${cashier.name} — Live Performance & Receipts',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Terminal: ${cashier.terminalId}  •  Shift Active for ${_formatDuration(cashier.shiftDuration)}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.neonCyan, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('X-Report generated and sent to printer for ${cashier.name}.'),
                                            backgroundColor: AppColors.neonCyan,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.print_outlined, size: 14),
                                      label: const Text('X-REPORT'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.neonCyan,
                                        side: const BorderSide(color: AppColors.neonCyan),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // 4 Performance Metrics Tiles
                                Row(
                                  children: [
                                    _buildDetailMetricTile(
                                      label: 'TOTAL REVENUE',
                                      value: '${cashier.totalSales.toStringAsFixed(2)} EGP',
                                      color: AppColors.neonCyan,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildDetailMetricTile(
                                      label: 'CASH COLLECTED',
                                      value: '${cashier.cashSales.toStringAsFixed(2)} EGP',
                                      color: AppColors.emerald,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildDetailMetricTile(
                                      label: 'VISA / CARD TILL',
                                      value: '${cashier.visaSales.toStringAsFixed(2)} EGP',
                                      color: AppColors.electricPurpleLight,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildDetailMetricTile(
                                      label: 'AVG BASKET',
                                      value: '${cashier.averageBasketValue.toStringAsFixed(2)} EGP',
                                      color: AppColors.amber,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Full Receipt Feed Header
                                Row(
                                  children: [
                                    const Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Full Detailed Receipts Feed (${cashierReceipts.length} Recorded)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Complete itemized records displaying every product, quantity, unit price, VAT and line total exactly as issued to the customer.',
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : Colors.black54),
                                ),
                                const SizedBox(height: 14),

                                // Full Receipt Items Cards
                                if (cashierReceipts.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('No transactions recorded yet in this active shift.', style: TextStyle(color: AppColors.textMuted)),
                                  )
                                else
                                  ...cashierReceipts.map((receipt) {
                                    final isVisa = receipt.paymentMethod == 'VISA';

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                      ),
                                      child: ExpansionTile(
                                        initiallyExpanded: true,
                                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: (isVisa ? AppColors.electricPurple : AppColors.emerald).withOpacity(0.14),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            isVisa ? Icons.credit_card : Icons.payments_outlined,
                                            color: isVisa ? AppColors.electricPurpleLight : AppColors.emerald,
                                            size: 18,
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(
                                              receipt.receiptNo,
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                color: AppColors.neonCyan,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (isVisa ? AppColors.electricPurple : AppColors.emerald).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                receipt.paymentMethod,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  color: isVisa ? AppColors.electricPurpleLight : AppColors.emerald,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          '${receipt.items.length} items (${receipt.totalItemCount} units)  •  ${receipt.timestamp.toString().substring(11, 16)}',
                                          style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '+${receipt.total.toStringAsFixed(2)} EGP',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.neonCyan),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.neonCyan),
                                              tooltip: 'View Full Thermal Slip',
                                              onPressed: () => _showFullReceiptModal(context, receipt),
                                            ),
                                          ],
                                        ),
                                        children: [
                                          // Itemized Products Breakdown Table
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.card : Colors.white,
                                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'ITEMIZED PRODUCTS IN RECEIPT:',
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.neonCyan),
                                                ),
                                                const SizedBox(height: 6),
                                                ...receipt.items.map((item) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            '• ${item.nameEn} (${item.nameAr})',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${item.quantity}x @ ${item.unitPrice.toStringAsFixed(2)} EGP',
                                                          style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                                                        ),
                                                        const SizedBox(width: 14),
                                                        Text(
                                                          '= ${item.lineTotal.toStringAsFixed(2)} EGP',
                                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.neonCyan),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                                const Divider(height: 14),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Subtotal: ${receipt.subtotal.toStringAsFixed(2)} EGP  •  VAT (14%): ${receipt.tax.toStringAsFixed(2)} EGP',
                                                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                                                    ),
                                                    ElevatedButton.icon(
                                                      onPressed: () => _showFullReceiptModal(context, receipt),
                                                      icon: const Icon(Icons.receipt_rounded, size: 14),
                                                      label: const Text('FULL SLIP'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.neonCyan,
                                                        foregroundColor: Colors.black,
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailMetricTile({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withOpacity(0.35), width: 1.2),
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
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subvalue,
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : Colors.black45),
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
