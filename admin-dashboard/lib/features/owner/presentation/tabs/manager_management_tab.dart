import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';

/// Tab 4: Manager Management Tab
/// A UI form to add new Store Managers, edit their details,
/// manage their branch assignments, or remove them from the system.
class ManagerManagementTab extends StatefulWidget {
  const ManagerManagementTab({Key? key}) : super(key: key);

  @override
  State<ManagerManagementTab> createState() => _ManagerManagementTabState();
}

class _ManagerManagementTabState extends State<ManagerManagementTab> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddManagerDialog(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+20 100 ');
    final nationalIdCtrl = TextEditingController(text: '29');
    String selectedBranch = 'Main Branch HQ Desk';
    String selectedShift = 'Branch Operations (08:00 - 18:00)';
    final pinCtrl = TextEditingController(text: '1234');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
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
                    child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.neonCyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Appoint New Store Manager',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign executive managerial privileges, store replenishment authorization rights, and branch terminal assignment.',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // Full Name
                        Text('FULL NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameCtrl,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter manager name' : null,
                          style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                          decoration: AppDecorations.searchField(hint: 'e.g. Hazem Mahmoud', isDark: isDark),
                        ),
                        const SizedBox(height: 14),

                        // Phone Number & National ID Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PHONE NUMBER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: phoneCtrl,
                                    validator: (v) => (v == null || v.trim().length < 8) ? 'Enter valid phone' : null,
                                    style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                                    decoration: AppDecorations.searchField(hint: '+20 100 123 4567', isDark: isDark),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NATIONAL ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: nationalIdCtrl,
                                    validator: (v) => (v == null || v.trim().length < 10) ? 'Enter National ID' : null,
                                    style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                                    decoration: AppDecorations.searchField(hint: '14-digit ID', isDark: isDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Assigned Branch Desk
                        Text('ASSIGNED BRANCH HQ DESK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
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
                              value: selectedBranch,
                              isExpanded: true,
                              dropdownColor: isDark ? AppColors.card : Colors.white,
                              style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87, fontSize: 13),
                              items: const [
                                DropdownMenuItem(value: 'Main Branch HQ Desk', child: Text('Main Branch HQ Desk (Nasr City)')),
                                DropdownMenuItem(value: 'Downtown Branch Desk', child: Text('Downtown Branch Desk (Tahrir)')),
                                DropdownMenuItem(value: 'New Cairo Branch Desk', child: Text('New Cairo Branch Desk (Fifth Settlement)')),
                                DropdownMenuItem(value: 'Mohandessin Branch Desk', child: Text('Mohandessin Branch Desk (Giza)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedBranch = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Shift Schedule & PIN
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SHIFT SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
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
                                        value: selectedShift,
                                        isExpanded: true,
                                        dropdownColor: isDark ? AppColors.card : Colors.white,
                                        style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87, fontSize: 12),
                                        items: const [
                                          DropdownMenuItem(value: 'Branch Operations (08:00 - 18:00)', child: Text('Day Shift (08:00 - 18:00)')),
                                          DropdownMenuItem(value: 'Evening Operations (14:00 - 23:00)', child: Text('Evening (14:00 - 23:00)')),
                                          DropdownMenuItem(value: 'Full Day Shift (08:00 - 22:00)', child: Text('Full Day Shift')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setDialogState(() => selectedShift = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SECURITY PIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: pinCtrl,
                                    obscureText: true,
                                    keyboardType: TextInputType.number,
                                    validator: (v) => (v == null || v.trim().length < 4) ? '4 digits' : null,
                                    style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                                    decoration: AppDecorations.searchField(hint: '1234', isDark: isDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    if (formKey.currentState!.validate()) {
                      PosStateManager.instance.addManager(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        nationalId: nationalIdCtrl.text.trim(),
                        shiftSchedule: selectedShift,
                        assignedTerminal: selectedBranch,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Store Manager "${nameCtrl.text.trim()}" successfully registered!'),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: const Text('CONFIRM APPOINTMENT'),
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

  void _showEditManagerDialog(BuildContext context, EmployeeProfile manager, bool isDark) {
    final nameCtrl = TextEditingController(text: manager.name);
    final phoneCtrl = TextEditingController(text: manager.phone);
    String selectedBranch = manager.assignedTerminal;
    String selectedShift = manager.shiftSchedule;
    bool isActive = manager.isActive;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.card : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.electricPurpleLight, width: 1.5),
              ),
              title: Text(
                'Edit Manager Details: ${manager.name}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                ),
              ),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FULL NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                      decoration: AppDecorations.searchField(hint: 'Manager Name', isDark: isDark),
                    ),
                    const SizedBox(height: 14),

                    Text('PHONE NUMBER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneCtrl,
                      style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                      decoration: AppDecorations.searchField(hint: 'Phone', isDark: isDark),
                    ),
                    const SizedBox(height: 14),

                    Text('ASSIGNED BRANCH DESK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMuted : Colors.black54)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: selectedBranch),
                      onChanged: (v) => selectedBranch = v,
                      style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                      decoration: AppDecorations.searchField(hint: 'Branch Desk', isDark: isDark),
                    ),
                    const SizedBox(height: 14),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Active Status in System',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        isActive ? 'Account active & authorized to login' : 'Account suspended',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54),
                      ),
                      value: isActive,
                      activeColor: AppColors.emerald,
                      onChanged: (v) => setDialogState(() => isActive = v),
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
                    PosStateManager.instance.updateManager(
                      manager.id,
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      shiftSchedule: selectedShift,
                      assignedTerminal: selectedBranch,
                      isActive: isActive,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Manager "${manager.name}" details updated!'), backgroundColor: AppColors.emerald),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteManagerDialog(BuildContext context, EmployeeProfile manager, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.rose),
          ),
          title: Text('Relieve Manager: ${manager.name}?'),
          content: Text(
            'Are you sure you want to remove Store Manager "${manager.name}" (${manager.id}) from the system? Managerial login credentials and branch permissions will be revoked immediately.',
            style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.black87, fontSize: 13),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                PosStateManager.instance.removeManager(manager.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Store Manager "${manager.name}" removed from system.'), backgroundColor: AppColors.rose),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose, foregroundColor: Colors.white),
              child: const Text('CONFIRM REMOVE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([state, AppController.instance]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final managers = state.managers.where((m) {
          final q = _searchQuery.toLowerCase();
          return q.isEmpty ||
              m.name.toLowerCase().contains(q) ||
              m.phone.contains(q) ||
              m.assignedTerminal.toLowerCase().contains(q) ||
              m.id.toLowerCase().contains(q);
        }).toList();

        final totalManagers = state.managers.length;
        final activeManagers = state.managers.where((m) => m.isActive).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Banner with Add Manager Button ─────────────────────
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
                    color: AppColors.neonCyan.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.neonCyan, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Managers Administration & Hierarchy',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Owner-level controls to appoint, configure branch headquarters, edit profiles, or revoke store managerial credentials.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddManagerDialog(context, isDark),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('APPOINT NEW MANAGER'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
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
                    title: 'TOTAL BRANCH MANAGERS',
                    value: '$totalManagers Appointed',
                    subvalue: 'Managing retail operations',
                    icon: Icons.groups_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'ACTIVE MANAGERS',
                    value: '$activeManagers Active',
                    subvalue: 'Authorized for daily shifts',
                    icon: Icons.verified_user_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'SUPERMARKET BRANCHES',
                    value: '${state.managers.map((m) => m.assignedTerminal).toSet().length} Locations',
                    subvalue: 'Active HQ coverage',
                    icon: Icons.store_mall_directory_rounded,
                    accentColor: AppColors.electricPurpleLight,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  _buildMetricCard(
                    title: 'AUTHORIZATION PRIVILEGES',
                    value: 'Level 2 Executive',
                    subvalue: 'Reorders, receiving & returns',
                    icon: Icons.key_rounded,
                    accentColor: AppColors.amber,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Search Bar ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: TextStyle(color: isDark ? AppColors.textWhite : const Color(0xFF0F172A), fontSize: 13),
                      decoration: AppDecorations.searchField(
                        hint: 'Search managers by name, phone number, branch or employee ID...',
                        isDark: isDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Managers Data Table ───────────────────────────────────────
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
                          DataColumn(label: Text('MANAGER NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('PHONE NUMBER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('ASSIGNED BRANCH DESK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('SHIFT SCHEDULE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('NATIONAL ID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                          DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                        ],
                        rows: managers.map((m) {
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
                                    m.id,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.neonCyan,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.neonCyan.withOpacity(0.18),
                                      child: Text(
                                        m.name.isNotEmpty ? m.name[0] : 'M',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.neonCyan),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      m.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(m.phone, style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.amber),
                                    const SizedBox(width: 6),
                                    Text(m.assignedTerminal, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              DataCell(Text(m.shiftSchedule, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(m.nationalId, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (m.isActive ? AppColors.emerald : AppColors.rose).withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: (m.isActive ? AppColors.emerald : AppColors.rose).withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    m.isActive ? 'ACTIVE ON DUTY' : 'SUSPENDED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: m.isActive ? AppColors.emerald : AppColors.rose,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.neonCyan),
                                      tooltip: 'Edit Details',
                                      onPressed: () => _showEditManagerDialog(context, m, isDark),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.rose),
                                      tooltip: 'Relieve Manager',
                                      onPressed: () => _showDeleteManagerDialog(context, m, isDark),
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
                ),
              ),
            ],
          ),
        );
      },
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
