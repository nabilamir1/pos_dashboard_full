import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';

/// In-Store POS Tab for Cashier Role.
/// Barcode input/scanner, autocomplete search, cart table (+/- qty, line totals),
/// subtotal, 14% VAT, total (EGP), Cash/Visa payment dialog, receipt generation.
class OfflinePosTab extends StatefulWidget {
  final String cashierName;
  final String terminalId;

  const OfflinePosTab({
    super.key,
    required this.cashierName,
    required this.terminalId,
  });

  @override
  State<OfflinePosTab> createState() => _OfflinePosTabState();
}

class _OfflinePosTabState extends State<OfflinePosTab> {
  final TextEditingController _barcodeCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();
  final List<MockCartLine> _cart = [];
  String? _feedbackMsg;
  bool _isSuccessFeedback = false;
  bool _showSearch = false;
  String _searchQuery = '';

  double get _subtotal => _cart.fold(0.0, (acc, l) => acc + l.lineTotal);
  double get _tax => _subtotal * 0.14;
  double get _total => _subtotal + _tax;

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _searchCtrl.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  void _addByBarcode(String barcode) {
    final state = PosStateManager.instance;
    final product = state.findProductByBarcode(barcode.trim());
    if (product == null) {
      setState(() {
        _feedbackMsg = 'Product not found for barcode: $barcode';
        _isSuccessFeedback = false;
      });
      return;
    }

    final existingIdx = _cart.indexWhere((l) => l.barcode == product.barcode);
    setState(() {
      if (existingIdx != -1) {
        _cart[existingIdx].quantity += 1;
      } else {
        _cart.add(MockCartLine(
          productId: product.id,
          barcode: product.barcode,
          nameEn: product.nameEn,
          nameAr: product.nameAr,
          quantity: 1,
          unitPrice: product.price,
        ));
      }
      _feedbackMsg = '✓ Added: ${product.nameEn} (${product.price.toStringAsFixed(2)} EGP)';
      _isSuccessFeedback = true;
      _barcodeCtrl.clear();
    });
    _barcodeFocus.requestFocus();
  }

  void _addProductFromSearch(LiveStoreProduct product) {
    final existingIdx = _cart.indexWhere((l) => l.barcode == product.barcode);
    setState(() {
      if (existingIdx != -1) {
        _cart[existingIdx].quantity += 1;
      } else {
        _cart.add(MockCartLine(
          productId: product.id,
          barcode: product.barcode,
          nameEn: product.nameEn,
          nameAr: product.nameAr,
          quantity: 1,
          unitPrice: product.price,
        ));
      }
      _feedbackMsg = '✓ Added: ${product.nameEn}';
      _isSuccessFeedback = true;
      _showSearch = false;
      _searchCtrl.clear();
      _searchQuery = '';
    });
  }

  void _updateQty(int index, int delta) {
    setState(() {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
    });
  }

