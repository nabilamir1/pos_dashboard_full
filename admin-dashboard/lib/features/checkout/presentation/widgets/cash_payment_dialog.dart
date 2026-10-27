import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Cash Payment handling dialog.
///
/// Shows the total amount, a tendered field with quick-select denominations,
/// and computes the change due. Purely UI — no backend.
class CashPaymentDialog extends StatefulWidget {
  final double totalAmount;

  /// Called when the cashier confirms the cash payment.
  final void Function(double tendered, double change) onConfirm;

  const CashPaymentDialog({
    Key? key,
    required this.totalAmount,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<CashPaymentDialog> {
  final _tenderedController = TextEditingController();
  double _tendered = 0;

  // Egyptian pound denominations
  static const List<double> _denominations = [
    10, 20, 50, 100, 200, 500, 1000
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with exact amount rounded up to nearest 10
    final rounded =
        (widget.totalAmount / 10).ceil() * 10.0;
    _tenderedController.text = rounded.toStringAsFixed(0);
    _tendered = rounded;
  }

  @override
  void dispose() {
    _tenderedController.dispose();
    super.dispose();
  }

  double get _change => (_tendered - widget.totalAmount).clamp(0, double.infinity);
  bool get _isValid => _tendered >= widget.totalAmount;

  void _setTendered(double value) {
    setState(() {
      _tendered = value;
      _tenderedController.text = value.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        decoration: AppDecorations.glassCard(radius: 20),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppGradients.emerald,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payments_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Enter the amount tendered by customer',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textMuted),
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

            // ── Total due ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'AMOUNT DUE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.totalAmount.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.sky,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tendered input ──────────────────────────────────
            const Text(
              'AMOUNT TENDERED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tenderedController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('EGP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      )),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 50, minHeight: 0),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isValid ? AppColors.emerald : AppColors.error,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isValid ? AppColors.emerald : AppColors.error,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _tendered = double.tryParse(val) ?? 0;
                });
              },
            ),

            const SizedBox(height: 14),

            // ── Quick denominations ─────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                // Exact amount button
                _denomButton(
                  label: 'Exact',
                  value: widget.totalAmount,
                  isExact: true,
                ),
                ..._denominations
                    .where((d) => d >= widget.totalAmount * 0.3)
                    .map((d) => _denomButton(label: '${d.toInt()}', value: d)),
              ],
            ),

            const SizedBox(height: 20),

            // ── Change display ──────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isValid
                    ? AppColors.success.withOpacity(0.08)
                    : AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isValid
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.error.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _isValid ? 'CHANGE DUE' : 'INSUFFICIENT AMOUNT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: _isValid ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isValid
                        ? '${_change.toStringAsFixed(2)} EGP'
                        : '${(widget.totalAmount - _tendered).toStringAsFixed(2)} EGP short',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _isValid ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Confirm button ──────────────────────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isValid
                    ? () {
                        final tendered = _tendered;
                        final change = _change;
                        Navigator.pop(context);
                        widget.onConfirm(tendered, change);
                        print(
                            '[CASH PAYMENT] Tendered: $tendered EGP · Change: ${change.toStringAsFixed(2)} EGP');
                      }
                    : null,
                icon: const Icon(Icons.check_circle_rounded,
                    size: 22, color: AppColors.textOnAccent),
                label: const Text(
                  'CONFIRM CASH PAYMENT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.textOnAccent,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  disabledBackgroundColor: AppColors.emerald.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _denomButton(
      {required String label, required double value, bool isExact = false}) {
    final selected = (_tendered - value).abs() < 0.01;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _setTendered(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.emerald.withOpacity(0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.emerald : AppColors.border,
            ),
          ),
          child: Text(
            isExact ? '⚡ Exact' : '$label EGP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
                  selected ? AppColors.emerald : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
