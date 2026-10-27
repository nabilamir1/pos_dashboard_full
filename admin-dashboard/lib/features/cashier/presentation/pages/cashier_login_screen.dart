import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Cashier Shift Login Screen.
///
/// Provides a premium, glass-morphism login dialog for cashiers to start
/// their shift. Uses only mock validation — no backend calls.
class CashierLoginScreen extends StatefulWidget {
  /// Called when the cashier logs in successfully with their name.
  final void Function(String cashierName, String shiftId) onLoginSuccess;

  const CashierLoginScreen({Key? key, required this.onLoginSuccess})
      : super(key: key);

  @override
  State<CashierLoginScreen> createState() => _CashierLoginScreenState();
}

class _CashierLoginScreenState extends State<CashierLoginScreen>
    with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
  final _pinController = TextEditingController();
  final _idFocus = FocusNode();
  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorMessage;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Mock cashier credentials
  static const _mockCashiers = {
    '1001': {'pin': '1234', 'name': 'Ahmed Hassan'},
    '1002': {'pin': '5678', 'name': 'Sara Ibrahim'},
    '1003': {'pin': '0000', 'name': 'Mohamed Ali'},
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _idFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _idController.dispose();
    _pinController.dispose();
    _idFocus.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final id = _idController.text.trim();
    final pin = _pinController.text.trim();

    if (id.isEmpty || pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter both Cashier ID and PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate a small network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final cashier = _mockCashiers[id];
      if (cashier != null && cashier['pin'] == pin) {
        final shiftId =
            'SHIFT-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
        print(
            '[MOCK LOGIN] Cashier "${cashier['name']}" logged in. Shift ID: $shiftId');
        widget.onLoginSuccess(cashier['name']!, shiftId);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid Cashier ID or PIN. Try: 1001 / 1234';
        });
        print('[MOCK LOGIN] Failed attempt — ID: $id');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Animated background blobs ─────────────────────────
          ..._buildBackgroundOrbs(size),

          // ── Main content ──────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & brand
                  _buildLogo(),
                  const SizedBox(height: 36),

                  // Login card
                  _buildLoginCard(),

                  const SizedBox(height: 24),

                  // Hint row
                  Text(
                    'Demo credentials — ID: 1001 · PIN: 1234',
                    style: TextStyle(
                      color: AppColors.textMuted.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background decorative orbs ──────────────────────────────────
  List<Widget> _buildBackgroundOrbs(Size size) {
    return [
      Positioned(
        top: -80,
        left: -80,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.emerald.withOpacity(0.08 * _pulseAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        right: -100,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.cyan.withOpacity(0.06 * _pulseAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // ── Logo widget ─────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.emerald,
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.emerald.withOpacity(0.35 * _pulseAnimation.value),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.storefront_rounded,
                size: 38, color: Colors.white),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'CYBORG SUPERMARKET',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'POINT OF SALE — CASHIER LOGIN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.emerald.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // ── Login card ──────────────────────────────────────────────────
  Widget _buildLoginCard() {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(32),
      decoration: AppDecorations.glassCard(radius: 20).copyWith(
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withOpacity(0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.badge_outlined,
                    color: AppColors.emerald, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Your Shift',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Enter your cashier credentials below',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Cashier ID
          _buildLabel('CASHIER ID'),
          const SizedBox(height: 8),
          TextField(
            controller: _idController,
            focusNode: _idFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
            decoration: AppDecorations.searchField(
              hint: 'e.g. 1001',
              prefixIcon: Icons.person_outline,
            ),
            onSubmitted: (_) =>
                FocusScope.of(context).nextFocus(), // jump to PIN
          ),

          const SizedBox(height: 20),

          // PIN
          _buildLabel('PIN CODE'),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 6,
            ),
            decoration: AppDecorations.searchField(
              hint: '••••',
              prefixIcon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePin
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePin = !_obscurePin),
              ),
            ),
            onSubmitted: (_) => _handleLogin(),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Login button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                disabledBackgroundColor: AppColors.emerald.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded,
                            size: 20, color: AppColors.textOnAccent),
                        SizedBox(width: 10),
                        Text(
                          'START SHIFT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppColors.textOnAccent,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 18),

          // Current date/time badge
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    _formattedNow(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }

  String _formattedNow() {
    final now = DateTime.now();
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month]} ${now.year}  ·  $h:$m';
  }
}
