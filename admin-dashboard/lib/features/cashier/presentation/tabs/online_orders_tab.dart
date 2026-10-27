import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';

/// Tab for Cashier to receive and manage Online Orders (Web/App).
/// Customer details (Name, Phone, Address, Email), COD status,
/// Accept/Reject, missing items handling (replace item or cancel order),
/// item scanning verification, and print/dispatch to "Out for Delivery".
class OnlineOrdersTab extends StatefulWidget {
  const OnlineOrdersTab({Key? key}) : super(key: key);

  @override
  State<OnlineOrdersTab> createState() => _OnlineOrdersTabState();
}

class _OnlineOrdersTabState extends State<OnlineOrdersTab> {
  String _statusFilter = 'ALL';
  OnlineOrder? _selectedOrder;
  final TextEditingController _scanCtrl = TextEditingController();

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  void _showMissingItemDialog(BuildContext context, OnlineOrder order, OnlineOrderItem item, bool isDark) {
    final state = PosStateManager.instance;
    LiveStoreProduct? replacementProduct = state.products.firstWhere(
      (p) => p.category == 'Beverages' && p.barcode != item.barcode,
      orElse: () => state.products.first,
    );
    final noteCtrl = TextEditingController(text: 'Customer approved alternative flavor');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.card : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.amber),
              ),
              title: Row(
                children: [
                  const Icon(Icons.report_problem_rounded, color: AppColors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${context.tr('item_out_of_stock')}: ${item.nameEn}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The item "${item.nameEn}" (${item.quantity}x) is unavailable in current inventory. Please contact customer ${order.customerName} (${order.customerPhone}):',
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondary : Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      context.tr('replace_similar_opt'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.neonCyan),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: replacementProduct?.barcode,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.card : Colors.white,
                          style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87, fontSize: 13),
                          items: state.products.take(10).map((p) {
                            return DropdownMenuItem(
                              value: p.barcode,
                              child: Text('${p.nameEn} - ${p.price.toStringAsFixed(2)} EGP'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                replacementProduct = state.findProductByBarcode(val);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                      decoration: AppDecorations.searchField(hint: 'Customer replacement notes', isDark: isDark),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      context.tr('cancel_order_opt'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.rose),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'If customer refuses replacement, cancel order without penalties.',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    state.handleMissingOnlineItem(
                      orderId: order.orderId,
                      missingBarcode: item.barcode,
                      action: 'CANCEL',
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order ${order.orderId} cancelled per customer request.'),
                        backgroundColor: AppColors.rose,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose,
                    side: const BorderSide(color: AppColors.rose),
                  ),
                  child: Text(context.tr('cancel_entire_order')),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (replacementProduct != null) {
                      state.handleMissingOnlineItem(
                        orderId: order.orderId,
                        missingBarcode: item.barcode,
                        action: 'REPLACE',
                        replacementBarcode: replacementProduct!.barcode,
                        note: noteCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Item replaced with ${replacementProduct!.nameEn}.'),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: Text(context.tr('confirm_replacement')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _scanItemForPacking(OnlineOrder order) {
    final barcode = _scanCtrl.text.trim();
    if (barcode.isEmpty) return;

    final match = order.items.any((i) => i.barcode == barcode || i.code.toLowerCase() == barcode.toLowerCase());
    if (match) {
      PosStateManager.instance.scanOnlineOrderItem(order.orderId, barcode);
      _scanCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item scanned and verified in packing bin.'),
          backgroundColor: AppColors.emerald,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('scan_no_match')),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([state, AppController.instance]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final orders = state.onlineOrders.where((o) {
          if (_statusFilter == 'PENDING') return o.status == 'Pending';
          if (_statusFilter == 'PREPARING') return o.status == 'Preparing';
          if (_statusFilter == 'DELIVERY') return o.status == 'Out for Delivery';
          if (_statusFilter == 'CANCELLED') return o.status == 'Cancelled';
          return true;
        }).toList();

        final pendingCount = state.onlineOrders.where((o) => o.status == 'Pending').length;
        final preparingCount = state.onlineOrders.where((o) => o.status == 'Preparing').length;
        final deliveryCount = state.onlineOrders.where((o) => o.status == 'Out for Delivery').length;

        final activeSelected = _selectedOrder != null
            ? state.onlineOrders.firstWhere((o) => o.orderId == _selectedOrder!.orderId, orElse: () => state.onlineOrders.first)
            : (orders.isNotEmpty ? orders.first : null);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top KPI Summary Cards
              Row(
                children: [
                  _buildMetricCard(
                    title: context.tr('kpi_pending_online'),
                    value: '$pendingCount ${context.tr('kpi_orders_unit')}',
                    subvalue: context.tr('order_pending_desc'),
                    icon: Icons.notifications_active_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: context.tr('kpi_preparing_online'),
                    value: '$preparingCount ${context.tr('kpi_in_prep_unit')}',
                    subvalue: context.tr('order_preparing_desc'),
                    icon: Icons.inventory_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: context.tr('kpi_delivery_online'),
                    value: '$deliveryCount ${context.tr('kpi_en_route_unit')}',
                    subvalue: context.tr('order_delivery_desc'),
                    icon: Icons.delivery_dining_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Bar
              Row(
                children: [
                  _buildFilterPill('ALL', '${context.tr('filter_all_orders')} (${state.onlineOrders.length})', isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('PENDING', '${context.tr('filter_pending')} ($pendingCount)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('PREPARING', '${context.tr('filter_preparing')} ($preparingCount)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('DELIVERY', '${context.tr('filter_delivery')} ($deliveryCount)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('CANCELLED', context.tr('filter_cancelled'), isDark),
                ],
              ),
              const SizedBox(height: 20),

              // Split Layout: Order Roster (Left) + Selected Order Details & Packing (Right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left List
                  Expanded(
                    flex: 5,
                    child: orders.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            alignment: Alignment.center,
                            decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                            child: Text(
                              context.tr('no_orders_match'),
                              style: TextStyle(color: isDark ? AppColors.textMuted : Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final isSelected = activeSelected?.orderId == order.orderId;

                              return Container(
                                decoration: AppDecorations.cyborgCard(
                                  radius: 14,
                                  borderColor: isSelected ? AppColors.neonCyan : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                                  glow: isSelected && isDark,
                                  isDark: isDark,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedOrder = order),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                order.orderId,
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.neonCyan,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              _buildStatusBadge(order.status),
                                              const Spacer(),
                                              Text(
                                                '${order.total.toStringAsFixed(2)} EGP',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.person, size: 14, color: isDark ? AppColors.textMuted : Colors.black45),
                                              const SizedBox(width: 6),
                                              Text(
                                                order.customerName,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(Icons.phone, size: 14, color: isDark ? AppColors.textMuted : Colors.black45),
                                              const SizedBox(width: 6),
                                              Text(
                                                order.customerPhone,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark ? AppColors.textSecondary : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined, size: 14, color: isDark ? AppColors.textMuted : Colors.black45),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  order.customerAddress,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? AppColors.textMuted : Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.amber.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  order.paymentMethod,
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.amber),
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${order.totalItemCount} items',
                                                style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(width: 24),

                  // Right Details & Dispatch Section
                  Expanded(
                    flex: 6,
                    child: activeSelected == null
                        ? Container(
                            height: 400,
                            alignment: Alignment.center,
                            decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                            child: Text(
                              context.tr('select_order_hint'),
                              style: TextStyle(color: isDark ? AppColors.textMuted : Colors.black54),
                            ),
                          )
                        : _buildOrderInspectPanel(activeSelected, isDark),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderInspectPanel(OnlineOrder order, bool isDark) {
    final state = PosStateManager.instance;
    final isPending = order.status == 'Pending';
    final isPreparing = order.status == 'Preparing';
    final isOutForDelivery = order.status == 'Out for Delivery';
    final isCancelled = order.status == 'Cancelled';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cyborgCard(
        radius: 16,
        borderColor: AppColors.borderCyan,
        glow: isDark,
        isDark: isDark,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_rounded, color: AppColors.neonCyan, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${context.tr('order_number')}${order.orderId}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('payment_cod_notice'),
                      style: const TextStyle(fontSize: 12, color: AppColors.amber, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Accept / Reject buttons if pending
              if (isPending) ...[
                OutlinedButton(
                  onPressed: () => _showRejectDialog(order, isDark),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose,
                    side: const BorderSide(color: AppColors.rose),
                  ),
                  child: Text(context.tr('reject_order')),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => state.acceptOnlineOrder(order.orderId),
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(context.tr('accept_order')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Customer Profile Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('customer_info'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMuted : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('${context.tr('label_phone')}: ${order.customerPhone}', style: const TextStyle(fontSize: 12, color: AppColors.neonCyan)),
                          if (order.customerEmail != null)
                            Text(
                              '${context.tr('label_email')}: ${order.customerEmail}',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : Colors.black54),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('delivery_address'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textMuted : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.customerAddress,
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (order.replacementNotes != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                    ),
                    child: Text('Note: ${order.replacementNotes}', style: const TextStyle(fontSize: 11, color: AppColors.amber)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Packing Barcode Scanner if Preparing
          if (isPreparing) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceLight.withOpacity(0.5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: AppColors.neonCyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _scanCtrl,
                      onSubmitted: (_) => _scanItemForPacking(order),
                      style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                      decoration: InputDecoration(
                        hintText: context.tr('scan_packing_hint'),
                        hintStyle: TextStyle(color: isDark ? AppColors.textMuted : Colors.black38),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _scanItemForPacking(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: Text(context.tr('verify_item')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Ordered Items Table
          Text(
            context.tr('ordered_products'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMuted : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = order.items[index];

                return ListTile(
                  dense: true,
                  leading: isPreparing
                      ? Icon(
                          item.isScanned ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: item.isScanned ? AppColors.emerald : AppColors.textMuted,
                          size: 20,
                        )
                      : null,
                  title: Text(
                    item.nameEn,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    '${item.code} • ${context.tr('label_barcode')}: ${item.barcode} • ${item.quantity}x @ ${item.unitPrice.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.lineTotal.toStringAsFixed(2)} EGP',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.neonCyan),
                      ),
                      if (isPreparing) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => _showMissingItemDialog(context, order, item, isDark),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            side: const BorderSide(color: AppColors.amber),
                            foregroundColor: AppColors.amber,
                          ),
                          child: Text(context.tr('missing_item'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Total Breakdown Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.tr('subtotal')}: ${order.subtotal.toStringAsFixed(2)} EGP  •  ${context.tr('vat_tax')}: ${order.tax.toStringAsFixed(2)} EGP',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : Colors.black54),
              ),
              Text(
                '${context.tr('grand_total')} (${context.tr('label_cod')}): ${order.total.toStringAsFixed(2)} EGP',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.neonCyan),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Ready & Dispatch Action
          if (isPreparing) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  state.dispatchOnlineOrder(order.orderId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('dispatch_snackbar').replaceFirst('{id}', order.orderId)),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                },
                icon: const Icon(Icons.print_rounded, size: 18),
                label: Text(context.tr('print_and_dispatch')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ),
          ] else if (isOutForDelivery) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining_rounded, color: AppColors.emerald),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('dispatched_notice'),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isCancelled) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.rose.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: AppColors.rose),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${context.tr('order_cancelled_label')}: ${order.cancelReason ?? context.tr('rejected_by_cashier')}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.rose),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRejectDialog(OnlineOrder order, bool isDark) {
    final reasonCtrl = TextEditingController(text: 'Address outside courier coverage zone');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          title: Text(
            '${context.tr('reject_order_title')} #${order.orderId}?',
            style: TextStyle(color: isDark ? AppColors.textWhite : const Color(0xFF0F172A), fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: reasonCtrl,
            style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
            decoration: AppDecorations.searchField(hint: context.tr('reject_reason_hint'), isDark: isDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel'), style: const TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                PosStateManager.instance.rejectOnlineOrder(order.orderId, reasonCtrl.text.trim());
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose, foregroundColor: Colors.white),
              child: Text(context.tr('confirm_reject'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String displayKey;
    switch (status) {
      case 'Pending':
        color = AppColors.neonCyan;
        displayKey = 'status_pending';
        break;
      case 'Preparing':
        color = AppColors.amber;
        displayKey = 'status_preparing';
        break;
      case 'Out for Delivery':
        color = AppColors.emerald;
        displayKey = 'status_out_for_delivery';
        break;
      case 'Cancelled':
        color = AppColors.rose;
        displayKey = 'status_cancelled';
        break;
      default:
        color = AppColors.textMuted;
        displayKey = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: AppDecorations.badge(color: color),
      child: Text(
        context.tr(displayKey).toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildFilterPill(String key, String label, bool isDark) {
    final isSelected = _statusFilter == key;
    return InkWell(
      onTap: () => setState(() => _statusFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withOpacity(isDark ? 0.18 : 0.12)
              : (isDark ? AppColors.surface : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? AppColors.neonCyan
                : (isDark ? AppColors.textSecondary : Colors.black87),
          ),
        ),
      ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textMuted : Colors.black54,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
