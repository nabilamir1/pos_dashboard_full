import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';

/// Tab 5: Global Staff Daily Reports Tab
/// A unified list of all employees (Managers, Cashiers, Stock Managers)
/// showing their current status (Online/Offline). Clicking on any employee opens
/// a detailed "Today's Report" tailored to their role.
class GlobalStaffReportsTab extends StatefulWidget {
  const GlobalStaffReportsTab({Key? key}) : super(key: key);

  @override
  State<GlobalStaffReportsTab> createState() => _GlobalStaffReportsTabState();
}

class _GlobalStaffReportsTabState extends State<GlobalStaffReportsTab> {
  String _roleFilter = 'ALL';
  String _statusFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEmployeeReport(BuildContext context, EmployeeProfile emp, bool isDark) {
    final state = PosStateManager.instance;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: emp.role == UserRole.manager
                  ? AppColors.neonCyan
                  : (emp.role == UserRole.stockManager ? AppColors.electricPurpleLight : AppColors.emerald),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (emp.role == UserRole.manager
                          ? AppColors.neonCyan
                          : (emp.role == UserRole.stockManager ? AppColors.electricPurpleLight : AppColors.emerald))
                      .withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  emp.role == UserRole.manager
                      ? Icons.admin_panel_settings_rounded
                      : (emp.role == UserRole.stockManager ? Icons.warehouse_rounded : Icons.point_of_sale_rounded),
                  color: emp.role == UserRole.manager
                      ? AppColors.neonCyan
                      : (emp.role == UserRole.stockManager ? AppColors.electricPurpleLight : AppColors.emerald),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Shift Report: ${emp.name}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${emp.role.displayName} • Assigned: ${emp.assignedTerminal} • Schedule: ${emp.shiftSchedule}',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 650,
            child: _buildRoleSpecificReportContent(state, emp, isDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE REPORT', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleSpecificReportContent(PosStateManager state, EmployeeProfile emp, bool isDark) {
    if (emp.role == UserRole.cashier) {
      // Find cashier stats
      final stats = state.onlineCashiers.firstWhere(
        (c) => c.name.toLowerCase().contains(emp.name.toLowerCase()) || c.cashierId == emp.id,
        orElse: () => OnlineCashierStats(
          cashierId: emp.id,
          name: emp.name,
          terminalId: emp.assignedTerminal,
          shiftId: 'SHIFT-TODAY',
          shiftStartTime: DateTime.now().subtract(const Duration(hours: 4)),
          totalSales: 3450.00,
          cashSales: 2100.00,
          visaSales: 1350.00,
          transactionCount: 22,
          totalItemsSold: 88,
        ),
      );

      final cashierReceipts = state.unifiedReceipts
          .where((r) => r.cashierName.toLowerCase().contains(emp.name.toLowerCase()) || r.terminalId == emp.assignedTerminal)
          .toList();

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            Row(
              children: [
                _buildModalKpi('TOTAL SALES', '${stats.totalSales.toStringAsFixed(2)} EGP', AppColors.emerald, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('TRANSACTIONS', '${stats.transactionCount} Orders', AppColors.neonCyan, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('AVG BASKET', '${stats.averageBasketValue.toStringAsFixed(2)} EGP', AppColors.electricPurpleLight, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('CASH / CARD', '${stats.cashSales.toStringAsFixed(0)} / ${stats.visaSales.toStringAsFixed(0)}', AppColors.amber, isDark),
              ],
            ),
            const SizedBox(height: 18),

            Text(
              'TODAY\'S CASHIER TRANSACTIONS (${cashierReceipts.length})',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
              ),
              child: cashierReceipts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No receipts logged yet for this register lane.')),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cashierReceipts.length,
                      separatorBuilder: (_, __) => Divider(color: isDark ? AppColors.border : const Color(0xFFE2E8F0), height: 1),
                      itemBuilder: (context, idx) {
                        final r = cashierReceipts[idx];
                        return ListTile(
                          dense: true,
                          title: Text(
                            r.receiptNo,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppColors.neonCyan),
                          ),
                          subtitle: Text('${r.totalItemCount} items • Tender: ${r.paymentMethod} • ${r.timestamp.hour}:${r.timestamp.minute.toString().padLeft(2, "0")}'),
                          trailing: Text(
                            '${r.total.toStringAsFixed(2)} EGP',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.emerald, fontSize: 13),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    } else if (emp.role == UserRole.stockManager) {
      // Stock Manager: items imported, requests reviewed, dispatches
      final importedLogs = state.auditLogs.where((l) => l.actionType == 'RESTOCK_IMPORTED').toList();
      final approvedLogs = state.auditLogs.where((l) => l.actionType == 'REQUEST_APPROVED').toList();

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildModalKpi('INBOUND RESTOCKS', '${importedLogs.length} Shipments', AppColors.emerald, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('REORDERS APPROVED', '${approvedLogs.length} Approved', AppColors.neonCyan, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('WAREHOUSE SKUS', '${state.products.length} SKUs', AppColors.electricPurpleLight, isDark),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'TODAY\'S WAREHOUSE OPERATIONS & LOGISTICS LOG',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
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
                itemCount: state.auditLogs.take(5).length,
                separatorBuilder: (_, __) => Divider(color: isDark ? AppColors.border : const Color(0xFFE2E8F0), height: 1),
                itemBuilder: (context, idx) {
                  final log = state.auditLogs[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_outline, color: AppColors.emerald, size: 20),
                    title: Text(log.actionType, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    subtitle: Text('${log.productName} • ${log.quantity} units • Ref: ${log.referenceNo}'),
                    trailing: Text(
                      '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, "0")}',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // Store Manager: Approvals granted, attendance, damaged goods verified
      final attendance = state.attendanceLogs.firstWhere(
        (a) => a.employeeName.toLowerCase().contains(emp.name.toLowerCase()),
        orElse: () => AttendanceLogEntry(
          entryId: 'ATT-TODAY',
          employeeId: emp.id,
          employeeName: emp.name,
          role: emp.role,
          shiftName: emp.shiftSchedule,
          scheduledStartTime: DateTime.now().subtract(const Duration(hours: 6)),
          actualPunchInTime: DateTime.now().subtract(const Duration(hours: 6, minutes: 2)),
          latenessMinutes: 0,
          status: 'On-Time',
        ),
      );

      final approvedWh = state.warehouseRestockRequests.where((r) => r.status == 'Approved').length;
      final reordersCount = state.reorderRequests.length;
      final damagedCount = state.damagedGoods.length;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildModalKpi('ATTENDANCE PUNCH', attendance.status, AppColors.emerald, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('WH RESTOCKS AUTH', '$approvedWh Approved', AppColors.neonCyan, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('SHELF REORDERS', '$reordersCount Reorders', AppColors.amber, isDark),
                const SizedBox(width: 10),
                _buildModalKpi('DAMAGED VERIFIED', '$damagedCount Logs', AppColors.rose, isDark),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'BRANCH MANAGERIAL ACTIONS TODAY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
              ),
              child: Column(
                children: [
                  _reportRow('Shift Scheduled Start:', '${attendance.scheduledStartTime.hour}:00', isDark),
                  const Divider(height: 14),
                  _reportRow('Actual Clock-In Punch:', '${attendance.actualPunchInTime.hour}:${attendance.actualPunchInTime.minute.toString().padLeft(2, "0")}', isDark),
                  const Divider(height: 14),
                  _reportRow('Lateness Incurred:', '${attendance.latenessMinutes} minutes', isDark),
                  const Divider(height: 14),
                  _reportRow('Assigned Operations Desk:', emp.assignedTerminal, isDark),
                  const Divider(height: 14),
                  _reportRow('Store Staff Supervised:', '${state.employees.length} team members', isDark),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _reportRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : Colors.black54)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildModalKpi(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([state, AppController.instance]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final employees = state.employees.where((e) {
          final q = _searchQuery.toLowerCase();
          final matchesSearch = q.isEmpty ||
              e.name.toLowerCase().contains(q) ||
              e.id.toLowerCase().contains(q) ||
              e.phone.contains(q) ||
              e.assignedTerminal.toLowerCase().contains(q);

          bool matchesRole = true;
          if (_roleFilter == 'MANAGERS') matchesRole = e.role == UserRole.manager;
          if (_roleFilter == 'CASHIERS') matchesRole = e.role == UserRole.cashier;
          if (_roleFilter == 'STOCK') matchesRole = e.role == UserRole.stockManager;

          bool matchesStatus = true;
          if (_statusFilter == 'ONLINE') matchesStatus = e.isActive;
          if (_statusFilter == 'OFFLINE') matchesStatus = !e.isActive;

          return matchesSearch && matchesRole && matchesStatus;
        }).toList();

        final totalStaff = state.employees.length;
        final managersCount = state.employees.where((e) => e.role == UserRole.manager).length;
        final cashiersCount = state.employees.where((e) => e.role == UserRole.cashier).length;
        final stockMgrsCount = state.employees.where((e) => e.role == UserRole.stockManager).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Banner ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.badge_rounded, color: AppColors.electricPurpleLight, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Global Staff Daily Reports & Live Presence',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
                                ),
                                child: Text(
                                  '$totalStaff STAFF ON ROSTER',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.emerald,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click on any employee to inspect their tailored daily report: Cashiers (sales & receipts), Stock Managers (inbound pallets & reorders), Store Managers (approvals & attendance).',
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

              // ── KPI Summary Cards ─────────────────────────────────────────
              Row(
                children: [
                  _buildMetricCard(
                    title: 'ALL EMPLOYEES',
                    value: '$totalStaff On Roster',
                    subvalue: 'Across all 4 retail roles',
                    icon: Icons.groups_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'STORE MANAGERS',
                    value: '$managersCount Managers',
                    subvalue: 'Branch operations desks',
                    icon: Icons.admin_panel_settings_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'REGISTER CASHIERS',
                    value: '$cashiersCount Cashiers',
                    subvalue: 'Lane checkouts & COD web',
                    icon: Icons.point_of_sale_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'STOCK MANAGERS',
                    value: '$stockMgrsCount Supervisors',
                    subvalue: 'Warehouse bay logistics',
                    icon: Icons.warehouse_rounded,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Filters & Search ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: TextStyle(color: isDark ? AppColors.textWhite : const Color(0xFF0F172A), fontSize: 13),
                      decoration: AppDecorations.searchField(
                        hint: 'Search staff by name, role, terminal or phone...',
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Role Filter Pills
                  _buildFilterPill('ALL', 'All Roles ($totalStaff)', _roleFilter == 'ALL', () => setState(() => _roleFilter = 'ALL'), isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('MANAGERS', 'Managers ($managersCount)', _roleFilter == 'MANAGERS', () => setState(() => _roleFilter = 'MANAGERS'), isDark, color: AppColors.neonCyan),
                  const SizedBox(width: 8),
                  _buildFilterPill('CASHIERS', 'Cashiers ($cashiersCount)', _roleFilter == 'CASHIERS', () => setState(() => _roleFilter = 'CASHIERS'), isDark, color: AppColors.emerald),
                  const SizedBox(width: 8),
                  _buildFilterPill('STOCK', 'Stock ($stockMgrsCount)', _roleFilter == 'STOCK', () => setState(() => _roleFilter = 'STOCK'), isDark, color: AppColors.electricPurpleLight),
                  const SizedBox(width: 14),

                  // Status Filter Pills
                  _buildFilterPill('ALL_STATUS', 'All', _statusFilter == 'ALL', () => setState(() => _statusFilter = 'ALL'), isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('ONLINE', 'Online', _statusFilter == 'ONLINE', () => setState(() => _statusFilter = 'ONLINE'), isDark, color: AppColors.emerald),
                ],
              ),
              const SizedBox(height: 20),

              // ── Employees Unified List Table ──────────────────────────────
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
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 68,
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.surface : const Color(0xFFF8FAFC),
                        ),
                        dataRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.card : Colors.white,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('EMP ID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('EMPLOYEE NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('ROLE HIERARCHY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('ASSIGNED TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('TODAY\'S SHIFT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('LIVE STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('REPORT ACTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        ],
                        rows: employees.map((emp) {
                          Color roleColor = AppColors.neonCyan;
                          if (emp.role == UserRole.cashier) roleColor = AppColors.emerald;
                          if (emp.role == UserRole.stockManager) roleColor = AppColors.electricPurpleLight;

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    emp.id,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: roleColor,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: roleColor.withOpacity(0.18),
                                      child: Text(
                                        emp.name.isNotEmpty ? emp.name[0] : 'E',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: roleColor),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      emp.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: roleColor.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: roleColor.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    emp.role.displayName.toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: roleColor),
                                  ),
                                ),
                              ),
                              DataCell(Text(emp.assignedTerminal, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                              DataCell(Text(emp.shiftSchedule, style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: emp.isActive ? AppColors.emerald : AppColors.rose,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      emp.isActive ? 'ONLINE (ACTIVE)' : 'OFFLINE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: emp.isActive ? AppColors.emerald : AppColors.rose,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _openEmployeeReport(context, emp, isDark),
                                  icon: const Icon(Icons.analytics_rounded, size: 14),
                                  label: const Text('TODAY\'S REPORT'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: roleColor.withOpacity(0.15),
                                    foregroundColor: roleColor,
                                    side: BorderSide(color: roleColor.withOpacity(0.5)),
                                    elevation: 0,
                                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
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

  Widget _buildFilterPill(String key, String label, bool isSelected, VoidCallback onTap, bool isDark, {Color? color}) {
    final accent = color ?? AppColors.neonCyan;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(isDark ? 0.22 : 0.14)
              : (isDark ? AppColors.surface : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? accent
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
        padding: const EdgeInsets.all(18),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subvalue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondary : Colors.black54),
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
