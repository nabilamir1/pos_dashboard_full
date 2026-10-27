import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/localization/app_localizations.dart';

/// Tab for Store Manager to confirm and log incoming physical shipments delivered from the warehouse.
/// Once logged here, it immediately increases product stock so cashiers can sell it.
class StockReceivingTab extends StatefulWidget {
  const StockReceivingTab({Key? key}) : super(key: key);

  @override
  State<StockReceivingTab> createState() => _StockReceivingTabState();
}

class _StockReceivingTabState extends State<StockReceivingTab> {
  final TextEditingController _poController = TextEditingController(text: 'PO-2026-9014');
  final TextEditingController _supplierController = TextEditingController(text: 'Juhayna Dairy Distribution');
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _batchController = TextEditingController(text: 'BCH-26-JUH01');
  int _receivedQuantity = 50;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 180));
  LiveStoreProduct? _selectedProduct;
  String? _successNotification;
  String _searchFilter = '';

  final List<String> _supplierPresets = [
    'Juhayna Dairy Distribution',
    'Al-Mansour Beverages Co.',
    'Chipsy Egypt Distribution',
    'Bisco Misr Confectionery',
    'Henkel / Persil Cleaning Supply',
    'Cairo Central Warehouse Bay 1',
  ];

  @override
  void initState() {
    super.initState();
    final state = PosStateManager.instance;
    if (state.products.isNotEmpty) {
      _selectProduct(state.products.length > 3 ? state.products[3] : state.products.first);
    }
  }

  @override
  void dispose() {
    _poController.dispose();
    _supplierController.dispose();
    _barcodeController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  void _selectProduct(LiveStoreProduct product) {
    setState(() {
      _selectedProduct = product;
      _barcodeController.text = product.barcode;
      _successNotification = null;
    });
  }

  void _onBarcodeChanged(String bc) {
    final state = PosStateManager.instance;
    final found = state.findProductByBarcode(bc.trim());
    setState(() {
      _selectedProduct = found;
      _successNotification = null;
    });
  }

  void _confirmShipmentReceiving() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or scan a valid product.')),
      );
      return;
    }

    final stockBefore = _selectedProduct!.stock;
    final success = PosStateManager.instance.receiveWarehouseStock(
      poNumber: _poController.text.trim().isEmpty ? 'PO-INCOMING' : _poController.text.trim(),
      supplier: _supplierController.text.trim().isEmpty ? 'Central Warehouse' : _supplierController.text.trim(),
      barcode: _selectedProduct!.barcode,
      quantity: _receivedQuantity,
      batchNumber: _batchController.text.trim().isEmpty ? 'BCH-STANDARD' : _batchController.text.trim(),
      expiryDate: _expiryDate,
      receivedBy: 'Manager Tarek Mansour',
    );

    if (success) {
      final stockAfter = _selectedProduct!.stock;
      setState(() {
        _successNotification =
            'SHIPMENT CONFIRMED: ${_receivedQuantity}x units of "${_selectedProduct!.nameEn}" added to POS inventory! Cashier stock increased from $stockBefore → $stockAfter units (Available for immediate cashier checkout).';
        _receivedQuantity = 50;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Shipment logged: ${_selectedProduct!.nameEn} restocked in POS system (+${_receivedQuantity} units).',
          ),
          backgroundColor: AppColors.emerald,
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
        final totalShipments = state.receivingLogs.length;
        final totalUnitsReceived = state.receivingLogs.fold<int>(0, (sum, r) => sum + r.quantityReceived);

        final filteredLogs = state.receivingLogs.where((r) {
          if (_searchFilter.isEmpty) return true;
          final q = _searchFilter.toLowerCase();
          return r.poNumber.toLowerCase().contains(q) ||
              r.supplier.toLowerCase().contains(q) ||
              r.productName.toLowerCase().contains(q) ||
              r.barcode.contains(q) ||
              r.batchNumber.toLowerCase().contains(q);
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
                    title: 'WAREHOUSE SHIPMENTS LOGGED',
                    value: '$totalShipments Deliveries',
                    subvalue: '$totalUnitsReceived units added to cashier POS',
                    icon: Icons.local_shipping_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'POS STOCK AVAILABILITY',
                    value: 'Instant Cashier Sync',
                    subvalue: 'Available at register barcode scanner immediately',
                    icon: Icons.bolt_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'SUPPLIER RECONCILIATION',
                    value: '100% Waybills Verified',
                    subvalue: 'Physical counts matched to PO manifest',
                    icon: Icons.verified_outlined,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stock Receiving Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppDecorations.cyborgCard(
                  radius: 16,
                  borderColor: AppColors.neonCyan.withOpacity(0.4),
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
                          child: const Icon(Icons.inventory_rounded, color: AppColors.neonCyan, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Receive Physical Stock From Warehouse',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Confirm incoming pallet delivery. Once confirmed, stock increments immediately so cashiers can sell it.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // PO # & Supplier Row
                    Row(
                      children: [
                        // PO Number
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PURCHASE ORDER (PO) / WAYBILL NO.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _poController,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                                decoration: AppDecorations.searchField(
                                  hint: 'PO-2026-XXXX',
                                  prefixIcon: Icons.description_outlined,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Supplier Name
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SUPPLIER / WAREHOUSE SOURCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surface : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _supplierPresets.contains(_supplierController.text)
                                        ? _supplierController.text
                                        : _supplierPresets.first,
                                    isExpanded: true,
                                    dropdownColor: isDark ? AppColors.card : Colors.white,
                                    style: TextStyle(
                                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                      fontSize: 13,
                                    ),
                                    items: _supplierPresets.map((s) {
                                      return DropdownMenuItem(value: s, child: Text(s));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _supplierController.text = val);
                                      }
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

                    // Barcode Search Row & Batch #
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barcode Field
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DELIVERED PRODUCT BARCODE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _barcodeController,
                                onChanged: _onBarcodeChanged,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                                decoration: AppDecorations.searchField(
                                  hint: 'Scan or enter product barcode',
                                  prefixIcon: Icons.qr_code_scanner,
                                  isDark: isDark,
                                  suffix: IconButton(
                                    icon: const Icon(Icons.search, color: AppColors.neonCyan),
                                    onPressed: () => _onBarcodeChanged(_barcodeController.text),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Batch Number
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MANUFACTURING BATCH #',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _batchController,
                                style: TextStyle(
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: AppDecorations.searchField(
                                  hint: 'BCH-26-XXXX',
                                  prefixIcon: Icons.confirmation_number_outlined,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

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
                          final isSelected = _selectedProduct?.barcode == p.barcode;
                          return InkWell(
                            onTap: () => _selectProduct(p),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.neonCyan.withOpacity(0.2)
                                    : (isDark ? AppColors.surface : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.neonCyan
                                      : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                ),
                              ),
                              child: Text(
                                '${p.nameEn} (POS Stock: ${p.stock})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                                      : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Preview Box & Receiving Confirmation Action
                    if (_selectedProduct != null) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceLight.withOpacity(0.6)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderLight : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.emerald, size: 28),
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
                                        _selectedProduct!.nameEn,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.surface : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        child: Text(
                                          _selectedProduct!.code,
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
                                    '${_selectedProduct!.nameAr}  •  Retail Price: ${_selectedProduct!.price.toStringAsFixed(2)} EGP  •  Category: ${_selectedProduct!.category}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Stock before vs after preview
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.surface : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        child: Text(
                                          'Current Cashier Stock: ${_selectedProduct!.stock} units',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.emerald.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          'Stock After Receipt: ${_selectedProduct!.stock + _receivedQuantity} units',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.emerald,
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
                                  'QUANTITY RECEIVED',
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
                                    color: isDark ? AppColors.surface : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                        onPressed: _receivedQuantity > 10
                                            ? () => setState(() => _receivedQuantity -= 10)
                                            : null,
                                      ),
                                      Text(
                                        '$_receivedQuantity',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                        onPressed: () => setState(() => _receivedQuantity += 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),

                            // Action Button
                            ElevatedButton.icon(
                              onPressed: _confirmShipmentReceiving,
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                              label: const Text('CONFIRM & RESTOCK POS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald,
                                foregroundColor: AppColors.textOnAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Success Banner
                    if (_successNotification != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _successNotification!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald,
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

              // Received Shipments History Table
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Confirmed Warehouse Shipments Registry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 280,
                    height: 38,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchFilter = val),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                      decoration: AppDecorations.searchField(
                        hint: 'Search received shipments...',
                        prefixIcon: Icons.search,
                        isDark: isDark,
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
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                    ),
                    dataRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.card : Colors.white,
                    ),
                    columnSpacing: 22,
                    columns: [
                      DataColumn(label: Text(context.tr('col_req_id'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: const Text('PO / WAYBILL', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_supplier'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_product'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_qty'), style: const TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: const Text('BATCH #', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text(context.tr('col_status'), style: const TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows: filteredLogs.map((log) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              log.receivingId,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              log.poNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              log.supplier,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  log.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '${log.productCode} • Barcode: ${log.barcode}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '+${log.quantityReceived} units',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.emerald),
                            ),
                          ),
                          DataCell(
                            Text(
                              log.batchNumber,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppDecorations.badge(color: AppColors.emerald),
                              child: const Text(
                                'RESTOCKED IN POS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: AppColors.emerald,
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
