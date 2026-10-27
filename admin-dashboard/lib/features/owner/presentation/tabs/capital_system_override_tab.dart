import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';

/// Tab 6: Capital & System Override Tab (Handover Settings)
/// High-level settings panel allowing the Owner to manually override the system's
/// core values:
/// 1. Edit base capital money
/// 2. Bulk-edit store inventory levels
/// 3. Bulk-edit warehouse inventory levels (useful for ownership transfers or full resets)
class CapitalSystemOverrideTab extends StatefulWidget {
  const CapitalSystemOverrideTab({Key? key}) : super(key: key);

  @override
  State<CapitalSystemOverrideTab> createState() =>
      _CapitalSystemOverrideTabState();
}

class _CapitalSystemOverrideTabState extends State<CapitalSystemOverrideTab> {
  late final TextEditingController _capitalCtrl;

  // Store bulk override state
  final TextEditingController _storeFixedCtrl = TextEditingController(text: '100');
  String _storeCategory = 'ALL';

  // Warehouse bulk override state
  final TextEditingController _whFixedCtrl = TextEditingController(text: '450');
  String _whCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    _capitalCtrl = TextEditingController(
      text: PosStateManager.instance.baseCapital.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _capitalCtrl.dispose();
    _storeFixedCtrl.dispose();
    _whFixedCtrl.dispose();
    super.dispose();
  }

