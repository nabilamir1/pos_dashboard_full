import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/app_controller.dart';
import '../localization/app_localizations.dart';

/// Global header action buttons for Language (AR/EN) and Theme (Dark/Light) toggles.
class GlobalHeaderActions extends StatelessWidget {
  final bool compact;

  const GlobalHeaderActions({Key? key, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isDark = controller.isDarkMode;
        final isAr = controller.isArabic;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Theme Toggle Button (Dark / Light) ───────────────
            InkWell(
              onTap: () => controller.toggleTheme(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 14,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: 15,
                      color: isDark ? AppColors.neonCyan : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isDark ? context.tr('dark_mode') : context.tr('light_mode'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ── Language Toggle Button (EN / AR) ─────────────────
            InkWell(
              onTap: () => controller.toggleLanguage(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 14,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.electricPurple.withOpacity(0.15)
                      : AppColors.electricPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.electricPurple.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 15,
                      color: AppColors.electricPurpleLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAr ? 'عربي / RTL' : 'English / LTR',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.electricPurpleLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
