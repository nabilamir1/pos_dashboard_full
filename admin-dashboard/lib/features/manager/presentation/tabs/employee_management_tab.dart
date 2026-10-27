import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab for Store Manager to add new Cashiers & Stock Managers,
/// edit work schedules and current shifts, and remove employees.
class EmployeeManagementTab extends StatefulWidget {
  const EmployeeManagementTab({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementTab> createState() => _EmployeeManagementTabState();
}

class _EmployeeManagementTabState extends State<EmployeeManagementTab> {
  String _roleFilter = 'ALL';
  String _searchQuery = '';

  void _showAddEmployeeDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+20 100 ');
    final nationalIdCtrl = TextEditingController();
    UserRole selectedRole = UserRole.cashier;
    String selectedShift = 'Morning (08:00 - 16:00)';
    String assignedTerminal = 'POS-04';

    final shifts = [
      'Morning (08:00 - 16:00)',
      'Evening (16:00 - 00:00)',
      'Night (00:00 - 08:00)',
      'Full Shift (09:00 - 17:00)',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderCyan),
              ),
              title: const Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: AppColors.neonCyan),
                  SizedBox(width: 10),
                  Text(
                    'Add New Staff Member',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textWhite),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Selector Buttons
                      const Text(
                        'SELECT ROLE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedRole = UserRole.cashier;
                                  assignedTerminal = 'POS-04';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedRole == UserRole.cashier
                                      ? AppColors.neonCyan.withOpacity(0.15)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedRole == UserRole.cashier
                                        ? AppColors.neonCyan
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'CASHIER',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: selectedRole == UserRole.cashier
                                        ? AppColors.neonCyan
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedRole = UserRole.stockManager;
                                  assignedTerminal = 'Warehouse Bay 3';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedRole == UserRole.stockManager
                                      ? AppColors.electricPurple.withOpacity(0.15)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedRole == UserRole.stockManager
                                        ? AppColors.electricPurpleLight
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'STOCK MANAGER',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: selectedRole == UserRole.stockManager
                                        ? AppColors.electricPurpleLight
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      const Text(
                        'FULL NAME',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameCtrl,
                        decoration: AppDecorations.searchField(hint: 'e.g. Youssef Nabil', prefixIcon: Icons.badge),
                      ),
                      const SizedBox(height: 14),

                      // Phone Number & National ID Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PHONE NUMBER',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: phoneCtrl,
                                  decoration: AppDecorations.searchField(hint: '+20 100 ...', prefixIcon: Icons.phone),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'NATIONAL ID / CODE',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: nationalIdCtrl,
                                  decoration: AppDecorations.searchField(hint: '2980...', prefixIcon: Icons.fingerprint),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Shift Schedule
                      const Text(
                        'ASSIGNED SHIFT SCHEDULE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: shifts.contains(selectedShift) ? selectedShift : shifts.first,
                            isExpanded: true,
                            dropdownColor: AppColors.card,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            items: shifts.toSet().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedShift = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Terminal / Location
                      Text(
                        selectedRole == UserRole.cashier ? 'ASSIGNED CASHIER TERMINAL' : 'WAREHOUSE BAY / DISPATCH ZONE',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: TextEditingController(text: assignedTerminal),
                        onChanged: (val) => assignedTerminal = val,
                        decoration: AppDecorations.searchField(
                          hint: selectedRole == UserRole.cashier ? 'e.g. POS-04' : 'e.g. Warehouse Bay 3',
                          prefixIcon: Icons.desktop_windows,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    PosStateManager.instance.addEmployee(
                      name: nameCtrl.text.trim(),
                      role: selectedRole,
                      phone: phoneCtrl.text.trim(),
                      nationalId: nationalIdCtrl.text.trim().isEmpty ? '29900011223344' : nationalIdCtrl.text.trim(),
                      shiftSchedule: selectedShift,
                      assignedTerminal: assignedTerminal,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Staff member "${nameCtrl.text.trim()}" successfully registered.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('SAVE EMPLOYEE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.textOnCyan,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditShiftDialog(EmployeeProfile emp) {
    String selectedShift = emp.shiftSchedule;
    String assignedTerminal = emp.assignedTerminal;
    final shifts = [
      'Morning (08:00 - 16:00)',
      'Evening (16:00 - 00:00)',
      'Night (00:00 - 08:00)',
      'Full Shift (09:00 - 17:00)',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.neonCyan),
              ),
              title: Text(
                'Edit Schedule: ${emp.name}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textWhite),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WORK SCHEDULE / SHIFT',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: shifts.contains(selectedShift) ? selectedShift : shifts.first,
                          isExpanded: true,
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                          items: shifts.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedShift = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ASSIGNED TERMINAL / LOCATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: assignedTerminal),
                      onChanged: (val) => assignedTerminal = val,
                      decoration: AppDecorations.searchField(hint: 'POS Terminal', prefixIcon: Icons.desktop_windows),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    PosStateManager.instance.updateEmployee(
                      id: emp.id,
                      name: emp.name,
                      role: emp.role,
                      phone: emp.phone,
                      shiftSchedule: selectedShift,
                      assignedTerminal: assignedTerminal,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Shift schedule updated for ${emp.name}.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('UPDATE SHIFT'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteEmployee(EmployeeProfile emp) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.rose),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.rose),
              const SizedBox(width: 10),
              Text('Remove ${emp.name}?'),
            ],
          ),
          content: Text(
            'Are you sure you want to remove ${emp.name} (${emp.role.displayName}) from store employment? This action will revoke POS access.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                PosStateManager.instance.removeEmployee(emp.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${emp.name} has been removed from staff directory.'),
                    backgroundColor: AppColors.rose,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose, foregroundColor: Colors.white),
              child: const Text('DELETE EMPLOYEE'),
            ),
          ],
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
        final cashiersCount =
            state.employees.where((e) => e.role == UserRole.cashier).length;
        final stockMgrsCount =
            state.employees.where((e) => e.role == UserRole.stockManager).length;

