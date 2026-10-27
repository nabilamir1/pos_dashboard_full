import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab for Store Manager to scan damaged goods,
/// log them, and automatically deduct them from the active POS system inventory.
class DamagedGoodsTab extends StatefulWidget {
  const DamagedGoodsTab({Key? key}) : super(key: key);

  @override
  State<DamagedGoodsTab> createState() => _DamagedGoodsTabState();
}

class _DamagedGoodsTabState extends State<DamagedGoodsTab> {
  final TextEditingController _barcodeController = TextEditingController();
  int _damageQuantity = 1;
  String _selectedReason = 'Bottle / Carton Leaking or Punctured';
  LiveStoreProduct? _scannedProduct;
  String? _feedbackMessage;
  bool _isSuccess = false;
  String _searchFilter = '';

  final List<String> _damageReasons = [
    'Bottle / Carton Leaking or Punctured',
    'Packaging Crushed During Restocking',
    'Customer Dropped in Shopping Aisle',
    'Seal Broken / Contaminated',
    'Expired / Past Sell-By Date',
    'Defective Manufacturer Batch',
  ];

  @override
  void initState() {
    super.initState();
    final state = PosStateManager.instance;
    if (state.products.isNotEmpty) {
      _selectProduct(state.products[10]); // Clorox Bleach
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _onBarcodeChanged(String barcode) {
    final state = PosStateManager.instance;
    final found = state.findProductByBarcode(barcode.trim());
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

  void _logDamagedGoods() {
    if (_scannedProduct == null) {
      setState(() {
        _feedbackMessage = 'Please scan or select a valid product.';
        _isSuccess = false;
      });
      return;
    }

    if (_scannedProduct!.stock < _damageQuantity) {
      setState(() {
        _feedbackMessage =
            'Cannot deduct $_damageQuantity units — current POS stock is only ${_scannedProduct!.stock}.';
        _isSuccess = false;
      });
      return;
    }

    final stockBefore = _scannedProduct!.stock;
    final success = PosStateManager.instance.logDamagedStock(
      barcode: _scannedProduct!.barcode,
      quantity: _damageQuantity,
      reason: _selectedReason,
      loggedBy: 'Manager Tarek Mansour',
    );

    if (success) {
      final stockAfter = _scannedProduct!.stock;
      setState(() {
        _feedbackMessage =
            'DEDUCTED $_damageQuantity UNIT(S) FROM POS INVENTORY: "${_scannedProduct!.nameEn}". POS Stock updated from $stockBefore → $stockAfter.';
        _isSuccess = true;
        _damageQuantity = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock deducted: ${_scannedProduct!.nameEn} reduced by $_damageQuantity in cashier POS.',
          ),
          backgroundColor: AppColors.rose,
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
        final filteredDamaged = state.damagedGoods.where((d) {
          if (_searchFilter.isEmpty) return true;
          final q = _searchFilter.toLowerCase();
          return d.productName.toLowerCase().contains(q) ||
              d.productCode.toLowerCase().contains(q) ||
              d.barcode.contains(q) ||
              d.damageId.toLowerCase().contains(q);
        }).toList();

        final totalLossToday = state.damagedGoods.fold<double>(0.0, (sum, d) => sum + d.totalLoss);
        final totalDamagedUnits = state.damagedGoods.fold<int>(0, (sum, d) => sum + d.quantity);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top KPI Summary Cards
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL DAMAGED GOODS LOGGED',
                    value: '${state.damagedGoods.length} Incidents',
                    subvalue: '$totalDamagedUnits units removed from POS',
                    icon: Icons.broken_image_outlined,
                    accentColor: AppColors.rose,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'ESTIMATED SHRINKAGE LOSS',
                    value: '${totalLossToday.toStringAsFixed(2)} EGP',
                    subvalue: 'Audited inventory loss',
                    icon: Icons.trending_down_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'POS DEDUCTION STATUS',
                    value: 'Real-Time Sync Active',
                    subvalue: 'Instantly synced with all cashier lanes',
                    icon: Icons.sync_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barcode Scanner & Damage Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppDecorations.cyborgCard(
                  radius: 16,
                  borderColor: AppColors.rose.withOpacity(0.4),
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
                            color: AppColors.rose.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.remove_shopping_cart_rounded, color: AppColors.rose, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan & Register Damaged Stock',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Items logged here are AUTOMATICALLY DEDUCTED from active POS cashier inventory immediately',
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

                    // Barcode Search row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  hint: 'Scan damaged item barcode (e.g. 6224011001029)',
                                  prefixIcon: Icons.qr_code_scanner,
                                  suffix: IconButton(
                                    icon: const Icon(Icons.search, color: AppColors.rose),
                                    onPressed: () => _onBarcodeChanged(_barcodeController.text),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Damage Reason dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'REASON FOR DAMAGE',
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
                                    value: _damageReasons.contains(_selectedReason) ? _selectedReason : _damageReasons.first,
                                    isExpanded: true,
                                    dropdownColor: AppColors.card,
                                    style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                    items: _damageReasons.toSet().map((r) {
                                      return DropdownMenuItem(value: r, child: Text(r));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedReason = val);
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
                                color: isSelected ? AppColors.rose.withOpacity(0.2) : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? AppColors.rose : AppColors.border,
                                ),
                              ),
                              child: Text(
                                '${p.nameEn} (Stock: ${p.stock})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.rose : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product inspection & Auto-deduct Action Box
                    if (_scannedProduct != null) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            // Product icon
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.rose.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.rose.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.report_problem_outlined, color: AppColors.rose, size: 28),
                            ),
                            const SizedBox(width: 16),

                            // Product details
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
                                  const SizedBox(height: 6),
                                  // Live Stock comparison
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          'Current POS Stock: ${_scannedProduct!.stock} units',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.neonCyan,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.rose.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.rose.withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          'Stock After Deduction: ${(_scannedProduct!.stock - _damageQuantity).clamp(0, 999999)} units',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.rose,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Stepper
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DAMAGED QTY',
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
                                        onPressed: _damageQuantity > 1
                                            ? () => setState(() => _damageQuantity--)
                                            : null,
                                      ),
                                      Text(
                                        '$_damageQuantity',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        color: AppColors.textWhite,
                                        onPressed: () => setState(() => _damageQuantity++),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),

                            // Total Loss & Deduct Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'TOTAL VALUE LOSS',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.rose),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(_scannedProduct!.price * _damageQuantity).toStringAsFixed(2)} EGP',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.rose,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton.icon(
                                  onPressed: _logDamagedGoods,
                                  icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                                  label: const Text('LOG & DEDUCT FROM POS'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.rose,
                                    foregroundColor: Colors.white,
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
                          color: _isSuccess
                              ? AppColors.rose.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isSuccess
                                ? AppColors.rose.withOpacity(0.4)
                                : AppColors.error.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSuccess ? Icons.check_circle : Icons.error_outline,
                              size: 18,
                              color: _isSuccess ? AppColors.rose : AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _feedbackMessage!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _isSuccess ? AppColors.rose : AppColors.error,
                                  fontWeight: FontWeight.w700,
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

              // Damaged Goods Log Table
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.list_alt_rounded, color: AppColors.rose, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Damaged Stock Audit Log (Auto-Deducted)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 280,
                    height: 38,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchFilter = val),
                      decoration: AppDecorations.searchField(
                        hint: 'Search damaged log...',
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
                      DataColumn(label: Text('DAMAGE ID', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('DEDUCTED QTY', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('TOTAL LOSS', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('REASON / CAUSE', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('LOGGED BY', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('POS STATUS', style: TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows: filteredDamaged.map((d) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              d.damageId,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.rose,
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
                                  d.productName,
                                  style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                                ),
                                Text(
                                  '${d.productCode} • ${d.barcode}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '-${d.quantity} units',
                              style: const TextStyle(
                                color: AppColors.rose,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${d.totalLoss.toStringAsFixed(2)} EGP',
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
                              child: Text(d.reason, style: const TextStyle(fontSize: 11)),
                            ),
                          ),
                          DataCell(Text(d.loggedBy, style: const TextStyle(fontSize: 12))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppDecorations.badge(color: AppColors.rose),
                              child: const Text(
                                'DEDUCTED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: AppColors.rose,
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
