import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cyborg_admin_dashboard/main.dart';
import 'package:cyborg_admin_dashboard/core/theme/app_theme.dart';
import 'package:cyborg_admin_dashboard/features/owner/presentation/pages/owner_dashboard_screen.dart';

void main() {
  testWidgets('CyborgPosApp loads login screen and UI components successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CyborgPosApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify CYBORG branding and roles are rendered
    expect(find.textContaining('CYBORG'), findsWidgets);
    expect(find.textContaining('Owner'), findsWidgets);
    expect(find.textContaining('Manager'), findsWidgets);
    expect(find.textContaining('Cashier'), findsWidgets);
    expect(find.textContaining('Stock Manager'), findsWidgets);
  });

  testWidgets('OwnerDashboardScreen renders all 6 tabs and handles navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(isDark: true),
      home: OwnerDashboardScreen(onLogout: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify all 6 tabs are present in top navigation
    expect(find.text('Store Inventory'), findsWidgets);
    expect(find.text('Warehouse Inventory'), findsWidgets);
    expect(find.text('Comprehensive Financials'), findsWidgets);
    expect(find.text('Manager Management'), findsWidgets);
    expect(find.text('Global Staff Daily Reports'), findsWidgets);
    expect(find.text('Capital & System Override'), findsWidgets);
    expect(find.textContaining('Dr. Nabil'), findsWidgets);

    // Switch to Tab 2: Warehouse Inventory
    await tester.tap(find.byKey(const Key('owner_tab_1')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('RESERVE UNITS IN BAYS'), findsWidgets);

    // Switch to Tab 3: Comprehensive Financials
    await tester.tap(find.byKey(const Key('owner_tab_2')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Financial Audit'), findsWidgets);

    // Switch to Tab 4: Manager Management
    await tester.tap(find.byKey(const Key('owner_tab_3')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('APPOINT NEW MANAGER'), findsWidgets);

    // Switch to Tab 5: Global Staff Daily Reports
    await tester.tap(find.byKey(const Key('owner_tab_4')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Global Staff Daily Reports'), findsWidgets);

    // Switch to Tab 6: Capital & System Override
    await tester.tap(find.byKey(const Key('owner_tab_5')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Core Base Capital'), findsWidgets);
  });
}
