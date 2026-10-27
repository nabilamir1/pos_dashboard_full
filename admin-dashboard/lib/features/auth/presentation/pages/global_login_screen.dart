import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/global_header_actions.dart';

/// Global Login Screen featuring 4 role selections:
/// 1. Owner (Requires email cyborgcoding1@gmail.com and password cyborgandcode123)
/// 2. Manager (Store Operations & 8 Tabs)
/// 3. Cashier (POS Scanning & Checkout)
/// 4. Stock Manager (Warehouse & Reorders)
class GlobalLoginScreen extends StatefulWidget {
  final void Function(UserRole role, String userName, String? shiftId) onRoleSelected;

  const GlobalLoginScreen({
    Key? key,
    required this.onRoleSelected,
  }) : super(key: key);

  @override
  State<GlobalLoginScreen> createState() => _GlobalLoginScreenState();
}

class _GlobalLoginScreenState extends State<GlobalLoginScreen>
    with SingleTickerProviderStateMixin {
  UserRole _selectedRole = UserRole.manager;
  final TextEditingController _idController = TextEditingController(text: '2001');
  final TextEditingController _pinController = TextEditingController(text: '1234');
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPasswordController = TextEditingController();

  bool _obscurePin = true;
  bool _obscureOwnerPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final Map<UserRole, Map<String, String>> _roleDefaults = {
    UserRole.owner: {
      'id': 'cyborgcoding1@gmail.com',
      'pin': 'cyborgandcode123',
      'name': 'Dr. Nabil (Founder & Owner)',
      'desc': 'Consolidated financial reports, multi-branch audit, and margin analytics.',
      'badge': 'EXECUTIVE PORTAL',
    },
    UserRole.manager: {
      'id': '2001',
      'pin': '1234',
      'name': 'Tarek Mansour (Store Manager)',
      'desc': 'Returns, damaged stock auto-deduct, staff shifts, low stock alerts & warehouse receiving.',
      'badge': 'OPERATIONS DESK',
    },
    UserRole.cashier: {
      'id': '1001',
      'pin': '1234',
      'name': 'Ahmed Hassan (Senior Cashier)',
      'desc': 'High-speed barcode scanner checkout, cart management & printed receipts.',
      'badge': 'POS REGISTER LANE',
    },
    UserRole.stockManager: {
      'id': '3001',
      'pin': '5555',
      'name': 'Hossam El-Din (Stock Supervisor)',
      'desc': 'Warehouse inbound pallets, reorder request approvals & bay tracking.',
      'badge': 'WAREHOUSE CONSOLE',
    },
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _idController.dispose();
    _pinController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    super.dispose();
  }

  void _onSelectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role != UserRole.owner) {
        _idController.text = _roleDefaults[role]!['id']!;
        _pinController.text = _roleDefaults[role]!['pin']!;
      }
      _errorMessage = null;
    });
  }

  void _handleLogin() {
    // ── Dedicated Owner Authentication ──────────────────────────────────────
    if (_selectedRole == UserRole.owner) {
      final email = _ownerEmailController.text.trim();
      final password = _ownerPasswordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        final err = context.tr('please_enter_email_password');
        setState(() => _errorMessage = err);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.rose,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        if (email == 'cyborgcoding1@gmail.com' && password == 'cyborgandcode123') {
          widget.onRoleSelected(UserRole.owner, 'Dr. Nabil (Founder & Owner)', null);
        } else {
          final err = context.tr('invalid_owner_credentials');
          setState(() => _errorMessage = err);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: AppColors.rose,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
      return;
    }

    // ── Manager, Cashier, Stock Manager Authentication ─────────────────────
    final id = _idController.text.trim();
    final pin = _pinController.text.trim();

    if (id.isEmpty || pin.isEmpty) {
      final err = context.tr('please_enter_id_pin');
      setState(() => _errorMessage = err);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final info = _roleDefaults[_selectedRole]!;
      final expectedPin = info['pin']!;

      if (pin != expectedPin && pin != '1234' && pin != '0000') {
        setState(() {
          _isLoading = false;
          _errorMessage = '${context.tr("invalid_credentials")} - Demo PIN: $expectedPin';
        });
        return;
      }

      setState(() => _isLoading = false);

      String? shiftId;
      if (_selectedRole == UserRole.cashier) {
        shiftId = 'SHIFT-8810';
      } else if (_selectedRole == UserRole.manager) {
        shiftId = 'MGR-SHIFT-01';
      } else if (_selectedRole == UserRole.stockManager) {
        shiftId = 'WH-SHIFT-01';
      }

      widget.onRoleSelected(_selectedRole, info['name']!, shiftId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF1F5F9),
          body: Stack(
            children: [
              // Ambient Background Glows
              Positioned(
                top: -120,
                left: -120,
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonCyan.withOpacity(isDark ? 0.08 : 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                right: -150,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.electricPurple.withOpacity(isDark ? 0.08 : 0.05),
                  ),
                ),
              ),

              // Top Header Actions (Language & Theme toggles)
              Positioned(
                top: 16,
                right: 24,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: const GlobalHeaderActions(compact: true),
                  ),
                ),
              ),

              // Main Center View
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cyborg Brand Header
                        _buildHeader(isDark),
                        const SizedBox(height: 32),

                        // Role Selection Cards Grid (4 Roles)
                        SizedBox(
                          width: 980,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lock_person_rounded, size: 18, color: AppColors.neonCyan),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('login_title').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildRoleCard(
                                    role: UserRole.owner,
                                    title: context.tr('role_owner'),
                                    badge: context.tr('badge_executive'),
                                    desc: context.tr('owner_desc'),
                                    icon: Icons.workspace_premium_rounded,
                                    accentColor: AppColors.electricPurpleLight,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 14),
                                  _buildRoleCard(
                                    role: UserRole.manager,
                                    title: context.tr('role_manager'),
                                    badge: context.tr('badge_operations'),
                                    desc: context.tr('manager_desc'),
                                    icon: Icons.admin_panel_settings_rounded,
                                    accentColor: AppColors.neonCyan,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 14),
                                  _buildRoleCard(
                                    role: UserRole.cashier,
                                    title: context.tr('role_cashier'),
                                    badge: context.tr('badge_pos_lane'),
                                    desc: context.tr('cashier_desc'),
                                    icon: Icons.point_of_sale_rounded,
                                    accentColor: AppColors.emerald,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 14),
                                  _buildRoleCard(
                                    role: UserRole.stockManager,
                                    title: context.tr('role_stock_manager'),
                                    badge: context.tr('badge_warehouse_console'),
                                    desc: context.tr('stock_manager_desc'),
                                    icon: Icons.warehouse_rounded,
                                    accentColor: AppColors.amber,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Authentication Form Box
                        _buildAuthCard(isDark),
                        const SizedBox(height: 20),

                        // System status footer
                        Text(
                          context.tr('system_footer'),
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            color: isDark
                                ? AppColors.textMuted.withOpacity(0.6)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.cyborgPrimary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.4 * _pulseAnim.value),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.storefront_rounded, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr('app_title'),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withOpacity(isDark ? 0.1 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
          ),
          child: Text(
            context.tr('system_tagline'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: isDark ? AppColors.neonCyan : const Color(0xFF0098A6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String badge,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? AppColors.surfaceLight : AppColors.card)
              : (isSelected ? Colors.white : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _onSelectRole(role),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: accentColor, size: 22),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.black),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(bool isDark) {
    final info = _roleDefaults[_selectedRole]!;
    final isOwner = _selectedRole == UserRole.owner;

    return Container(
      width: 520,
      padding: const EdgeInsets.all(28),
      decoration: AppDecorations.cyborgCard(
        radius: 18,
        borderColor: isOwner ? AppColors.electricPurpleLight : AppColors.borderCyan,
        glow: true,
        isDark: isDark,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isOwner ? AppColors.electricPurple : AppColors.neonCyan).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOwner ? Icons.workspace_premium_rounded : Icons.verified_user_rounded,
                  color: isOwner ? AppColors.electricPurpleLight : AppColors.neonCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.tr('authenticate_as')} ${context.tr("role_${_selectedRole.name}")}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isOwner ? context.tr('dr_nabil_title') : info['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOwner
                            ? AppColors.electricPurpleLight
                            : (isDark ? AppColors.neonCyan : const Color(0xFF0098A6)),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Role info hint banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('${_selectedRole.name}_desc'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (isOwner) ...[
            // Owner Email Address Field
            Text(
              context.tr('owner_email').toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('owner_email_field'),
              controller: _ownerEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              decoration: AppDecorations.searchField(
                hint: 'cyborgcoding1@gmail.com',
                prefixIcon: Icons.email_outlined,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 16),

            // Owner Password Field
            Text(
              context.tr('owner_password').toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('owner_password_field'),
              controller: _ownerPasswordController,
              obscureText: _obscureOwnerPassword,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              decoration: AppDecorations.searchField(
                hint: '••••••••••••',
                prefixIcon: Icons.lock_outline,
                isDark: isDark,
                suffix: IconButton(
                  icon: Icon(
                    _obscureOwnerPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureOwnerPassword = !_obscureOwnerPassword),
                ),
              ),
              onSubmitted: (_) => _handleLogin(),
            ),
          ] else ...[
            // Employee ID Input
            Text(
              context.tr('user_id').toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('employee_id_field'),
              controller: _idController,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              decoration: AppDecorations.searchField(
                hint: 'e.g. 2001',
                prefixIcon: Icons.badge_outlined,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 16),

            // PIN Input
            Text(
              context.tr('enter_pin').toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('employee_pin_field'),
              controller: _pinController,
              obscureText: _obscurePin,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              decoration: AppDecorations.searchField(
                hint: '••••',
                prefixIcon: Icons.lock_outline,
                isDark: isDark,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
              onSubmitted: (_) => _handleLogin(),
            ),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 12, color: AppColors.rose, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 24),

          // Login Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              key: const Key('login_submit_btn'),
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwner ? AppColors.electricPurple : AppColors.neonCyan,
                foregroundColor: isOwner ? Colors.white : AppColors.textOnCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: isOwner ? Colors.white : Colors.black),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 20, color: isOwner ? Colors.white : AppColors.textOnCyan),
                        const SizedBox(width: 10),
                        Text(
                          isOwner
                              ? context.tr('enter_owner_dashboard')
                              : '${context.tr("enter_dashboard")} ${context.tr("badge_${_selectedRole.name}")}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: isOwner ? Colors.white : AppColors.textOnCyan,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // 1-Click Fast Switch Bar
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.tr('instant_access'),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textMuted.withOpacity(0.8) : const Color(0xFF64748B),
                ),
              ),
              _buildFastSwitchBtn(context.tr('role_owner'), UserRole.owner, isDark),
              Text(' • ', style: TextStyle(color: isDark ? AppColors.borderLight : const Color(0xFFCBD5E1))),
              _buildFastSwitchBtn(context.tr('role_manager'), UserRole.manager, isDark),
              Text(' • ', style: TextStyle(color: isDark ? AppColors.borderLight : const Color(0xFFCBD5E1))),
              _buildFastSwitchBtn(context.tr('role_cashier'), UserRole.cashier, isDark),
              Text(' • ', style: TextStyle(color: isDark ? AppColors.borderLight : const Color(0xFFCBD5E1))),
              _buildFastSwitchBtn(context.tr('role_stock_manager'), UserRole.stockManager, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFastSwitchBtn(String label, UserRole role, bool isDark) {
    return InkWell(
      onTap: () => _onSelectRole(role),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: _selectedRole == role ? FontWeight.w800 : FontWeight.w600,
            color: _selectedRole == role
                ? (isDark ? AppColors.neonCyan : const Color(0xFF0098A6))
                : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
            decoration: _selectedRole == role ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
