import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/data/pos_state_manager.dart';
import 'core/controllers/app_controller.dart';
import 'core/localization/app_localizations.dart';
import 'features/auth/presentation/pages/global_login_screen.dart';
import 'features/owner/presentation/pages/owner_dashboard_screen.dart';
import 'features/manager/presentation/pages/manager_dashboard_screen.dart';
import 'features/cashier/presentation/pages/cashier_dashboard_screen.dart';
import 'features/stock_manager/presentation/pages/stock_manager_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CyborgPosApp());
}

class CyborgPosApp extends StatelessWidget {
  const CyborgPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppController>.value(
          value: AppController.instance,
        ),
        ChangeNotifierProvider<PosStateManager>.value(
          value: PosStateManager.instance,
        ),
      ],
      child: Consumer<AppController>(
        builder: (context, ctrl, _) {
          return MaterialApp(
            title: 'Cyborg Supermarket POS',
            debugShowCheckedModeBanner: false,
            locale: ctrl.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'EG'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: buildAppTheme(isDark: ctrl.isDarkMode),
            home: Directionality(
              textDirection: ctrl.textDirection,
              child: const _AppShell(),
            ),
          );
        },
      ),
    );
  }
}

/// Root shell managing multi-role navigation between:
/// 1. GlobalLoginScreen (Owner, Manager, Cashier, Stock Manager selection)
/// 2. OwnerPlaceholderScreen (Owner role preview)
/// 3. ManagerDashboardScreen (8 Manager Tabs including Warehouse Approvals)
/// 4. CashierDashboardScreen (3 Cashier Tabs: Online Orders, In-Store POS, Receipts)
/// 5. StockManagerDashboardScreen (7 Stock Manager Tabs)
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  UserRole? _activeRole;
  String? _userName;
  String? _shiftId;

  void _onRoleSelected(UserRole role, String userName, String? shiftId) {
    setState(() {
      _activeRole = role;
      _userName = userName;
      _shiftId = shiftId ?? 'SHIFT-INIT';
    });
  }

  void _onLogout() {
    PosStateManager.instance.logout();
    setState(() {
      _activeRole = null;
      _userName = null;
      _shiftId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeRole == null) {
      return GlobalLoginScreen(onRoleSelected: _onRoleSelected);
    }

    switch (_activeRole!) {
      case UserRole.owner:
        return OwnerDashboardScreen(onLogout: _onLogout);

      case UserRole.manager:
        return ManagerDashboardScreen(onLogout: _onLogout);

      case UserRole.cashier:
        return CashierDashboardScreen(
          cashierName: _userName ?? 'Ahmed Hassan',
          terminalId: 'POS-01',
          shiftId: _shiftId ?? 'SHIFT-POS01',
          onLogout: _onLogout,
        );

      case UserRole.stockManager:
        return StockManagerDashboardScreen(onLogout: _onLogout);
    }
  }
}
