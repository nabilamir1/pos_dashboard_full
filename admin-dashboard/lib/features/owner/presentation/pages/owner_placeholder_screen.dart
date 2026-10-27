import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/controllers/app_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/global_header_actions.dart';

/// Owner role placeholder page.
///
/// Requirement: For the "Owner" role, navigate to an empty placeholder page for now.
class OwnerPlaceholderScreen extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const OwnerPlaceholderScreen({
    Key? key,
    required this.onBackToLogin,
  }) : super(key: key);

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
              // Ambient Glow Background
              if (isDark) ...[
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricPurple.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.neonCyan.withOpacity(0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Top Navigation Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface.withOpacity(0.85) : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.electricPurple,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricPurple.withOpacity(0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('app_title'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'EXECUTIVE OWNER PORTAL',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: isDark ? AppColors.electricPurpleLight : const Color(0xFF7C3AED),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Global Header Actions (Theme & Language)
                          const GlobalHeaderActions(compact: true),
                          const SizedBox(width: 14),

                          // Role indicator pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.electricPurple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.electricPurple.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield_outlined, size: 14, color: AppColors.electricPurpleLight),
                                const SizedBox(width: 6),
                                Text(
                                  context.tr('role_owner').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                    color: AppColors.electricPurpleLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Back to Login / Switch Role Button
                          OutlinedButton.icon(
                            onPressed: onBackToLogin,
                            icon: const Icon(Icons.logout_rounded, size: 16),
                            label: Text(context.tr('switch_role')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.rose,
                              side: BorderSide(color: AppColors.rose.withOpacity(0.4)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Placeholder Body
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.electricPurple.withOpacity(0.12),
                                  border: Border.all(
                                    color: AppColors.electricPurple.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.query_stats_rounded,
                                  size: 48,
                                  color: AppColors.electricPurpleLight,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Executive Analytics & Profit Telemetry',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 560,
                                child: Text(
                                  context.tr('owner_desc'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Placeholder feature cards
                              SizedBox(
                                width: 680,
                                child: Row(
                                  children: [
                                    _buildFeaturePreview(
                                      icon: Icons.trending_up_rounded,
                                      title: 'Consolidated P&L',
                                      desc: 'Cross-branch revenue, gross margins, and real-time EBITDA telemetry.',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildFeaturePreview(
                                      icon: Icons.domain_rounded,
                                      title: 'Branch Audit',
                                      desc: 'Live telemetry across Heliopolis, Maadi & New Cairo supermarkets.',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildFeaturePreview(
                                      icon: Icons.psychology_rounded,
                                      title: 'AI Stock Forecast',
                                      desc: 'Autonomous demand prediction and shrinkage detection models.',
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 36),

                              ElevatedButton.icon(
                                onPressed: onBackToLogin,
                                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                                label: Text(context.tr('switch_role')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.electricPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildFeaturePreview({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.cyborgCard(radius: 14, isDark: isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.electricPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.electricPurpleLight, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
