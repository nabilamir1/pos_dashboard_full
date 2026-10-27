import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mock_data.dart';
import 'receipt_dialog.dart';

/// A sleek desktop drawer for viewing and searching previous receipts in mock state.
class PreviousReceiptsDrawer extends StatefulWidget {
  final List<MockReceipt> receipts;
  final void Function(MockReceipt receipt)? onReorder;

  const PreviousReceiptsDrawer({
    Key? key,
    required this.receipts,
    this.onReorder,
  }) : super(key: key);

  @override
  State<PreviousReceiptsDrawer> createState() => _PreviousReceiptsDrawerState();
}

class _PreviousReceiptsDrawerState extends State<PreviousReceiptsDrawer> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'ALL'; // 'ALL', 'CASH', 'VISA'
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockReceipt> get _filteredReceipts {
    return widget.receipts.where((r) {
      if (_selectedFilter != 'ALL' && r.paymentMethod != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchNo = r.receiptNo.toLowerCase().contains(q);
        final matchCustomer = r.customerName.toLowerCase().contains(q);
        final matchItems = r.items.any((item) =>
            item.nameEn.toLowerCase().contains(q) ||
            item.nameAr.contains(q) ||
            item.barcode.contains(q));
        if (!matchNo && !matchCustomer && !matchItems) return false;
      }
      return true;
    }).toList();
  }

  double get _totalSales =>
      widget.receipts.fold(0.0, (acc, r) => acc + r.total);

  int get _cashCount =>
      widget.receipts.where((r) => r.paymentMethod == 'CASH').length;

  int get _visaCount =>
      widget.receipts.where((r) => r.paymentMethod == 'VISA').length;

  void _openReceiptDialog(BuildContext context, MockReceipt receipt) {
    showDialog(
      context: context,
      builder: (_) => ReceiptDialog(
        cartLines: receipt.items,
        subtotal: receipt.subtotal,
        tax: receipt.tax,
        total: receipt.total,
        paymentMethod: receipt.paymentMethod,
        cashierName: receipt.cashierName,
        terminalId: receipt.terminalId,
        tenderedAmount: receipt.tenderedAmount,
        changeAmount: receipt.changeAmount,
        customReceiptNo: receipt.receiptNo,
        customDate: receipt.timestamp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReceipts;

    return Drawer(
      width: 480,
      backgroundColor: AppColors.background,
      elevation: 16,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────
            _buildHeader(context),

            // ── Session Sales Stats ─────────────────────────────
            _buildSessionStats(),

            // ── Search & Filter ─────────────────────────────────
            _buildSearchAndFilters(),

            const SizedBox(height: 12),

            // ── Receipts List ───────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, index) {
                        return _buildReceiptCard(ctx, filtered[index]);
                      },
                    ),
            ),

            // ── Bottom dismiss helper ───────────────────────────
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppGradients.cyan,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Previous Receipts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.receipts.length} completed orders in session',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            tooltip: 'Close Drawer',
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            label: 'SESSION SALES',
            value: '${_totalSales.toStringAsFixed(2)} EGP',
            valueColor: AppColors.sky,
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          _statItem(
            label: 'ORDERS',
            value: '${widget.receipts.length}',
            valueColor: AppColors.textPrimary,
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          _statItem(
            label: 'CASH / VISA',
            value: '$_cashCount / $_visaCount',
            valueColor: AppColors.emerald,
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search input
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search receipt #, customer, item...',
              hintStyle:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 18, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
          ),
          const SizedBox(height: 10),

          // Filter pills
          Row(
            children: [
              _filterChip('ALL', 'All (${widget.receipts.length})'),
              const SizedBox(width: 8),
              _filterChip('CASH', '💵 Cash ($_cashCount)',
                  color: AppColors.emerald),
              const SizedBox(width: 8),
              _filterChip('VISA', '💳 Visa ($_visaCount)',
                  color: AppColors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label, {Color? color}) {
    final isSelected = _selectedFilter == filterKey;
    final activeColor = color ?? AppColors.sky;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = filterKey),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, MockReceipt receipt) {
    final isCash = receipt.paymentMethod == 'CASH';
    final timeStr = _formatTime(receipt.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openReceiptDialog(context, receipt),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Receipt number + payment badge + time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          receipt.receiptNo,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCash
                                ? AppColors.emerald.withOpacity(0.15)
                                : AppColors.cyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isCash
                                  ? AppColors.emerald.withOpacity(0.3)
                                  : AppColors.cyan.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            isCash ? '💵 Cash' : '💳 Visa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCash ? AppColors.emerald : AppColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Item list summary
                Text(
                  '${receipt.totalItemCount} item${receipt.totalItemCount > 1 ? 's' : ''}: ' +
                      receipt.items.map((i) => '${i.nameEn} (x${i.quantity})').join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 12),
                Container(height: 1, color: AppColors.border.withOpacity(0.5)),
                const SizedBox(height: 10),

                // Bottom row: Total + breakdown + Action buttons
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${receipt.total.toStringAsFixed(2)} EGP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.sky,
                          ),
                        ),
                        if (isCash && receipt.tenderedAmount != null)
                          Text(
                            'Paid: ${receipt.tenderedAmount!.toStringAsFixed(0)} · Change: ${receipt.changeAmount?.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),

                    // Reorder button (optional)
                    if (widget.onReorder != null)
                      IconButton(
                        onPressed: () {
                          widget.onReorder!(receipt);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Items from ${receipt.receiptNo} copied to cart!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        color: AppColors.textMuted,
                        tooltip: 'Load items into cart',
                      ),

                    // View Receipt button
                    ElevatedButton.icon(
                      onPressed: () => _openReceiptDialog(context, receipt),
                      icon: const Icon(Icons.visibility_outlined, size: 14),
                      label: const Text('View Receipt',
                          style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.borderLight),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 14),
          const Text(
            'No receipts found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search query'
                : 'Completed checkouts will appear here',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${_filteredReceipts.length} of ${widget.receipts.length} receipts',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
            label: const Text('Back to POS', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.emerald,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