  void _saveCapital(BuildContext context) {
    final amount = double.tryParse(_capitalCtrl.text.replaceAll(',', '').trim());
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid base capital amount.'), backgroundColor: AppColors.rose),
      );
      return;
    }

    PosStateManager.instance.setBaseCapital(amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Base Capital updated to ${amount.toStringAsFixed(2)} EGP.'),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  void _applyStoreBulk(BuildContext context, bool isDark) {
    final val = int.tryParse(_storeFixedCtrl.text.trim());
    if (val == null || val < 0) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.amber),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.amber),
              SizedBox(width: 10),
              Text('Confirm Store Inventory Bulk Override'),
            ],
          ),
          content: Text(
            'This action will forcefully set on-shelf store inventory of ${_storeCategory == "ALL" ? "ALL products" : "category $_storeCategory"} to $val units. Are you sure you wish to proceed with this handover override?',
            style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.black87, fontSize: 13),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                PosStateManager.instance.bulkUpdateStoreStock(
                  fixedValue: val,
                  category: _storeCategory,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Store on-shelf inventory bulk updated to $val units!'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: Colors.black),
              child: const Text('CONFIRM OVERRIDE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _applyWhBulk(BuildContext context, bool isDark) {
    final val = int.tryParse(_whFixedCtrl.text.trim());
    if (val == null || val < 0) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.card : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.electricPurpleLight),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.electricPurpleLight),
              SizedBox(width: 10),
              Text('Confirm Warehouse Inventory Bulk Override'),
            ],
          ),
          content: Text(
            'This action will forcefully set central warehouse stock of ${_whCategory == "ALL" ? "ALL products" : "category $_whCategory"} to $val reserve units. Are you sure you wish to proceed?',
            style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.black87, fontSize: 13),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                PosStateManager.instance.bulkUpdateWarehouseStock(
                  fixedValue: val,
                  category: _whCategory,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Warehouse reserve inventory bulk updated to $val units!'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricPurple, foregroundColor: Colors.white),
              child: const Text('CONFIRM OVERRIDE', style: TextStyle(fontWeight: FontWeight.bold)),
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
        final categories = <String>{'ALL', ...state.products.map((p) => p.category)};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Banner ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.amber.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppColors.amber, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Executive Capital & System Inventory Override',
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
                                  color: AppColors.amber.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.amber.withOpacity(0.4)),
                                ),
                                child: const Text(
                                  'HIGH PRIVILEGE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.amber,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Administrative override settings for ownership handover, base treasury float adjustment, and bulk inventory calibration.',
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
              const SizedBox(height: 28),

              // ── Section 1: Base Capital Money ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: AppDecorations.cyborgCard(
                  radius: 14,
                  borderColor: AppColors.neonCyan.withOpacity(0.4),
                  isDark: isDark,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded, color: AppColors.neonCyan, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          '1. Core Base Capital & Treasury Float (EGP)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Active Capital: ${state.baseCapital.toStringAsFixed(2)} EGP',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.neonCyan, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The baseline treasury capital deposited to back active supermarket POS operations, cash register starting floats, and supplier PO clearances.',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : Colors.black54),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _capitalCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                            decoration: AppDecorations.searchField(
                              hint: 'Enter Base Capital Amount in EGP',
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        ElevatedButton.icon(
                          onPressed: () => _saveCapital(context),
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('UPDATE BASE CAPITAL'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick increment presets
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildPresetChip('+50,000 EGP', () {
                          _capitalCtrl.text = (state.baseCapital + 50000).toStringAsFixed(2);
                          _saveCapital(context);
                        }, isDark),
                        _buildPresetChip('+100,000 EGP', () {
                          _capitalCtrl.text = (state.baseCapital + 100000).toStringAsFixed(2);
                          _saveCapital(context);
                        }, isDark),
                        _buildPresetChip('+250,000 EGP', () {
                          _capitalCtrl.text = (state.baseCapital + 250000).toStringAsFixed(2);
                          _saveCapital(context);
                        }, isDark),
                        _buildPresetChip('Reset to 500,000 EGP', () {
                          _capitalCtrl.text = '500000.00';
                          _saveCapital(context);
                        }, isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section 2: Bulk-Edit Store Inventory Levels ───────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: AppDecorations.cyborgCard(
                  radius: 14,
                  borderColor: AppColors.amber.withOpacity(0.4),
                  isDark: isDark,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: AppColors.amber, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          '2. Bulk-Edit Store Front On-Shelf Inventory Levels',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Current Store Units: ${state.totalStoreStockUnits}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.amber, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bulk set or calibrate on-shelf store stock across specific or all retail categories. Used during store renovations, seasonal restocks, or ownership transfers.',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : Colors.black54),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        // Category Selector
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _storeCategory,
                              dropdownColor: isDark ? AppColors.card : Colors.white,
                              style: TextStyle(
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c == 'ALL' ? 'Target: ALL Categories' : 'Category: $c'))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _storeCategory = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Fixed Value Field
                        Expanded(
                          child: TextField(
                            controller: _storeFixedCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                            decoration: AppDecorations.searchField(
                              hint: 'New Stock Units per Item (e.g. 100)',
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        ElevatedButton.icon(
                          onPressed: () => _applyStoreBulk(context, isDark),
                          icon: const Icon(Icons.flash_on_rounded, size: 18),
                          label: const Text('APPLY BULK STORE OVERRIDE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      children: [
                        _buildPresetChip('Set all to 50 Units', () {
                          _storeFixedCtrl.text = '50';
                          _applyStoreBulk(context, isDark);
                        }, isDark),
                        _buildPresetChip('Set all to 100 Units', () {
                          _storeFixedCtrl.text = '100';
                          _applyStoreBulk(context, isDark);
                        }, isDark),
                        _buildPresetChip('Set all to 200 Units', () {
                          _storeFixedCtrl.text = '200';
                          _applyStoreBulk(context, isDark);
                        }, isDark),
                        _buildPresetChip('+10% across store', () {
                          state.bulkUpdateStoreStock(multiplier: 1.1, category: _storeCategory);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('+10% added to store inventory levels.'), backgroundColor: AppColors.emerald),
                          );
                        }, isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section 3: Bulk-Edit Warehouse Inventory Levels ───────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: AppDecorations.cyborgCard(
                  radius: 14,
                  borderColor: AppColors.electricPurple.withOpacity(0.4),
                  isDark: isDark,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warehouse_rounded, color: AppColors.electricPurpleLight, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          '3. Bulk-Edit Central Warehouse Reserve Inventory Levels',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Current Warehouse Units: ${state.totalWarehouseStockUnits}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.electricPurpleLight, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bulk calibrate reserve stock pallets in central distribution warehouse. Highly useful for physical inventory counts, ownership transfers, and audit sync.',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : Colors.black54),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        // Category Selector
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _whCategory,
                              dropdownColor: isDark ? AppColors.card : Colors.white,
                              style: TextStyle(
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c == 'ALL' ? 'Target: ALL WH Categories' : 'Category: $c'))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _whCategory = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Fixed Value Field
                        Expanded(
                          child: TextField(
                            controller: _whFixedCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                            decoration: AppDecorations.searchField(
                              hint: 'New Warehouse Units per SKU (e.g. 500)',
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        ElevatedButton.icon(
                          onPressed: () => _applyWhBulk(context, isDark),
                          icon: const Icon(Icons.flash_on_rounded, size: 18),
                          label: const Text('APPLY BULK WAREHOUSE OVERRIDE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      children: [
                        _buildPresetChip('Set all to 300 Reserve Units', () {
                          _whFixedCtrl.text = '300';
                          _applyWhBulk(context, isDark);
                        }, isDark),
                        _buildPresetChip('Set all to 500 Reserve Units', () {
                          _whFixedCtrl.text = '500';
                          _applyWhBulk(context, isDark);
                        }, isDark),
                        _buildPresetChip('Set all to 1,000 Reserve Units', () {
                          _whFixedCtrl.text = '1000';
                          _applyWhBulk(context, isDark);
                        }, isDark),
                        _buildPresetChip('+25% across warehouse', () {
                          state.bulkUpdateWarehouseStock(multiplier: 1.25, category: _whCategory);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('+25% added to warehouse inventory levels.'), backgroundColor: AppColors.emerald),
                          );
                        }, isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section 4: Handover Protocol Log ───────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_edu_rounded, color: AppColors.neonCyan, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Executive Overrides & Audit Log Trail',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.auditLogs.take(4).length,
                      separatorBuilder: (_, __) => Divider(color: isDark ? AppColors.border : const Color(0xFFE2E8F0), height: 1),
                      itemBuilder: (context, idx) {
                        final l = state.auditLogs[idx];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.verified_user_rounded, color: AppColors.neonCyan, size: 18),
                          title: Text(l.actionType, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          subtitle: Text('${l.performedBy} • Ref: ${l.referenceNo} • ${l.notes}'),
                          trailing: Text('${l.timestamp.hour}:${l.timestamp.minute.toString().padLeft(2, "0")}'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap, bool isDark) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      backgroundColor: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
      side: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
      onPressed: onTap,
    );
  }
}
