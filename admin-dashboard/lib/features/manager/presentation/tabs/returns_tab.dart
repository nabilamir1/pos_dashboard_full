import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab for Store Manager to scan returned products sold by cashiers
/// and save them as "Returned" records.
class ReturnsTab extends StatefulWidget {
  const ReturnsTab({Key? key}) : super(key: key);

  @override
  State<ReturnsTab> createState() => _ReturnsTabState();
}

class _ReturnsTabState extends State<ReturnsTab> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _receiptController = TextEditingController(text: 'REC-904121');
  String _selectedCashier = 'Ahmed Hassan (POS-01)';
  String _selectedReason = 'Customer Changed Mind';
  int _quantity = 1;
  LiveStoreProduct? _scannedProduct;
  String? _feedbackMessage;
  bool _isSuccessFeedback = false;
  String _searchFilter = '';

  final List<String> _cashierList = [
    'Ahmed Hassan (POS-01)',
    'Sara Ibrahim (POS-02)',
    'Mohamed Ali (POS-03)',
    'Layla Nour (Web Order)',
  ];

  final List<String> _reasons = [
    'Customer Changed Mind',
    'Defective Packaging / Seal',
    'Expired or Bad Quality',
    'Wrong Item Scanned at Register',
    'Customer Dissatisfied with Taste',
  ];

  @override
  void initState() {
    super.initState();
    // Default preview with popular product
    final state = PosStateManager.instance;
    if (state.products.isNotEmpty) {
      _scannedProduct = state.products.first;
      _barcodeController.text = _scannedProduct!.barcode;
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  void _onBarcodeChanged(String value) {
    final state = PosStateManager.instance;
    final found = state.findProductByBarcode(value.trim());
    setState(() {
      _scannedProduct = found;
      _feedbackMessage = null;
    });
  }

  void _selectProduct(LiveStoreProduct product) {
    setState(() {
      _scannedProduct = product;
      _barcodeController.text = product.barcode;
      _feedbackMessage = null;
    });
  }

  void _processReturn() {
    if (_scannedProduct == null) {
      setState(() {
        _feedbackMessage = 'Please scan or select a valid product first.';
        _isSuccessFeedback = false;
      });
      return;
    }

    final cashierClean = _selectedCashier.split(' (').first;
    final success = PosStateManager.instance.processReturn(
      barcode: _scannedProduct!.barcode,
      quantity: _quantity,
      reason: _selectedReason,
      cashierName: cashierClean,
      receiptNo: _receiptController.text.trim().isEmpty ? 'REC-MANUAL' : _receiptController.text.trim(),
    );

    if (success) {
      setState(() {
        _feedbackMessage =
            'Successfully logged return for "${_scannedProduct!.nameEn}" (${_quantity}x - ${(_scannedProduct!.price * _quantity).toStringAsFixed(2)} EGP). Saved as "Returned".';
        _isSuccessFeedback = true;
        _quantity = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Return processed: ${_scannedProduct!.nameEn} registered as Returned.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final returnsList = state.returns.where((r) {
          if (_searchFilter.isEmpty) return true;
          final q = _searchFilter.toLowerCase();
          return r.productName.toLowerCase().contains(q) ||
              r.productCode.toLowerCase().contains(q) ||
              r.barcode.contains(q) ||
              r.originalReceiptNo.toLowerCase().contains(q) ||
              r.originalCashier.toLowerCase().contains(q);
        }).toList();

        final totalRefundedToday = state.returns.fold<double>(0.0, (sum, r) => sum + r.refundAmount);
        final totalReturnedUnits = state.returns.fold<int>(0, (sum, r) => sum + r.quantity);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top KPI Summary Cards
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL RETURNS TODAY',
                    value: '${state.returns.length} Records',
                    subvalue: '$totalReturnedUnits items received',
                    icon: Icons.assignment_return_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'TOTAL REFUNDED AMOUNT',
                    value: '${totalRefundedToday.toStringAsFixed(2)} EGP',
                    subvalue: 'Audited against cashier tills',
                    icon: Icons.payments_outlined,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'STATUS',
                    value: 'Active Registry',
                    subvalue: 'Real-time synchronization',
                    icon: Icons.verified_user_outlined,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barcode Scanner & Return Registration Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppDecorations.cyborgCard(
                  radius: 16,
                  borderColor: AppColors.borderCyan,
                  glow: true,
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
                            color: AppColors.neonCyan.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.neonCyan, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan Returned Product (Sold by Cashier)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Scan barcode from customer receipt to register return and verify cashier sale',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Barcode input row with quick picker
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barcode text field
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PRODUCT BARCODE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _barcodeController,
                                onChanged: _onBarcodeChanged,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                                decoration: AppDecorations.searchField(
                                  hint: 'Enter or scan barcode (e.g. 6221033001012)',
                                  prefixIcon: Icons.barcode_reader,
                                  suffix: IconButton(
                                    icon: const Icon(Icons.search, color: AppColors.neonCyan),
                                    onPressed: () => _onBarcodeChanged(_barcodeController.text),
                                    tooltip: 'Lookup Product',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Receipt No field
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORIGINAL RECEIPT NO.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _receiptController,
                                style: const TextStyle(fontSize: 14),
                                decoration: AppDecorations.searchField(
                                  hint: 'e.g. REC-904121',
                                  prefixIcon: Icons.receipt_long,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Original Cashier dropdown
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SOLD BY CASHIER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _cashierList.contains(_selectedCashier) ? _selectedCashier : _cashierList.first,
                                    isExpanded: true,
                                    dropdownColor: AppColors.card,
                                    style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                    items: _cashierList.toSet().map((c) {
                                      return DropdownMenuItem(value: c, child: Text(c));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCashier = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick product picker bar
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const Text(
                          'Quick Barcode Demo:',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                        ...state.products.take(6).map((p) {
                          final isSelected = _scannedProduct?.barcode == p.barcode;
                          return InkWell(
                            onTap: () => _selectProduct(p),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.neonCyan.withOpacity(0.2) : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? AppColors.neonCyan : AppColors.border,
                                ),
                              ),
                              child: Text(
                                '${p.nameEn} (${p.price} EGP)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Scanned Product Details & Return Action Card
                    if (_scannedProduct != null) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppColors.neonCyan, size: 26),
                            ),
                            const SizedBox(width: 16),

                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _scannedProduct!.nameEn,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textWhite,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Text(
                                          _scannedProduct!.code,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_scannedProduct!.nameAr}  •  Unit Price: ${_scannedProduct!.price.toStringAsFixed(2)} EGP  •  Category: ${_scannedProduct!.category}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),

                            // Reason dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RETURN REASON',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _reasons.contains(_selectedReason) ? _selectedReason : _reasons.first,
                                      dropdownColor: AppColors.card,
                                      style: const TextStyle(color: AppColors.textWhite, fontSize: 12),
                                      items: _reasons.toSet().map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedReason = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // Quantity Stepper
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'QUANTITY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        color: AppColors.textWhite,
                                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                      ),
                                      Text(
                                        '$_quantity',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        color: AppColors.textWhite,
                                        onPressed: () => setState(() => _quantity++),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),

                            // Total refund & Action button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'REFUND AMOUNT',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.neonCyan),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(_scannedProduct!.price * _quantity).toStringAsFixed(2)} EGP',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neonCyan,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton.icon(
                                  onPressed: _processReturn,
                                  icon: const Icon(Icons.check_circle_outline, size: 16),
                                  label: const Text('SAVE AS "RETURNED"'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neonCyan,
                                    foregroundColor: AppColors.textOnCyan,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Feedback Message
                    if (_feedbackMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isSuccessFeedback
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isSuccessFeedback
                                ? AppColors.success.withOpacity(0.4)
                                : AppColors.error.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSuccessFeedback ? Icons.check_circle : Icons.error_outline,
                              size: 18,
                              color: _isSuccessFeedback ? AppColors.success : AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _feedbackMessage!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _isSuccessFeedback ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w600,
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
              const SizedBox(height: 32),

              // Returned Products History Table
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history_rounded, color: AppColors.neonCyan, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Returned Products Registry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                  // Search filter
                  SizedBox(
                    width: 280,
                    height: 38,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchFilter = val),
                      decoration: AppDecorations.searchField(
                        hint: 'Search returned records...',
                        prefixIcon: Icons.search,
                      ),
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
                    headingRowColor: WidgetStateProperty.all(isDark ? AppColors.surface : const Color(0xFFF8FAFC)),
                    dataRowColor: WidgetStateProperty.all(isDark ? AppColors.card : Colors.white),
                    headingTextStyle: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                    dataTextStyle: TextStyle(color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('RETURN ID', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('RECEIPT NO.', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('CASHIER', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('QTY', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('REFUND', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('REASON', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows: returnsList.map((r) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              r.returnId,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.neonCyan,
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
                                  r.productName,
                                  style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                                ),
                                Text(
                                  '${r.productCode} • ${r.barcode}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(r.originalReceiptNo, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(r.originalCashier, style: const TextStyle(fontSize: 12))),
                          DataCell(Text('${r.quantity}x', style: const TextStyle(fontWeight: FontWeight.w700))),
                          DataCell(
                            Text(
                              '${r.refundAmount.toStringAsFixed(2)} EGP',
                              style: const TextStyle(
                                color: AppColors.amber,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(r.reason, style: const TextStyle(fontSize: 11)),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppDecorations.badge(color: AppColors.neonCyan),
                              child: const Text(
                                'RETURNED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: AppColors.neonCyan,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subvalue,
    required IconData icon,
    required Color accentColor,
    bool isDark = true,
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
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : const Color(0xFF334155)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
