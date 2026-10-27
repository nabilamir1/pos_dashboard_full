import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab for Store Manager to monitor shift attendance,
/// log exact employee punch-in times, and view calculated lateness status.
class AttendanceTab extends StatefulWidget {
  const AttendanceTab({Key? key}) : super(key: key);

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  String _filter = 'ALL';

  void _showClockInDialog() {
    final state = PosStateManager.instance;
    if (state.employees.isEmpty) return;

    EmployeeProfile selectedEmp = state.employees.first;
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);
    DateTime punchTime = now;
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final diff = punchTime.difference(scheduledTime).inMinutes;
            final isLate = diff > 5;

            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderCyan),
              ),
              title: const Row(
                children: [
                  Icon(Icons.more_time_rounded, color: AppColors.neonCyan),
                  SizedBox(width: 10),
                  Text(
                    'Manual Punch-In / Clock-In Log',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textWhite, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECT EMPLOYEE',
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
                          value: state.employees.any((e) => e.id == selectedEmp.id)
                              ? selectedEmp.id
                              : (state.employees.isNotEmpty ? state.employees.first.id : null),
                          isExpanded: true,
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                          items: state.employees.map((e) {
                            return DropdownMenuItem(
                              value: e.id,
                              child: Text('${e.name} (${e.role.badgeLabel}) - ${e.assignedTerminal}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedEmp = state.employees.firstWhere((e) => e.id == val);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scheduled vs Punch times
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SCHEDULED SHIFT START',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  '${_pad(scheduledTime.hour)}:${_pad(scheduledTime.minute)} (08:00 AM)',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textWhite),
                                ),
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
                                'ACTUAL PUNCH-IN TIME',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  '${_pad(punchTime.hour)}:${_pad(punchTime.minute)} (Recorded Now)',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.neonCyan),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lateness Calculator Feedback Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isLate ? AppColors.rose : AppColors.emerald).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isLate ? AppColors.rose : AppColors.emerald).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLate ? Icons.timer_off_outlined : Icons.check_circle_outline,
                            color: isLate ? AppColors.rose : AppColors.emerald,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLate ? 'AUTOMATIC STATUS: LATE (+$diff MINS)' : 'AUTOMATIC STATUS: ON-TIME',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: isLate ? AppColors.rose : AppColors.emerald,
                                  ),
                                ),
                                Text(
                                  isLate
                                      ? 'Exceeded 5-minute shift grace threshold. Penalty log recorded.'
                                      : 'Punched within required shift start window.',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    const Text(
                      'MANAGER NOTES (OPTIONAL)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      decoration: AppDecorations.searchField(
                        hint: 'e.g. Traffic on ring road, notified store manager',
                        prefixIcon: Icons.note_alt_outlined,
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
                    PosStateManager.instance.clockInEmployee(
                      employeeId: selectedEmp.id,
                      scheduledTime: scheduledTime,
                      punchInTime: punchTime,
                      shiftName: selectedEmp.shiftSchedule,
                      notes: notesCtrl.text.trim().isEmpty ? 'Manager verified check-in' : notesCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Attendance recorded for ${selectedEmp.name}.'),
                        backgroundColor: isLate ? AppColors.rose : AppColors.emerald,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('RECORD PUNCH-IN'),
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

  @override
  Widget build(BuildContext context) {
    final state = PosStateManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final totalLogs = state.attendanceLogs.length;
        final lateCount = state.attendanceLogs.where((a) => a.isLate).length;
        final onTimeCount = totalLogs - lateCount;

        final displayLogs = state.attendanceLogs.where((a) {
          if (_filter == 'LATE') return a.isLate;
          if (_filter == 'ON_TIME') return !a.isLate;
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Attendance Metrics
              Row(
                children: [
                  _buildMetricCard(
                    title: 'TOTAL SHIFT CHECK-INS',
                    value: '$totalLogs Punches',
                    subvalue: 'Tracked today across all shifts',
                    icon: Icons.fingerprint_rounded,
                    accentColor: AppColors.neonCyan,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'ON-TIME EMPLOYEES',
                    value: '$onTimeCount Staff',
                    subvalue: 'Within scheduled 5-min window',
                    icon: Icons.check_circle_rounded,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: 'LATE ARRIVALS DETECTED',
                    value: '$lateCount Delays',
                    subvalue: 'Automatic lateness flagged',
                    icon: Icons.warning_rounded,
                    accentColor: AppColors.rose,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter row & Clock In button
              Row(
                children: [
                  _buildFilterPill('ALL', 'All Attendance ($totalLogs)', isDark: isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('ON_TIME', 'On-Time ($onTimeCount)', isDark: isDark),
                  const SizedBox(width: 8),
                  _buildFilterPill('LATE', 'Late ($lateCount)', isDark: isDark),
                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: _showClockInDialog,
                    icon: const Icon(Icons.add_alarm_rounded, size: 18),
                    label: const Text('CLOCK-IN EMPLOYEE (OVERRIDE)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: AppColors.textOnCyan,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attendance Table
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
                      DataColumn(label: Text('ENTRY ID', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('EMPLOYEE', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('SCHEDULED START', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('ACTUAL PUNCH-IN', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('CALCULATED STATUS', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('NOTES', style: TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows: displayLogs.map((entry) {
                      final isCashier = entry.role == UserRole.cashier;
                      final isLate = entry.isLate;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              entry.entryId,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              entry.employeeName,
                              style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: AppDecorations.badge(
                                color: isCashier ? AppColors.neonCyan : AppColors.electricPurpleLight,
                              ),
                              child: Text(
                                entry.role.badgeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isCashier ? AppColors.neonCyan : AppColors.electricPurpleLight,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatTime(entry.scheduledStartTime),
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : const Color(0xFF475569)),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatTime(entry.actualPunchInTime),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isLate ? AppColors.rose : AppColors.emerald,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppDecorations.badge(color: isLate ? AppColors.rose : AppColors.emerald),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isLate ? Icons.warning_rounded : Icons.check_circle_rounded,
                                    size: 12,
                                    color: isLate ? AppColors.rose : AppColors.emerald,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    entry.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: isLate ? AppColors.rose : AppColors.emerald,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              entry.notes,
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : const Color(0xFF64748B)),
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
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
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

  String _formatTime(DateTime dt) {
    return '${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

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
