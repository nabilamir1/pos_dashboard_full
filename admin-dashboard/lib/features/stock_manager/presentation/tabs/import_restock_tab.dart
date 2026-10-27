import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab 6: Import/Restock Tab
/// Allows Stock Manager to log inbound shipments and add new imported quantities
/// to existing warehouse products with supplier and batch traceability.
class ImportRestockTab extends StatefulWidget {
  const ImportRestockTab({super.key});

  @override
  State<ImportRestockTab> createState() => _ImportRestockTabState();
}

class _ImportRestockTabState extends State<ImportRestockTab> {
  final _formKey = GlobalKey<FormState>();

  LiveStoreProduct? _selectedProduct;
  final TextEditingController _qtyCtrl = TextEditingController(text: '150');
  final TextEditingController _poCtrl = TextEditingController(text: 'PO-2026-8840');
  final TextEditingController _supplierCtrl = TextEditingController(text: 'National FMCG Distribution Ltd.');
  final TextEditingController _batchCtrl = TextEditingController(text: 'LOT-2026-X11');

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _poCtrl.dispose();
    _supplierCtrl.dispose();
    _batchCtrl.dispose();
    super.dispose();
  }

  void _onConfirmImport() {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0) return;

    PosStateManager.instance.importRestockToWarehouse(
      barcode: _selectedProduct!.barcode,
      quantity: qty,
      supplier: _supplierCtrl.text.trim(),
      poNumber: _poCtrl.text.trim().toUpperCase(),
      batchNumber: _batchCtrl.text.trim().toUpperCase(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Imported +$qty units of ${_selectedProduct!.nameEn} into warehouse Bay!',
        ),
        backgroundColor: AppColors.emerald,
      ),
    );

    setState(() {
      _qtyCtrl.text = '100';
      _poCtrl.text = 'PO-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      _batchCtrl.text = 'LOT-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedProduct == null && state.products.isNotEmpty) {
      _selectedProduct = state.products.first;
    }

    final inboundQty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final currentWhStock = _selectedProduct?.warehouseStock ?? 0;
    final projectedWhStock = currentWhStock + inboundQty;

    // Filter audit logs for inbound restocks
    final recentImports = state.auditLogs
        .where((l) => l.actionType == 'RESTOCK_IMPORTED')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Two Column Form & Calculations ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inbound Form
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppDecorations.cyborgCard(
                    radius: 16,
                    isDark: isDark,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.input_rounded, color: AppColors.neonCyan, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Warehouse Inbound Restock Entry',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Record incoming manufacturer pallets & supplier restock deliveries',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondary : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Product Selector
                        _label('TARGET PRODUCT TO RESTOCK', isDark),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<LiveStoreProduct>(
                              value: _selectedProduct,
                              isExpanded: true,
                              dropdownColor: isDark ? AppColors.card : Colors.white,
                              items: state.products.map((p) {
                                return DropdownMenuItem<LiveStoreProduct>(
                                  value: p,
                                  child: Text(
                                    '${p.code} — ${p.nameEn} (Current WH: ${p.warehouseStock})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textWhite : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedProduct = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Quantity & PO Number
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('INBOUND QUANTITY (UNITS)', isDark),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _qtyCtrl,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.neonCyan, fontSize: 15),
                                    decoration: _inputDecoration('e.g. 150', isDark),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('PURCHASE ORDER NUMBER', isDark),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _poCtrl,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                                    decoration: _inputDecoration('PO-2026-XXXX', isDark),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Supplier & Batch
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('SUPPLIER / IMPORTER', isDark),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _supplierCtrl,
                                    style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                                    decoration: _inputDecoration('Supplier Company', isDark),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('BATCH / LOT NUMBER', isDark),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _batchCtrl,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                                    decoration: _inputDecoration('LOT-XXXX', isDark),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _onConfirmImport,
                            icon: const Icon(Icons.archive_rounded, size: 20),
                            label: const Text('CONFIRM INBOUND SHIPMENT & UPDATE WAREHOUSE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(fontWeight: FontWeight.w900),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Stock Projection Card
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.electricPurple.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricPurple.withOpacity(0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics_rounded, color: AppColors.electricPurpleLight, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Warehouse Stock Impact',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_selectedProduct != null) ...[
                        _impactBox('CURRENT WAREHOUSE STOCK', '$currentWhStock units', isDark, color: AppColors.amber),
                        const SizedBox(height: 12),
                        _impactBox('INBOUND SHIPMENT', '+$inboundQty units', isDark, color: AppColors.neonCyan),
                        const SizedBox(height: 12),
                        _impactBox('PROJECTED NEW STOCK', '$projectedWhStock units', isDark, color: AppColors.emerald, isLarge: true),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRODUCT CODE: ${_selectedProduct!.code}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.neonCyan)),
                              const SizedBox(height: 4),
                              Text('BARCODE: ${_selectedProduct!.barcode}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                              const SizedBox(height: 4),
                              Text('CATEGORY: ${_selectedProduct!.category}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text('STORE POS STOCK: ${_selectedProduct!.stock} units', style: const TextStyle(fontSize: 11, color: AppColors.electricPurpleLight)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Section: Recent Inbound Restock Deliveries ──────────────────────
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.neonCyan, size: 22),
              const SizedBox(width: 10),
              Text(
                'Recent Inbound Warehouse Restock Logs (${recentImports.length})',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (recentImports.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
              child: const Text('No recent inbound shipments recorded yet in this shift.', style: TextStyle(color: AppColors.textMuted)),
            )
          else
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
                      headingRowHeight: 48,
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 64,
                      headingRowColor: MaterialStateProperty.all(isDark ? AppColors.surface : const Color(0xFFF8FAFC)),
                      dataRowColor: MaterialStateProperty.all(isDark ? AppColors.card : Colors.white),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('PO NUMBER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        DataColumn(label: Text('PRODUCT NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        DataColumn(label: Text('BARCODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        DataColumn(label: Text('IMPORTED QTY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        DataColumn(label: Text('RECEIVED BY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        DataColumn(label: Text('TIMESTAMP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        DataColumn(label: Text('NOTES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                      ],
                      rows: recentImports.map((log) {
                        return DataRow(
                          cells: [
                            DataCell(Text(log.referenceNo, style: const TextStyle(color: AppColors.neonCyan, fontFamily: 'monospace', fontWeight: FontWeight.w800))),
                            DataCell(Text(log.productName, style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.textWhite : Colors.black87))),
                            DataCell(Text(log.barcode, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                            DataCell(Text('+${log.quantity} units', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.emerald))),
                            DataCell(Text(log.performedBy, style: const TextStyle(fontSize: 12))),
                            DataCell(Text(log.timestamp.toString().substring(11, 16), style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                            DataCell(Text(log.notes, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
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
  }

  Widget _impactBox(String title, String val, bool isDark, {required Color color, bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          Text(val, style: TextStyle(fontSize: isLarge ? 18 : 14, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: isDark ? AppColors.textMuted : Colors.black54),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
