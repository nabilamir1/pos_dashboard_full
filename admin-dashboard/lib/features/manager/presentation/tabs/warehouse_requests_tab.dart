import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/localization/app_localizations.dart';

/// Tab for Store Manager to review, approve, or deny warehouse restock requests
/// sent by the Stock Manager when warehouse supplies fall below safe thresholds.
class WarehouseRequestsTab extends StatefulWidget {
  const WarehouseRequestsTab({super.key});

  @override
  State<WarehouseRequestsTab> createState() => _WarehouseRequestsTabState();
}

class _WarehouseRequestsTabState extends State<WarehouseRequestsTab> {
  String _statusFilter = 'ALL';

  void _showApproveDialog(BuildContext context, WarehouseRestockRequest req) {
    final noteCtrl = TextEditingController(
      text: 'PO-2026-AUTH: Approved by Store Manager for supplier dispatch.',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.emerald, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.emerald, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${ctx.tr('approve')}: ${req.productName}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _dialogRow('Request ID:', req.requestId, isDark),
                    const SizedBox(height: 6),
                    _dialogRow('Barcode / SKU:', '${req.productBarcode} (${req.productCode})', isDark),
                    const SizedBox(height: 6),
                    _dialogRow('Current Warehouse Stock:', '${req.currentWarehouseStock} units', isDark),
                    const SizedBox(height: 6),
                    _dialogRow('Requested Replenishment:', '+${req.requestedQuantity} units', isDark, isHighlight: true),
                    const SizedBox(height: 6),
                    _dialogRow('Supplier / Vendor:', req.supplier, isDark),
                    const SizedBox(height: 6),
                    _dialogRow('Requested By:', req.requestedBy, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ctx.tr('approval_note'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: isDark ? AppColors.textMuted : Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: noteCtrl,
                style: TextStyle(
                  color: isDark ? AppColors.textWhite : Colors.black87,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter purchase order authorization note...',
                  filled: true,
                  fillColor: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.tr('cancel'), style: const TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                PosStateManager.instance.approveWarehouseRestockRequest(
                  req.requestId,
                  note: noteCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Warehouse restock ${req.requestId} APPROVED! Supplier order released.'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(ctx.tr('confirm_approval')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDenyDialog(BuildContext context, WarehouseRestockRequest req) {
    final reasonCtrl = TextEditingController(
      text: 'Budget constraint for current fiscal quarter. Postponed to next month.',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.rose, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_rounded,
                    color: AppColors.rose, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${ctx.tr('deny')}: ${req.productName}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Provide reason for rejection to notify Stock Manager:',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ctx.tr('denial_reason'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: isDark ? AppColors.textMuted : Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                style: TextStyle(
                  color: isDark ? AppColors.textWhite : Colors.black87,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter reason for rejection...',
                  filled: true,
                  fillColor: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.tr('cancel'), style: const TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                PosStateManager.instance.denyWarehouseRestockRequest(
                  req.requestId,
                  reasonCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Warehouse restock ${req.requestId} REJECTED.'),
                    backgroundColor: AppColors.rose,
                  ),
                );
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(ctx.tr('confirm_denial')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
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
        final allRequests = state.warehouseRestockRequests;
        final pendingRequests = allRequests
            .where((r) => r.status.contains('Awaiting'))
            .toList();
        final approvedRequests =
            allRequests.where((r) => r.status == 'Approved').toList();
        final rejectedRequests =
            allRequests.where((r) => r.status == 'Rejected').toList();

        final filteredRequests = allRequests.where((r) {
          if (_statusFilter == 'PENDING') return r.status.contains('Awaiting');
          if (_statusFilter == 'APPROVED') return r.status == 'Approved';
          if (_statusFilter == 'REJECTED') return r.status == 'Rejected';
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top KPI Overview Cards ─────────────────────────────────────
              Row(
                children: [
                  _buildMetricCard(
                    title: context.tr('kpi_pending_approvals'),
                    value: '${pendingRequests.length} Pending',
                    subvalue: 'Sent by Stock Manager',
                    icon: Icons.hourglass_top_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: context.tr('kpi_approved_reorders'),
                    value: '${approvedRequests.length} Authorized',
                    subvalue: 'Supplier Purchase Orders released',
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: context.tr('kpi_denied_reorders'),
                    value: '${rejectedRequests.length} Rejected',
                    subvalue: 'Requests denied with remarks',
                    icon: Icons.cancel_outlined,
                    accentColor: AppColors.rose,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Filter Toolbar ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.neonCyan, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${context.tr('filter')}:',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark ? AppColors.textWhite : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildFilterChip('ALL', '${context.tr('all')} (${allRequests.length})', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('PENDING', '${context.tr('pending')} (${pendingRequests.length})', isDark, color: AppColors.amber),
                    const SizedBox(width: 8),
                    _buildFilterChip('APPROVED', '${context.tr('approved')} (${approvedRequests.length})', isDark, color: AppColors.emerald),
                    const SizedBox(width: 8),
                    _buildFilterChip('REJECTED', 'Rejected (${rejectedRequests.length})', isDark, color: AppColors.rose),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Pending Action Items ───────────────────────────────────────
              if (pendingRequests.isNotEmpty && (_statusFilter == 'ALL' || _statusFilter == 'PENDING')) ...[
                Row(
                  children: [
                    const Icon(Icons.notification_important_rounded, color: AppColors.amber, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Action Required: Warehouse Restock Requests from Stock Manager (${pendingRequests.length})',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pendingRequests.map((req) => _buildPendingCard(req, isDark)),
                const SizedBox(height: 28),
              ],

              // ── Requests History Table ─────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.history_rounded, color: AppColors.neonCyan, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Warehouse Restock Decisions History (${filteredRequests.length})',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (filteredRequests.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                  child: Text(
                    'No warehouse restock requests found matching filter "$_statusFilter".',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
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
                          headingRowColor: MaterialStateProperty.all(
                            isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                          ),
                          dataRowColor: MaterialStateProperty.all(
                            isDark ? AppColors.card : Colors.white,
                          ),
                          columnSpacing: 24,
                          columns: [
                            DataColumn(label: Text(context.tr('col_req_id'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_product'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_barcode'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_wh_stock'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_qty'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_supplier'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_status'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_decision'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                            DataColumn(label: Text(context.tr('col_actions'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          ],
                          rows: filteredRequests.map((req) {
                            final isPending = req.status.contains('Awaiting');
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
                                      Text(
                                        'Code: ${req.productCode}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
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
                                  SizedBox(
                                    width: 220,
                                    child: Text(
                                      req.decisionNote ?? (isPending ? 'Pending Manager review' : '-'),
                                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  isPending
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 22),
                                              tooltip: 'Approve Restock',
                                              onPressed: () => _showApproveDialog(context, req),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.cancel_rounded, color: AppColors.rose, size: 22),
                                              tooltip: 'Deny Restock',
                                              onPressed: () => _showDenyDialog(context, req),
                                            ),
                                          ],
                                        )
                                      : const Icon(Icons.check_rounded, color: AppColors.textMuted, size: 18),
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

  Widget _buildPendingCard(WarehouseRestockRequest req, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.amber.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warehouse_rounded, color: AppColors.amber, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      req.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        req.productCode,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neonCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Supplier: ${req.supplier}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.electricPurpleLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Barcode: ${req.productBarcode}  •  Requested by: ${req.requestedBy}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Warehouse Reserve: ${req.currentWarehouseStock} units',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rose,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Requested Inbound: +${req.requestedQuantity} units',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.neonCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showDenyDialog(context, req),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: Text(context.tr('deny')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.rose,
                  side: const BorderSide(color: AppColors.rose),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showApproveDialog(context, req),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text(context.tr('approve')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark, {Color color = AppColors.neonCyan}) {
    final isSelected = _statusFilter == key;
    return InkWell(
      onTap: () => setState(() => _statusFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : (isDark ? AppColors.surface : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.black : (isDark ? AppColors.textWhite : Colors.black87),
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
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(isDark ? 0.12 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subvalue,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondary : Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
