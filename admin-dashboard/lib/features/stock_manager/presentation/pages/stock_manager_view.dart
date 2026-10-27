import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Stock Manager Dashboard / Warehouse Approval Console.
class StockManagerView extends StatefulWidget {
  final VoidCallback onLogout;

  const StockManagerView({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<StockManagerView> createState() => _StockManagerViewState();
}

class _StockManagerViewState extends State<StockManagerView> {
  void _approveRequest(StockReorderRequest req) {
    showDialog(
      context: context,
      builder: (ctx) {
        final noteCtrl = TextEditingController(text: 'Purchase Order PO-2026-993 approved and dispatched to supplier');
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.emerald),
          ),
          title: Text('Approve Reorder: ${req.productName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Required Quantity: ${req.requiredQuantity} units'),
              const SizedBox(height: 12),
              const Text('DISPATCH NOTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: noteCtrl,
                decoration: AppDecorations.searchField(hint: 'Enter approval note'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                PosStateManager.instance.approveStoreReorder(
                  req.requestId,
                  note: noteCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reorder request for ${req.productName} APPROVED.'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              child: const Text('CONFIRM APPROVAL'),
            ),
          ],
        );
      },
    );
  }

  void _denyRequest(StockReorderRequest req) {
    showDialog(
      context: context,
      builder: (ctx) {
        final reasonCtrl = TextEditingController(text: 'Supplier out of raw materials until next Tuesday');
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.rose),
          ),
          title: Text('Deny Reorder: ${req.productName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('REASON FOR DENIAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                decoration: AppDecorations.searchField(hint: 'Explain reason for denial'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                PosStateManager.instance.denyStoreReorder(
                  req.requestId,
                  reasonCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reorder request for ${req.productName} DENIED.'),
                    backgroundColor: AppColors.rose,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
              child: const Text('CONFIRM DENIAL'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final pendingRequests =
                state.reorderRequests.where((r) => r.status.contains('Pending')).toList();
            final completedRequests =
                state.reorderRequests.where((r) => !r.status.contains('Pending')).toList();

            return Column(
              children: [
                // Top Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.electricPurple,
                        ),
                        child: const Icon(Icons.warehouse_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CYBORG SUPERMARKET — WAREHOUSE & STOCK DESK',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textWhite),
                          ),
                          Text(
                            'STOCK MANAGER APPROVAL CONSOLE',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.electricPurpleLight),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Stock Manager profile badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.electricPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.electricPurple.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, size: 14, color: AppColors.electricPurpleLight),
                            SizedBox(width: 6),
                            Text(
                              'Hossam El-Din  •  Stock Manager',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.electricPurpleLight),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text('SWITCH ROLE'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neonCyan,
                          side: const BorderSide(color: AppColors.borderCyan),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metric Cards
                        Row(
                          children: [
                            _buildMetricCard(
                              title: 'PENDING APPROVAL REQUESTS',
                              value: '${pendingRequests.length} Pending Requests',
                              subvalue: 'Sent by Store Manager',
                              icon: Icons.hourglass_top_rounded,
                              accentColor: AppColors.amber,
                            ),
                            const SizedBox(width: 16),
                            _buildMetricCard(
                              title: 'WAREHOUSE BAY STATUS',
                              value: 'Bay 1 & Bay 2 Ready',
                              subvalue: 'Forklift active & receiving shipments',
                              icon: Icons.store_mall_directory_rounded,
                              accentColor: AppColors.electricPurpleLight,
                            ),
                            const SizedBox(width: 16),
                            _buildMetricCard(
                              title: 'TOTAL PRODUCTS IN CATALOG',
                              value: '${state.products.length} SKUs',
                              subvalue: 'Synchronized with POS system',
                              icon: Icons.checklist_rounded,
                              accentColor: AppColors.neonCyan,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Section 1: Pending Requests Awaiting Approval
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_rounded, color: AppColors.amber, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Pending Reorder Requests from Store Manager (${pendingRequests.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textWhite),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (pendingRequests.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            alignment: Alignment.center,
                            decoration: AppDecorations.cyborgCard(radius: 12),
                            child: const Column(
                              children: [
                                Icon(Icons.check_circle_outline, size: 40, color: AppColors.emerald),
                                SizedBox(height: 10),
                                Text(
                                  'All Stock Reorder Requests Processed!',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textWhite),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No pending approval/denial reorders from the store manager.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        else
                          ...pendingRequests.map((req) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: AppDecorations.cyborgCard(
                                radius: 14,
                                borderColor: AppColors.amber.withOpacity(0.5),
                                glow: true,
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
                                              req.productName,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textWhite),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.border),
                                              ),
                                              child: Text(req.productCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Requested by: ${req.requestedBy}  •  Barcode: ${req.productBarcode}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              'Current POS Stock: ${req.currentStock} units',
                                              style: const TextStyle(fontSize: 12, color: AppColors.rose, fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(width: 14),
                                            Text(
                                              'Requested Reorder: +${req.requiredQuantity} units',
                                              style: const TextStyle(fontSize: 13, color: AppColors.neonCyan, fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action Buttons: Approve / Deny
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _denyRequest(req),
                                        icon: const Icon(Icons.close_rounded, size: 16),
                                        label: const Text('DENY REQUEST'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.rose,
                                          side: const BorderSide(color: AppColors.rose),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () => _approveRequest(req),
                                        icon: const Icon(Icons.check_rounded, size: 16),
                                        label: const Text('APPROVE REORDER'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.emerald,
                                          foregroundColor: AppColors.textOnAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 32),

                        // Section 2: Completed / Decided Requests Log
                        const Row(
                          children: [
                            Icon(Icons.history_edu_rounded, color: AppColors.neonCyan, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Processed Reorder Decisions History',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textWhite),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Container(
                          decoration: AppDecorations.cyborgCard(radius: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(AppColors.surface),
                              dataRowColor: MaterialStateProperty.all(AppColors.card),
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text('REQUEST ID', style: TextStyle(fontWeight: FontWeight.w800))),
                                DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.w800))),
                                DataColumn(label: Text('REORDER QTY', style: TextStyle(fontWeight: FontWeight.w800))),
                                DataColumn(label: Text('DECISION', style: TextStyle(fontWeight: FontWeight.w800))),
                                DataColumn(label: Text('REVIEWED BY', style: TextStyle(fontWeight: FontWeight.w800))),
                                DataColumn(label: Text('DECISION NOTE', style: TextStyle(fontWeight: FontWeight.w800))),
                              ],
                              rows: completedRequests.map((req) {
                                final isApproved = req.status == 'Approved';
                                final color = isApproved ? AppColors.emerald : AppColors.rose;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(req.requestId, style: const TextStyle(color: AppColors.neonCyan, fontFamily: 'monospace'))),
                                    DataCell(Text(req.productName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textWhite))),
                                    DataCell(Text('+${req.requiredQuantity} units', style: const TextStyle(fontWeight: FontWeight.w800))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: AppDecorations.badge(color: color),
                                        child: Text(
                                          req.status.toUpperCase(),
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(req.reviewedBy ?? 'Stock Mgr', style: const TextStyle(fontSize: 12))),
                                    DataCell(Text(req.decisionNote ?? '-', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.cyborgCard(radius: 14),
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
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subvalue,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
