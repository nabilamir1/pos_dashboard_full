import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab 7: Audit & Receipts Log Tab
/// Complete history table showing receipts and logs for every warehouse action:
/// requests approved/denied, products added, restocks imported, deliveries fulfilled.
class AuditReceiptsLogTab extends StatefulWidget {
  const AuditReceiptsLogTab({super.key});

  @override
  State<AuditReceiptsLogTab> createState() => _AuditReceiptsLogTabState();
}

class _AuditReceiptsLogTabState extends State<AuditReceiptsLogTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedActionFilter = 'ALL';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'REQUEST_APPROVED':
      case 'RESTOCK_IMPORTED':
        return AppColors.emerald;
      case 'REQUEST_DENIED':
      case 'DAMAGED_DEDUCTED':
        return AppColors.rose;
      case 'FULFILLED':
      case 'ORDER_DISPATCHED':
        return AppColors.neonCyan;
      case 'PRODUCT_ADDED':
        return AppColors.electricPurpleLight;
      case 'WH_RESTOCK_REQUESTED':
        return AppColors.amber;
      default:
        return AppColors.neonCyan;
    }
  }

  String _formatActionType(String actionType) {
    return actionType.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final allLogs = state.auditLogs;
        final query = _searchCtrl.text.trim().toLowerCase();

        final filteredLogs = allLogs.where((log) {
          final matchesFilter = _selectedActionFilter == 'ALL' ||
              log.actionType == _selectedActionFilter;
          final matchesSearch = query.isEmpty ||
              log.logId.toLowerCase().contains(query) ||
              log.productName.toLowerCase().contains(query) ||
              log.barcode.contains(query) ||
              log.referenceNo.toLowerCase().contains(query) ||
              log.performedBy.toLowerCase().contains(query) ||
              log.notes.toLowerCase().contains(query);
          return matchesFilter && matchesSearch;
        }).toList();

        final totalActions = allLogs.length;
        final approvedCount = allLogs.where((l) => l.actionType == 'REQUEST_APPROVED').length;
        final restockCount = allLogs.where((l) => l.actionType == 'RESTOCK_IMPORTED').length;
        final dispatchCount = allLogs.where((l) => l.actionType == 'FULFILLED' || l.actionType == 'ORDER_DISPATCHED').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── KPI Summary Cards ──────────────────────────────────────────
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL AUDIT ACTIONS',
                    value: '$totalActions Logs',
                    subvalue: 'Immutable warehouse event trail',
                    icon: Icons.history_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'APPROVED REORDERS',
                    value: '$approvedCount Requests',
                    subvalue: 'Stock Manager approvals',
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'INBOUND RESTOCKS',
                    value: '$restockCount Shipments',
                    subvalue: 'Supplier deliveries received',
                    icon: Icons.archive_rounded,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'OUTBOUND DISPATCHES',
                    value: '$dispatchCount Deliveries',
                    subvalue: 'Store floor & courier orders',
                    icon: Icons.local_shipping_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Filter & Search Toolbar ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              color: isDark ? AppColors.textWhite : Colors.black87,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search audit trail by Log ID, Product, Barcode, PO/Receipt Ref...',
                              hintStyle: TextStyle(
                                color: isDark ? AppColors.textMuted : Colors.black45,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neonCyan, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Audit report exported to CSV & printed!'),
                                backgroundColor: AppColors.neonCyan,
                              ),
                            );
                          },
                          icon: const Icon(Icons.print_rounded, size: 16),
                          label: const Text('EXPORT AUDIT REPORT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Filter Action Chips
                    Row(
                      children: [
                        Text(
                          'Action Type:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textMuted : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip('ALL', 'All Events', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('REQUEST_APPROVED', 'Approvals', isDark, color: AppColors.emerald),
                        const SizedBox(width: 8),
                        _buildFilterChip('FULFILLED', 'Store Deliveries', isDark, color: AppColors.neonCyan),
                        const SizedBox(width: 8),
                        _buildFilterChip('RESTOCK_IMPORTED', 'Inbound Restocks', isDark, color: AppColors.electricPurpleLight),
                        const SizedBox(width: 8),
                        _buildFilterChip('PRODUCT_ADDED', 'New SKUs', isDark, color: AppColors.amber),
                        const SizedBox(width: 8),
                        _buildFilterChip('REQUEST_DENIED', 'Denials', isDark, color: AppColors.rose),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Audit Table ────────────────────────────────────────────────
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
                          DataColumn(label: Text('LOG ID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('ITEM / PRODUCT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('QTY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('PERFORMED BY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('REFERENCE NO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('TIME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('NOTES / REMARKS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        ],
                        rows: filteredLogs.map((log) {
                          final color = _getActionColor(log.actionType);

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  log.logId,
                                  style: const TextStyle(
                                    color: AppColors.neonCyan,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: color.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    _formatActionType(log.actionType),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                    ),
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
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: isDark ? AppColors.textWhite : Colors.black87,
                                      ),
                                    ),
                                    if (log.barcode.isNotEmpty)
                                      Text(log.barcode, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${log.quantity} units',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                              DataCell(Text(log.performedBy, style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Text(
                                  log.referenceNo,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.neonCyan),
                                ),
                              ),
                              DataCell(
                                Text(
                                  log.timestamp.toString().substring(11, 16),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 240,
                                  child: Text(
                                    log.notes,
                                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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

  Widget _buildFilterChip(String key, String label, bool isDark, {Color color = AppColors.neonCyan}) {
    final isSelected = _selectedActionFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedActionFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : Colors.black45),
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