        final filteredList = state.employees.where((e) {
          if (_roleFilter == 'CASHIER' && e.role != UserRole.cashier) return false;
          if (_roleFilter == 'STOCK_MGR' && e.role != UserRole.stockManager) return false;
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            return e.name.toLowerCase().contains(q) ||
                e.id.toLowerCase().contains(q) ||
                e.phone.contains(q) ||
                e.assignedTerminal.toLowerCase().contains(q);
          }
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary KPI Row
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL ACTIVE STAFF',
                    value: '${state.employees.length} Employees',
                    subvalue: '$cashiersCount Cashiers • $stockMgrsCount Stock Managers',
                    icon: Icons.badge_outlined,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'CASHIER LANES COVERED',
                    value: '$cashiersCount Active Tills',
                    subvalue: 'POS-01 through POS-03 Assigned',
                    icon: Icons.desktop_windows_outlined,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'STOCK WAREHOUSE TEAM',
                    value: '$stockMgrsCount Supervisors',
                    subvalue: 'Warehouse Bay 1 & Bay 2 Active',
                    icon: Icons.inventory_outlined,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Bar: Role filter pills + Search + "Add Employee" button
              Row(
                children: [
                  // Filter pills
                  _buildFilterPill('ALL', 'All Staff (${state.employees.length})'),
                  const SizedBox(width: 8),
                  _buildFilterPill('CASHIER', 'Cashiers ($cashiersCount)'),
                  const SizedBox(width: 8),
                  _buildFilterPill('STOCK_MGR', 'Stock Managers ($stockMgrsCount)'),
                  const Spacer(),

                  // Search field
                  SizedBox(
                    width: 260,
                    height: 42,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: AppDecorations.searchField(
                        hint: 'Search name, ID or phone...',
                        prefixIcon: Icons.search,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Add Employee button
                  ElevatedButton.icon(
                    onPressed: _showAddEmployeeDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('ADD NEW EMPLOYEE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: AppColors.textOnCyan,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Employee Directory Table
              Container(
                decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(isDark ? AppColors.surface : const Color(0xFFF8FAFC)),
                    dataRowColor: WidgetStateProperty.all(isDark ? AppColors.card : Colors.white),
                    headingTextStyle: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                    dataTextStyle: TextStyle(color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('EMPLOYEE ID', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('STAFF NAME', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('SHIFT SCHEDULE', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('ASSIGNED TERMINAL', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('PHONE CONTACT', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows: filteredList.map((emp) {
                      final isCashier = emp.role == UserRole.cashier;
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              emp.id,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: (isCashier ? AppColors.neonCyan : AppColors.electricPurple).withOpacity(0.2),
                                  child: Icon(
                                    isCashier ? Icons.point_of_sale : Icons.warehouse,
                                    size: 14,
                                    color: isCashier ? AppColors.neonCyan : AppColors.electricPurpleLight,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  emp.name,
                                  style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: AppDecorations.badge(
                                color: isCashier ? AppColors.neonCyan : AppColors.electricPurpleLight,
                              ),
                              child: Text(
                                emp.role.badgeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isCashier ? AppColors.neonCyan : AppColors.electricPurpleLight,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(emp.shiftSchedule, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textWhite : const Color(0xFF334155)))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                emp.assignedTerminal,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                          DataCell(Text(emp.phone, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.neonCyan),
                                  tooltip: 'Edit Shift & Schedule',
                                  onPressed: () => _showEditShiftDialog(emp),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.rose),
                                  tooltip: 'Remove Employee',
                                  onPressed: () => _confirmDeleteEmployee(emp),
                                ),
                              ],
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

  Widget _buildFilterPill(String key, String label, {bool isDark = true}) {
    final isSelected = _roleFilter == key;
    return InkWell(
      onTap: () => setState(() => _roleFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withOpacity(0.18)
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
            color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
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
    bool isDark = true,
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
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : const Color(0xFF334155)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
