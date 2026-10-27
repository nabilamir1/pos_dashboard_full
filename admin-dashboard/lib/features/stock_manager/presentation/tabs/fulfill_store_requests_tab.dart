import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab 5: Fulfill Store Requests Tab
/// Receives approved requests from the Manager for missing store items.
/// The Stock Manager scans barcodes to log items out of the warehouse,
/// which automatically deducts warehouse stock, increments POS store stock,
/// and generates an official delivery receipt to the store.
class FulfillStoreRequestsTab extends StatefulWidget {
  const FulfillStoreRequestsTab({super.key});

  @override
  State<FulfillStoreRequestsTab> createState() =>
      _FulfillStoreRequestsTabState();
}

class _FulfillStoreRequestsTabState extends State<FulfillStoreRequestsTab> {
  StockReorderRequest? _selectedRequest;
  final TextEditingController _barcodeScanCtrl = TextEditingController();
  bool _isBarcodeVerified = false;

  @override
  void dispose() {
    _barcodeScanCtrl.dispose();
    super.dispose();
  }

  void _onSelectRequest(StockReorderRequest req) {
    setState(() {
      _selectedRequest = req;
      _barcodeScanCtrl.clear();
      _isBarcodeVerified = false;
    });
  }

  void _verifyBarcode(String inputBarcode) {
    if (_selectedRequest == null) return;
    final barcode = inputBarcode.trim();
    if (barcode == _selectedRequest!.productBarcode) {
      setState(() {
        _isBarcodeVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode Verified! Item ready for warehouse dispatch.'),
          backgroundColor: AppColors.emerald,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _isBarcodeVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode mismatch! Please scan the correct product.'),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  void _simulateScan() {
    if (_selectedRequest == null) return;
    _barcodeScanCtrl.text = _selectedRequest!.productBarcode;
    _verifyBarcode(_selectedRequest!.productBarcode);
  }

  void _fulfillAndShowReceipt(StockReorderRequest req) {
    final state = PosStateManager.instance;
    final success = state.fulfillStoreRequest(
      requestId: req.requestId,
      barcode: req.productBarcode,
    );

    if (success) {
      _showDeliveryReceiptDialog(req);
      setState(() {
        _selectedRequest = null;
        _barcodeScanCtrl.clear();
        _isBarcodeVerified = false;
      });
    }
  }

  void _showDeliveryReceiptDialog(StockReorderRequest req) {
    final now = DateTime.now();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

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
                child: Text(
                  'Warehouse Delivery Slip / Store Handover',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _receiptRow('DELIVERY RECEIPT NO:', 'DELIV-${req.requestId}', isDark, isCode: true),
                      const Divider(height: 20),
                      _receiptRow('Item Dispatched:', req.productName, isDark),
                      const SizedBox(height: 6),
                      _receiptRow('Barcode / SKU:', '${req.productBarcode} (${req.productCode})', isDark),
                      const SizedBox(height: 6),
                      _receiptRow('Quantity Delivered:', '+${req.requiredQuantity} units', isDark, isHighlight: true),
                      const SizedBox(height: 6),
                      _receiptRow('Dispatched By:', 'Stock Mgr Hossam El-Din', isDark),
                      const SizedBox(height: 6),
                      _receiptRow('Destination:', 'Store Floor Shelves (POS)', isDark),
                      const SizedBox(height: 6),
                      _receiptRow('Dispatch Bay:', 'Bay 1 — Automated Forklift #3', isDark),
                      const SizedBox(height: 6),
                      _receiptRow('Timestamp:', now.toString().substring(0, 19), isDark),
                      const Divider(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'LOGGED OUT OF WAREHOUSE & ADDED TO POS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.emerald),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery slip printed & sent to store counter!'),
                    backgroundColor: AppColors.neonCyan,
                  ),
                );
              },
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text('PRINT DELIVERY SLIP'),
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

  Widget _receiptRow(String label, String value, bool isDark, {bool isCode = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textMuted : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontFamily: isCode ? 'monospace' : null,
            fontWeight: FontWeight.w900,
            color: isHighlight
                ? AppColors.neonCyan
                : (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
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
        final approvedUnfulfilled = state.reorderRequests
            .where((r) => r.status == 'Approved' && !r.isFulfilled)
            .toList();
        final fulfilledHistory = state.reorderRequests
            .where((r) => r.isFulfilled)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Banner ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFECFDF5), Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emerald.withOpacity(0.4), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping_rounded, color: AppColors.emerald, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Fulfillment & Delivery Scanner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select approved store requests, scan physical barcodes before packaging, and log items out of the warehouse with automated delivery handover receipts.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Main Two-Column Layout ──────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Approved Requests List
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.playlist_add_check_rounded, color: AppColors.emerald, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Approved Requests Awaiting Warehouse Outbound (${approvedUnfulfilled.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (approvedUnfulfilled.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(36),
                            alignment: Alignment.center,
                            decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                            child: const Column(
                              children: [
                                Icon(Icons.verified_rounded, size: 40, color: AppColors.emerald),
                                SizedBox(height: 12),
                                Text(
                                  'All Approved Store Requests Have Been Fulfilled!',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No pending store restock packages awaiting barcode verification in warehouse.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        else
                          ...approvedUnfulfilled.map((req) {
                            final isSelected = _selectedRequest?.requestId == req.requestId;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.card : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.neonCyan.withOpacity(0.2),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.inventory_2_rounded, color: AppColors.emerald, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              req.productName,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(req.productCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.neonCyan)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Barcode: ${req.productBarcode}  •  Reorder Qty: +${req.requiredQuantity} units',
                                          style: const TextStyle(fontSize: 12, color: AppColors.neonCyan, fontWeight: FontWeight.w700),
                                        ),
                                        if (req.decisionNote != null) ...[
                                          const SizedBox(height: 2),
                                          Text('Note: ${req.decisionNote}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _onSelectRequest(req),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected ? AppColors.neonCyan : (isDark ? AppColors.surface : const Color(0xFFE2E8F0)),
                                      foregroundColor: isSelected ? Colors.black : (isDark ? AppColors.textWhite : Colors.black87),
                                    ),
                                    child: Text(isSelected ? 'ACTIVE' : 'SELECT'),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Right Column: Barcode Scanning Handover Console
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: AppDecorations.cyborgCard(
                        radius: 16,
                        borderColor: _selectedRequest != null ? AppColors.neonCyan : null,
                        isDark: isDark,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.qr_code_scanner_rounded, color: AppColors.neonCyan, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Outbound Handover Station',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_selectedRequest == null) ...[
                            Container(
                              padding: const EdgeInsets.all(24),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.touch_app_rounded, color: AppColors.textMuted, size: 36),
                                  SizedBox(height: 10),
                                  Text(
                                    'Please select an approved store request from the left column to begin scanning and dispatching.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SELECTED ITEM TO DISPATCH:',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? AppColors.textMuted : Colors.black54),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedRequest!.productName,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Expected Barcode: ${_selectedRequest!.productBarcode}',
                                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.neonCyan),
                                  ),
                                  Text(
                                    'Handover Units: +${_selectedRequest!.requiredQuantity} units',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.emerald),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'SCAN ITEM BARCODE FOR VERIFICATION:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? AppColors.textMuted : Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _barcodeScanCtrl,
                                    onChanged: _verifyBarcode,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textWhite : Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Scan or paste barcode...',
                                      filled: true,
                                      fillColor: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _simulateScan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.electricPurple,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  child: const Text('SIMULATE'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Verification status indicator
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isBarcodeVerified
                                    ? AppColors.emerald.withOpacity(0.14)
                                    : AppColors.amber.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _isBarcodeVerified
                                      ? AppColors.emerald.withOpacity(0.4)
                                      : AppColors.amber.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isBarcodeVerified ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                    color: _isBarcodeVerified ? AppColors.emerald : AppColors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isBarcodeVerified ? 'Barcode Verified & Matched' : 'Awaiting physical barcode scan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _isBarcodeVerified ? AppColors.emerald : AppColors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _isBarcodeVerified
                                    ? () => _fulfillAndShowReceipt(_selectedRequest!)
                                    : null,
                                icon: const Icon(Icons.local_shipping_rounded, size: 20),
                                label: const Text('DISPATCH & ISSUE DELIVERY SLIP'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonCyan,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                                ),
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

              // ── Section 3: Completed Store Deliveries History ───────────────
              Row(
                children: [
                  const Icon(Icons.history_edu_rounded, color: AppColors.neonCyan, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Recent Store Deliveries Handover History (${fulfilledHistory.length})',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (fulfilledHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                  child: const Text('No completed warehouse dispatches recorded yet in this shift.', style: TextStyle(color: AppColors.textMuted)),
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
                            DataColumn(label: Text('RECEIPT NO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text('BARCODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text('QUANTITY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text('DISPATCHED BY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text('TIME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text('DELIVERY RECEIPT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          ],
                          rows: fulfilledHistory.map((req) {
                            return DataRow(
                              cells: [
                                DataCell(Text('DELIV-${req.requestId}', style: const TextStyle(color: AppColors.neonCyan, fontFamily: 'monospace', fontWeight: FontWeight.w800))),
                                DataCell(Text(req.productName, style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.textWhite : Colors.black87))),
                                DataCell(Text(req.productBarcode, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                                DataCell(Text('+${req.requiredQuantity} units', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.emerald))),
                                DataCell(Text(req.reviewedBy ?? 'Stock Mgr', style: const TextStyle(fontSize: 12))),
                                DataCell(Text(req.fulfilledTime != null ? req.fulfilledTime.toString().substring(11, 16) : 'Recently', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                                DataCell(
                                  OutlinedButton.icon(
                                    onPressed: () => _showDeliveryReceiptDialog(req),
                                    icon: const Icon(Icons.receipt_rounded, size: 14),
                                    label: const Text('VIEW SLIP'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.neonCyan,
                                      side: const BorderSide(color: AppColors.neonCyan),
                                    ),
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