  void _removeItem(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _feedbackMsg = null;
    });
  }

  void _showPaymentDialog() {
    if (_cart.isEmpty) return;

    String paymentMethod = 'CASH'; // 'CASH' or 'VISA'
    double tendered = (_total / 50).ceil() * 50.0;
    if (tendered < _total) tendered = _total;
    final tenderCtrl = TextEditingController(text: tendered.toStringAsFixed(0));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final change = tendered - _total;

            return AlertDialog(
              backgroundColor: isDark ? AppColors.card : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                  width: 1.5,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.point_of_sale_rounded, color: AppColors.emerald, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Checkout & Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Total Summary Box
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppGradients.cyborgPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TOTAL AMOUNT DUE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: AppColors.textOnCyan,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_total.toStringAsFixed(2)} EGP',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textOnCyan,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Subtotal: ${_subtotal.toStringAsFixed(2)} EGP  •  VAT (14%): ${_tax.toStringAsFixed(2)} EGP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textOnCyan.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Method Selector
                    Text(
                      'SELECT PAYMENT METHOD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _paymentMethodBtn(
                            'CASH',
                            Icons.payments_rounded,
                            paymentMethod == 'CASH',
                            AppColors.emerald,
                            () => setDialogState(() => paymentMethod = 'CASH'),
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _paymentMethodBtn(
                            'VISA / CARD',
                            Icons.credit_card_rounded,
                            paymentMethod == 'VISA',
                            AppColors.neonCyan,
                            () => setDialogState(() => paymentMethod = 'VISA'),
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Cash Tendered & Change Section
                    if (paymentMethod == 'CASH') ...[
                      Text(
                        'CASH TENDERED (EGP)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: tenderCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) {
                          final parsed = double.tryParse(val) ?? 0.0;
                          setDialogState(() => tendered = parsed);
                        },
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                        ),
                        decoration: AppDecorations.searchField(
                          hint: 'Enter cash received',
                          prefixIcon: Icons.attach_money_rounded,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: AppDecorations.badge(
                          color: change >= 0 ? AppColors.emerald : AppColors.rose,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              change >= 0 ? 'CHANGE DUE' : 'INSUFFICIENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: change >= 0 ? AppColors.emerald : AppColors.rose,
                              ),
                            ),
                            Text(
                              '${change.abs().toStringAsFixed(2)} EGP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: change >= 0 ? AppColors.emerald : AppColors.rose,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  onPressed: (paymentMethod == 'CASH' && change < 0)
                      ? null
                      : () {
                          PosStateManager.instance.recordInStoreReceipt(
                            items: _cart.map((l) => l.copy()).toList(),
                            subtotal: _subtotal,
                            tax: _tax,
                            total: _total,
                            paymentMethod: paymentMethod,
                            tendered: paymentMethod == 'CASH' ? tendered : null,
                            change: paymentMethod == 'CASH' ? change : null,
                            cashierName: widget.cashierName,
                            terminalId: widget.terminalId,
                          );
                          Navigator.pop(ctx);
                          setState(() {
                            _cart.clear();
                            _feedbackMsg = '✓ Transaction completed! Receipt printed.';
                            _isSuccessFeedback = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✓ Receipt generated! Payment: $paymentMethod — Total: ${_total.toStringAsFixed(2)} EGP',
                              ),
                              backgroundColor: AppColors.emerald,
                            ),
                          );
                        },
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text('COMPLETE & PRINT RECEIPT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
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
    final isAr = AppController.instance.isArabic;

    return AnimatedBuilder(
      animation: Listenable.merge([state, AppController.instance]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: Scanner & Product Lookup ─────────────────
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Barcode Scanner Input
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppDecorations.cyborgCard(
                        borderColor: AppColors.neonCyan,
                        glow: true,
                        isDark: isDark,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.qr_code_scanner_rounded, color: AppColors.neonCyan, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'SCAN / ENTER BARCODE',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _barcodeCtrl,
                                  focusNode: _barcodeFocus,
                                  autofocus: true,
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) _addByBarcode(val);
                                  },
                                  decoration: AppDecorations.searchField(
                                    hint: 'Scan barcode or type product code...',
                                    prefixIcon: Icons.barcode_reader,
                                    isDark: isDark,
                                    suffix: IconButton(
                                      icon: const Icon(Icons.add_circle, color: AppColors.neonCyan),
                                      onPressed: () {
                                        if (_barcodeCtrl.text.trim().isNotEmpty) {
                                          _addByBarcode(_barcodeCtrl.text);
                                        }
                                      },
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => setState(() => _showSearch = !_showSearch),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: AppDecorations.cyborgCard(
                                    borderColor: _showSearch
                                        ? AppColors.electricPurpleLight
                                        : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                    isDark: isDark,
                                  ),
                                  child: Icon(
                                    _showSearch ? Icons.close : Icons.search_rounded,
                                    color: _showSearch
                                        ? AppColors.electricPurpleLight
                                        : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_feedbackMsg != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: AppDecorations.badge(
                                color: _isSuccessFeedback ? AppColors.emerald : AppColors.rose,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isSuccessFeedback ? Icons.check_circle : Icons.error,
                                    size: 16,
                                    color: _isSuccessFeedback ? AppColors.emerald : AppColors.rose,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _feedbackMsg!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _isSuccessFeedback ? AppColors.emerald : AppColors.rose,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Add Demo Buttons
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: AppDecorations.cyborgCard(isDark: isDark),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'QUICK ADD (DEMO)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: state.products.take(8).map((p) {
                              return InkWell(
                                onTap: () => _addByBarcode(p.barcode),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: AppDecorations.badge(color: AppColors.neonCyan),
                                  child: Text(
                                    isAr ? p.nameAr : p.nameEn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Panel (conditional)
                    if (_showSearch)
                      Expanded(
                        child: Container(
                          decoration: AppDecorations.cyborgCard(
                            borderColor: AppColors.electricPurpleLight,
                            isDark: isDark,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (v) => setState(() => _searchQuery = v),
                                  style: TextStyle(
                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  ),
                                  decoration: AppDecorations.searchField(
                                    hint: 'Search by name, code, or category...',
                                    prefixIcon: Icons.search,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _filteredProducts(state).length,
                                  itemBuilder: (ctx, idx) {
                                    final p = _filteredProducts(state)[idx];
                                    return ListTile(
                                      dense: true,
                                      leading: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: AppDecorations.badge(color: AppColors.neonCyan),
                                        child: const Icon(Icons.inventory_2, size: 16, color: AppColors.neonCyan),
                                      ),
                                      title: Text(
                                        isAr ? p.nameAr : p.nameEn,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${p.code}  •  ${p.barcode}  •  Stock: ${p.stock}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                      trailing: Text(
                                        '${p.price.toStringAsFixed(2)} EGP',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.emerald,
                                          fontSize: 13,
                                        ),
                                      ),
                                      onTap: () => _addProductFromSearch(p),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // ── Right: Cart & Payment ──────────────────────────
              Expanded(
                flex: 4,
                child: Container(
                  decoration: AppDecorations.cyborgCard(
                    borderColor: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    isDark: isDark,
                  ),
                  child: Column(
                    children: [
                      // Cart Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart_rounded, color: AppColors.neonCyan, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'SHOPPING CART',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppDecorations.badge(color: AppColors.neonCyan),
                              child: Text(
                                '${_cart.length} items',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (_cart.isNotEmpty)
                              InkWell(
                                onTap: _clearCart,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: AppDecorations.badge(color: AppColors.rose),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete_outline, size: 14, color: AppColors.rose),
                                      SizedBox(width: 4),
                                      Text(
                                        'CLEAR',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.rose,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Cart Items Table
                      Expanded(
                        child: _cart.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 48,
                                      color: AppColors.textMuted.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Cart is empty',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Scan a barcode or search for products',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(10),
                                itemCount: _cart.length,
                                itemBuilder: (ctx, idx) {
                                  final line = _cart[idx];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surface : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Item #
                                        Container(
                                          width: 28,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.neonCyan.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${idx + 1}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Product Name
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isAr ? line.nameAr : line.nameEn,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                                ),
                                              ),
                                              Text(
                                                line.barcode,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Unit Price
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            line.unitPrice.toStringAsFixed(2),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                            ),
                                          ),
                                        ),

                                        // Qty Controls
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _qtyBtn(Icons.remove, () => _updateQty(idx, -1), isDark),
                                            Container(
                                              width: 36,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${line.quantity}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                            _qtyBtn(Icons.add, () => _updateQty(idx, 1), isDark),
                                          ],
                                        ),

                                        // Line Total
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            line.lineTotal.toStringAsFixed(2),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Remove
                                        InkWell(
                                          onTap: () => _removeItem(idx),
                                          borderRadius: BorderRadius.circular(6),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.close, size: 16, color: AppColors.rose),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      // ── Bottom: Totals & Pay Button ───────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                          border: Border(
                            top: BorderSide(
                              color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            _summaryRow(context.tr('subtotal'), '${_subtotal.toStringAsFixed(2)} EGP', isDark),
                            const SizedBox(height: 6),
                            _summaryRow(context.tr('vat_tax'), '${_tax.toStringAsFixed(2)} EGP', isDark),
                            Divider(
                              color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                              height: 20,
                            ),
                            _summaryRow(
                              context.tr('grand_total').toUpperCase(),
                              '${_total.toStringAsFixed(2)} EGP',
                              isDark,
                              isTotal: true,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _cart.isEmpty ? null : _showPaymentDialog,
                                icon: const Icon(Icons.payment_rounded, size: 20),
                                label: Text(
                                  _cart.isEmpty
                                      ? 'SCAN ITEMS TO BEGIN'
                                      : 'PAY ${_total.toStringAsFixed(2)} EGP',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _cart.isEmpty
                                      ? (isDark ? AppColors.surface : const Color(0xFFE2E8F0))
                                      : AppColors.neonCyan,
                                  foregroundColor: _cart.isEmpty
                                      ? AppColors.textMuted
                                      : AppColors.textOnCyan,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  List<LiveStoreProduct> _filteredProducts(PosStateManager state) {
    if (_searchQuery.isEmpty) return state.products;
    final q = _searchQuery.toLowerCase();
    return state.products.where((p) {
      return p.nameEn.toLowerCase().contains(q) ||
          p.nameAr.contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.barcode.contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }

  Widget _summaryRow(String label, String value, bool isDark, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal
                ? (isDark ? AppColors.textWhite : const Color(0xFF0F172A))
                : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
            letterSpacing: isTotal ? 1.0 : 0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.w900,
            color: isTotal
                ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                : (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceLight : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
          ),
        ),
        child: Icon(icon, size: 14, color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6)),
      ),
    );
  }

  Widget _paymentMethodBtn(
    String label,
    IconData icon,
    bool isSelected,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? AppColors.surface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textMuted, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? color
                    : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
