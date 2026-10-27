import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab 3: Warehouse Low Stock Tab
/// Monitors products low in the warehouse and allows the Stock Manager
/// to dispatch restock requests to the Store Manager (requiring Manager approval).
class WarehouseLowStockTab extends StatefulWidget {
  const WarehouseLowStockTab({super.key});

  @override
  State<WarehouseLowStockTab> createState() => _WarehouseLowStockTabState();
}

class _WarehouseLowStockTabState extends State<WarehouseLowStockTab> {
  LiveStoreProduct? _selectedProduct;
  final TextEditingController _qtyController = TextEditingController(text: '200');
  final TextEditingController _supplierController = TextEditingController(text: 'Egyptian FMCG Wholesale Distribution');

  @override
  void dispose() {
    _qtyController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _openRequestDialog(BuildContext context, [LiveStoreProduct? preselected]) {
    final state = PosStateManager.instance;
    LiveStoreProduct? currentProd = preselected ?? _selectedProduct ?? (state.products.isNotEmpty ? state.products.first : null);
    final qtyCtrl = TextEditingController(text: '250');
    final supplierCtrl = TextEditingController(
      text: currentProd?.category == 'Meat'
          ? 'Egyptian Meat Imports Co.'
          : 'National FMCG Distribution Ltd.',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
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
                    child: const Icon(Icons.send_rounded, color: AppColors.neonCyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Request Warehouse Restock from Manager',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Product to Replenish:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textMuted : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<LiveStoreProduct>(
                          value: currentProd,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.card : Colors.white,
                          items: state.products.map((p) {
                            return DropdownMenuItem<LiveStoreProduct>(
                              value: p,
                              child: Text(
                                '${p.nameEn} (WH: ${p.warehouseStock} units)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textWhite : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                currentProd = val;
                                if (val.category == 'Meat') {
                                  supplierCtrl.text = 'Egyptian Meat Imports Co.';
                                } else if (val.category == 'Dairy') {
                                  supplierCtrl.text = 'Juhayna Food Industries';
                                } else {
                                  supplierCtrl.text = 'National FMCG Distribution Ltd.';
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (currentProd != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Warehouse Stock: ${currentProd!.warehouseStock} units',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.amber),
                            ),
                            Text(
                              'Threshold: ≤ ${currentProd!.minWarehouseThreshold}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    Text(
                      'Requested Replenishment Quantity (Units):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textMuted : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'e.g. 200',
                        filled: true,
                        fillColor: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Supplier / Vendor:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textMuted : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: supplierCtrl,
                      style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Supplier Company Name',
                        filled: true,
                        fillColor: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                    if (currentProd == null || qty <= 0) return;

                    state.sendWarehouseRestockRequest(
                      barcode: currentProd!.barcode,
                      requestedQuantity: qty,
                      supplier: supplierCtrl.text.trim(),
                    );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Restock request for ${currentProd!.nameEn} (+$qty units) sent to Manager!'),
                        backgroundColor: AppColors.neonCyan,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('SUBMIT TO MANAGER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final lowWarehouseItems = state.products
            .where((p) => p.warehouseStock <= p.minWarehouseThreshold)
            .toList();
        final sentRequests = state.warehouseRestockRequests;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Action Banner ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.electricPurple.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.amber,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Warehouse Low Stock Replenishment Protocol',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'When the central warehouse inventory falls below safe thresholds, generate a restock request. Once authorized by the Store Manager, supplier purchase orders are released.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () => _openRequestDialog(context),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('NEW RESTOCK REQUEST'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section 1: Low Warehouse Inventory Items ───────────────────
              Row(
                children: [
                  const Icon(Icons.crisis_alert_rounded, color: AppColors.amber, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Critical & Low Warehouse Items (${lowWarehouseItems.length})',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (lowWarehouseItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded, color: AppColors.emerald, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'All warehouse items currently have healthy stock levels above minimum thresholds.',
                        style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              else
                ...lowWarehouseItems.map((prod) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.cyborgCard(
                      radius: 14,
                      borderColor: AppColors.amber.withOpacity(0.5),
                      isDark: isDark,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.amber, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    prod.nameEn,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('(${prod.nameAr})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(prod.code, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.neonCyan)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    'Warehouse Stock: ${prod.warehouseStock} units',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rose),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Safe Threshold: ${prod.minWarehouseThreshold} units',
                                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : Colors.black54),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Store POS Stock: ${prod.stock} units',
                                    style: const TextStyle(fontSize: 12, color: AppColors.electricPurpleLight),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openRequestDialog(context, prod),
                          icon: const Icon(Icons.send_rounded, size: 15),
                          label: const Text('REQUEST RESTOCK'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 28),

              // ── Section 2: Sent Warehouse Restock Requests ──────────────────
              Row(
                children: [
                  const Icon(Icons.outbox_rounded, color: AppColors.neonCyan, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Warehouse Restock Requests Sent to Store Manager (${sentRequests.length})',
                    style: TextStyle(
                      fontSize: 17,
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
                        headingRowHeight: 48,
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 64,
                        headingRowColor: MaterialStateProperty.all(
                          isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                        ),
                        dataRowColor: MaterialStateProperty.all(
                          isDark ? AppColors.card : Colors.white,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('REQUEST ID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('BARCODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('CURRENT WH STOCK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('REQUESTED QTY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('SUPPLIER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('DECISION NOTE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        ],
                        rows: sentRequests.map((req) {
                          Color statusColor = AppColors.amber;
                          if (req.status == 'Approved') statusColor = AppColors.emerald;
                          if (req.status == 'Rejected') statusColor = AppColors.rose;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  req.requestId,
                                  style: const TextStyle(
                                    color: AppColors.neonCyan,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      req.productName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: isDark ? AppColors.textWhite : Colors.black87,
                                      ),
                                    ),
                                    Text('Code: ${req.productCode}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              DataCell(Text(req.productBarcode, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                              DataCell(Text('${req.currentWarehouseStock} units', style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.w700))),
                              DataCell(Text('+${req.requestedQuantity} units', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.neonCyan))),
                              DataCell(Text(req.supplier, style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    req.status.toUpperCase(),
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  req.decisionNote ?? (req.status.contains('Awaiting') ? 'Pending Manager review' : '-'),
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
}
