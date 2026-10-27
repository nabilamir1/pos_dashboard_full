import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mock_data.dart';

/// A premium receipt / invoice dialog that displays:
///  - Order item details
///  - Customer Name, Phone, Address
///  - Total Cost breakdown
///  - Store Phone for contact in case of errors
///
/// All data is mock — no backend involved.
class ReceiptDialog extends StatelessWidget {
  final List<MockCartLine> cartLines;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final String cashierName;
  final String terminalId;
  final double? tenderedAmount;
  final double? changeAmount;
  final String? customReceiptNo;
  final DateTime? customDate;

  const ReceiptDialog({
    Key? key,
    required this.cartLines,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.cashierName,
    required this.terminalId,
    this.tenderedAmount,
    this.changeAmount,
    this.customReceiptNo,
    this.customDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final receiptNo = customReceiptNo ??
        'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final dateStr = _formatDate(customDate ?? DateTime.now());

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Left: Thermal receipt ──────────────────────────────
          _buildThermalReceipt(receiptNo, dateStr),

          const SizedBox(width: 24),

          // ── Right: Digital summary card ───────────────────────
          _buildDigitalSummary(context, receiptNo, dateStr),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // THERMAL RECEIPT (left side)
  // ═════════════════════════════════════════════════════════════════
  Widget _buildThermalReceipt(String receiptNo, String dateStr) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Store name
          const Text(
            'CYBORG SUPERMARKET',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Ring Road, New Cairo, Egypt',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF475569),
            ),
          ),
          const Text(
            'Tel: +20 2 2345 6789',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF475569),
            ),
          ),

          _receiptDivider(),

          // Receipt info
          _receiptRow('Receipt #', receiptNo),
          _receiptRow('Date', dateStr),
          _receiptRow('Cashier', cashierName),
          _receiptRow('Terminal', terminalId),
          _receiptRow('Payment', paymentMethod),

          _receiptDivider(),

          // Column headers
          const Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('ITEM',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    )),
              ),
              Expanded(
                flex: 1,
                child: Text('QTY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    )),
              ),
              Expanded(
                flex: 2,
                child: Text('TOTAL',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Items
          ...cartLines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        line.nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${line.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${line.lineTotal.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          _receiptDivider(),

          // Totals
          _receiptRow('Subtotal', '${subtotal.toStringAsFixed(2)} EGP'),
          _receiptRow('VAT (14%)', '${tax.toStringAsFixed(2)} EGP'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} EGP',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          if (paymentMethod == 'CASH') ...[
            const SizedBox(height: 4),
            _receiptRow('Tendered',
                '${(tenderedAmount ?? total).toStringAsFixed(2)} EGP'),
            _receiptRow('Change Due',
                '${(changeAmount ?? 0.0).toStringAsFixed(2)} EGP'),
          ] else ...[
            const SizedBox(height: 4),
            _receiptRow('Payment Card', 'VISA **** 4242'),
            _receiptRow('Auth Code', 'AUTH-89210'),
          ],

          _receiptDivider(),

          // Footer
          const Text(
            'Thank you for shopping!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'For errors, call: +20 2 2345 6789',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),

          // Fake barcode
          _fakeBarcode(receiptNo),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // DIGITAL SUMMARY CARD (right side)
  // ═════════════════════════════════════════════════════════════════
  Widget _buildDigitalSummary(
      BuildContext context, String receiptNo, String dateStr) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(28),
      decoration: AppDecorations.glassCard(radius: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppGradients.emerald,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Complete',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sale processed successfully',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.success),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Big total
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emerald.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL PAID',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${total.toStringAsFixed(2)} EGP',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: paymentMethod == 'CASH'
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paymentMethod == 'CASH' ? '💵 Cash Payment' : '💳 Visa Payment',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: paymentMethod == 'CASH'
                          ? AppColors.success
                          : AppColors.cyan,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info rows
          _digitalInfoRow(Icons.receipt_outlined, 'Receipt #', receiptNo),
          _digitalInfoRow(Icons.calendar_today_outlined, 'Date & Time', dateStr),
          _digitalInfoRow(Icons.badge_outlined, 'Cashier', cashierName),
          _digitalInfoRow(Icons.point_of_sale_rounded, 'Terminal', terminalId),
          _digitalInfoRow(
              Icons.shopping_cart_outlined, 'Items', '${cartLines.length} products'),
          if (paymentMethod == 'CASH') ...[
            _digitalInfoRow(Icons.payments_outlined, 'Cash Tendered',
                '${(tenderedAmount ?? total).toStringAsFixed(2)} EGP'),
            _digitalInfoRow(Icons.change_circle_outlined, 'Change Given',
                '${(changeAmount ?? 0.0).toStringAsFixed(2)} EGP'),
          ] else ...[
            _digitalInfoRow(Icons.credit_card_rounded, 'Card Type', 'Visa Debit / Credit'),
            _digitalInfoRow(Icons.verified_outlined, 'Transaction', 'Approved (Auth #89210)'),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.print_rounded,
                                color: AppColors.emerald, size: 18),
                            const SizedBox(width: 10),
                            Text('Receipt #$receiptNo sent to thermal printer'),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    print('[RECEIPT] Print receipt: $receiptNo');
                  },
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('Print'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    print('[RECEIPT] New transaction started');
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      size: 18, color: AppColors.textOnAccent),
                  label: const Text('New Sale',
                      style: TextStyle(color: AppColors.textOnAccent)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Store contact footer
          Center(
            child: Text(
              'For issues, contact store: +20 2 2345 6789',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _receiptDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(
          40,
          (_) => const Expanded(
            child: Text(
              '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _digitalInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeBarcode(String code) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: code.codeUnits.take(14).map((b) {
            final w = (b % 3).toDouble() + 1.0;
            return Container(
              width: w,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: 0.8),
              color: const Color(0xFF0F172A),
            );
          }).toList(),
        ),
        const SizedBox(height: 2),
        Text(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year}  $h:$m';
  }
}
