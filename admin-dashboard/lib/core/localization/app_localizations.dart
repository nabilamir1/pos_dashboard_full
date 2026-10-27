import 'package:flutter/material.dart';

/// Centralized localization dictionary for CYBORG Supermarket POS.
/// Provides instant bilingual (English / Arabic) string translations
/// across all roles (Owner, Manager, Cashier, Stock Manager).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // ── App Brand & Header ──────────────────────────────
      'app_title': 'CYBORG SUPERMARKET',
      'warehouse_desk': 'WAREHOUSE DESK',
      'manager_desk': 'STORE MANAGER DESK',
      'cashier_desk': 'POS REGISTER LANE',
      'owner_desk': 'EXECUTIVE OWNER DESK',
      'switch_role': 'SWITCH ROLE',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language_name': 'English / LTR',
      'system_tagline': 'CENTRAL LOGISTICS, POS CONTROL & STORE REPLENISHMENT',
      'system_footer': 'CYBORG POS ENGINE v2.4 • HELIOPOLIS MAIN BRANCH • MULTI-ROLE REALTIME STATE',

      // ── Roles & Identity ─────────────────────────────────
      'role_owner': 'Owner / Executive',
      'role_manager': 'Store Manager',
      'role_cashier': 'Cashier',
      'role_stock_manager': 'Stock Manager',
      'owner_desc': 'Consolidated financial reports, multi-branch audit, and margin analytics.',
      'manager_desc': 'Returns, damaged stock auto-deduct, staff shifts, low stock alerts & warehouse receiving.',
      'cashier_desc': 'High-speed barcode scanner checkout, cart management & printed receipts.',
      'stock_manager_desc': 'Warehouse inbound pallets, reorder request approvals & bay tracking.',
      'login_title': 'Select Role to Access System',
      'login_subtitle': 'Multi-role real-time synchronization architecture',
      'authenticate_as': 'Authenticate as',
      'enter_pin': 'Enter Security PIN',
      'user_id': 'Employee ID',
      'login_button': 'SIGN IN TO WORKSPACE',
      'instant_access': 'Instant Role Access: ',
      'dr_nabil_title': 'Dr. Nabil • Founder & Owner',

      // ── Badges ───────────────────────────────────────────
      'badge_executive': 'EXECUTIVE PORTAL',
      'badge_operations': 'OPERATIONS DESK',
      'badge_pos_lane': 'POS REGISTER LANE',
      'badge_warehouse_console': 'WAREHOUSE CONSOLE',
      'badge_owner': 'OWNER',
      'badge_manager': 'MANAGER',
      'badge_cashier': 'CASHIER',
      'badge_stock_mgr': 'STOCK MGR',

      // ── Owner Login Specifics ────────────────────────────
      'owner_email': 'OWNER EMAIL ADDRESS',
      'owner_password': 'EXECUTIVE MASTER PASSWORD',
      'enter_owner_dashboard': 'ENTER OWNER DASHBOARD',
      'enter_dashboard': 'ENTER DASHBOARD',
      'invalid_owner_credentials': 'Invalid Credentials. Please check your Owner Email and Password.',
      'invalid_credentials': 'Invalid Credentials',
      'please_enter_email_password': 'Please enter both Owner Email and Password.',
      'please_enter_id_pin': 'Please enter both Employee ID and Security PIN.',

      // ── Common Actions & Statuses ────────────────────────
      'approve': 'APPROVE',
      'deny': 'DENY',
      'reject': 'REJECT',
      'accept': 'ACCEPT',
      'confirm': 'CONFIRM',
      'cancel': 'CANCEL',
      'close': 'CLOSE',
      'save': 'SAVE',
      'edit': 'EDIT',
      'relieve': 'RELIEVE',
      'delete': 'DELETE',
      'add': 'ADD',
      'search': 'SEARCH',
      'scan': 'SCAN',
      'filter': 'FILTER',
      'export': 'EXPORT',
      'print': 'PRINT',
      'view_slip': 'VIEW SLIP',
      'view_receipt': 'VIEW FULL RECEIPT',
      'simulate': 'SIMULATE SCAN',
      'all': 'ALL',
      'pending': 'PENDING',
      'approved': 'APPROVED',
      'denied': 'DENIED',
      'fulfilled': 'FULFILLED',
      'out_for_delivery': 'OUT FOR DELIVERY',
      'delivered': 'DELIVERED',
      'active': 'ACTIVE',
      'healthy': 'HEALTHY',
      'low_stock': 'LOW STOCK',
      'out_of_stock': 'OUT OF STOCK',
      'depleted': 'DEPLETED',
      'online': 'ONLINE',
      'offline': 'OFFLINE',
      'cashiers': 'CASHIERS',
      'stock': 'STOCK',
      'managers': 'MANAGERS',

      // ── Owner Dashboard Tabs ─────────────────────────────
      'tab_owner_store_inventory': 'Store Inventory',
      'tab_owner_wh_inventory': 'Warehouse Inventory',
      'tab_owner_financials': 'Comprehensive Financials',
      'tab_owner_managers': 'Manager Management',
      'tab_owner_staff_reports': 'Global Staff Daily Reports',
      'tab_owner_override': 'Capital & System Override',
      'owner_executive_suite': 'EXECUTIVE OWNER CONSOLE',
      'owner_tagline': 'CENTRAL MULTI-BRANCH AUDIT, VALUATION & ASSET OVERRIDE',

      // ── Manager Dashboard Tabs ───────────────────────────
      'tab_returns': 'Returns & Refunds',
      'tab_damaged': 'Damaged Goods',
      'tab_online_cashiers': 'Online Cashiers',
      'tab_employees': 'Staff Management',
      'tab_attendance': 'Attendance Logs',
      'tab_inventory': 'Inventory & Low Stock',
      'tab_stock_receiving': 'Stock Receiving',
      'tab_warehouse_approvals': 'Warehouse Requests',

      // ── Cashier Dashboard Tabs ───────────────────────────
      'tab_online_orders': 'Online Orders (COD)',
      'tab_instore_pos': 'In-Store POS',
      'tab_previous_receipts': 'Previous Receipts',

      // ── Stock Manager Dashboard Tabs ─────────────────────
      'tab_wh_dashboard': 'Warehouse Dashboard',
      'tab_store_requests': 'Store Low Stock Requests',
      'tab_wh_low_stock': 'Warehouse Low Stock',
      'tab_add_product': 'Add New Product',
      'tab_fulfill_requests': 'Fulfill Store Requests',
      'tab_import_restock': 'Import / Restock',
      'tab_audit_log': 'Audit & Receipts Log',

      // ── Table Column Headers ─────────────────────────────
      'col_code': 'CODE',
      'col_barcode': 'BARCODE',
      'col_product': 'PRODUCT NAME',
      'col_category': 'CATEGORY',
      'col_price': 'PRICE',
      'col_store_stock': 'STORE STOCK',
      'col_wh_stock': 'WH STOCK',
      'col_wh_threshold': 'WH THRESHOLD',
      'col_status': 'STATUS',
      'col_actions': 'ACTIONS',
      'col_req_id': 'REQUEST ID',
      'col_qty': 'QUANTITY',
      'col_supplier': 'SUPPLIER',
      'col_decision': 'DECISION NOTE',
      'col_time': 'TIMESTAMP',
      'col_cashier': 'CASHIER',
      'col_terminal': 'TERMINAL',
      'col_total': 'TOTAL',
      'col_customer': 'CUSTOMER',
      'col_manager': 'MANAGER',
      'col_phone': 'PHONE / CONTACT',
      'col_branch': 'BRANCH HQ',
      'col_shift': 'ASSIGNED SHIFT',

      // ── Metrics & KPIs ───────────────────────────────────
      'kpi_total_sales': 'TOTAL LIVE REVENUE',
      'kpi_active_cashiers': 'ACTIVE CASHIERS ONLINE',
      'kpi_transactions': 'STORE TRANSACTIONS',
      'kpi_total_skus': 'TOTAL WAREHOUSE SKUS',
      'kpi_total_units': 'TOTAL WAREHOUSE UNITS',
      'kpi_low_wh_stock': 'LOW WAREHOUSE STOCK',
      'kpi_out_of_stock': 'OUT OF STOCK (WH)',
      'kpi_pending_approvals': 'PENDING APPROVALS',
      'kpi_approved_reorders': 'APPROVED REORDERS',
      'kpi_fulfilled_store': 'FULFILLED TO STORE',
      'kpi_denied_reorders': 'DENIED REORDERS',
      'kpi_total_audit': 'TOTAL AUDIT ACTIONS',
      'kpi_inbound_restocks': 'INBOUND RESTOCKS',
      'kpi_outbound_dispatches': 'OUTBOUND DISPATCHES',

      // ── Owner Tab 1: Store Inventory ─────────────────────
      'store_inventory_title': 'Real-Time Store Front Inventory',
      'store_inventory_desc': 'Live on-shelf stock levels currently present across retail displays, cash registers, and aisles.',
      'store_live_feed': 'STORE LIVE FEED',
      'total_store_skus': 'TOTAL STORE SKUS',
      'catalogued_store_skus': 'Active in store aisles',
      'store_onshelf_units': 'STORE ON-SHELF UNITS',
      'units_on_shelves': 'Available for instant checkout',
      'store_shelf_valuation': 'STORE SHELF VALUATION',
      'retail_selling_price': 'Total retail asset value',
      'retail_price': 'Retail Price',
      'store_stock': 'Store Stock',
      'shelf_status': 'Shelf Status',
      'search_store_hint': 'Search store inventory by name, barcode, or category...',

      // ── Owner Tab 2: Warehouse Inventory ─────────────────
      'warehouse_inventory_title': 'Central Warehouse Inventory (Reserve Pallets Live View)',
      'warehouse_inventory_desc': 'Central distribution stock levels maintained across warehouse bays, incoming vendor pallets, and store transfers.',
      'central_logistics': 'CENTRAL LOGISTICS',
      'total_warehouse_skus': 'TOTAL WAREHOUSE SKUS',
      'catalogued_logistics': 'Catalogued in central logistics',
      'reserve_units_bays': 'RESERVE UNITS IN BAYS',
      'inbound_wh_stock': 'Inbound warehouse stock',
      'warehouse_reserve_val': 'WAREHOUSE RESERVE VALUE',
      'reserve_asset_val': 'Total reserve asset valuation',
      'search_wh_hint': 'Search warehouse inventory by name, barcode, or category...',
      'wh_reserve_units': 'Warehouse Reserve Units',
      'reorder_threshold': 'Reorder Point / Threshold',

      // ── Owner Tab 3: Comprehensive Financials ────────────
      'consolidated_financial_audit': 'Consolidated Financial Audit & P&L Analysis',
      'financial_audit_desc': 'Real-time automated reconciliation of cashier sales, COD driver cash returns, physical asset value, and stock loss write-offs.',
      'est_gross_margin': 'EST. GROSS MARGIN',
      'total_goods_val': 'TOTAL COMBINED RETAIL VALUE',
      'store_wh_combined': 'Store + WH available inventory',
      'total_cogs': 'TOTAL ESTIMATED COST OF GOODS',
      'cogs_baseline': 'Wholesale cost baseline (COGS)',
      'total_sales_rev': 'TOTAL SALES REVENUE',
      'combined_receipts': 'In-store lanes & COD deliveries',
      'cash_in_drawer': 'CASH IN DRAWER & REGISTERS',
      'physical_cash': 'Register cash + Driver COD returns',
      'losses_damages': 'LOSSES, DAMAGED & REFUNDS',
      'shrinkage_writeoffs': 'Waste, spoiled goods & refunds',
      'revenue_channels': 'Revenue Channels Breakdown',
      'instore_pos_revenue': 'In-Store POS Lanes Revenue:',
      'online_cod_revenue': 'Online Web/App Delivery (COD):',
      'total_recognized_rev': 'Total Recognized Sales Revenue:',
      'inventory_assets_val': 'Inventory Asset Valuation',
      'store_shelf_val_row': 'Store Front Shelf Valuation:',
      'central_wh_pallets_row': 'Central Warehouse Pallets:',
      'total_combined_retail_row': 'Total Combined Retail Asset:',
      'est_wholesale_cogs_row': 'Estimated Wholesale Cost (COGS):',
      'inventory_gross_markup_row': 'Inventory Gross Unrealized Markup:',
      'losses_refunds_shrinkage': 'Losses, Refunds & Shrinkage',
      'customer_returns_refunded': 'Customer Returns Refunded:',
      'damaged_spoiled_loss': 'Damaged & Spoiled Stock Write-offs:',
      'total_shrinkage_loss': 'Total Operating Shrinkage & Loss:',
      'recent_receipts_ledger': 'Recent Store Receipts & Transaction Audit',
      'receipt_id': 'RECEIPT ID',
      'time': 'TIME',
      'terminal': 'TERMINAL',
      'cashier': 'CASHIER',
      'payment_type': 'PAYMENT',
      'amount': 'AMOUNT',

      // ── Owner Tab 4: Manager Management ──────────────────
      'manager_admin_title': 'Store Managers Administration & Hierarchy',
      'manager_admin_desc': 'Owner-level controls to appoint, configure branch headquarters, edit profiles, or revoke store managerial credentials.',
      'appoint_new_manager': 'APPOINT NEW MANAGER',
      'total_branch_managers': 'TOTAL BRANCH MANAGERS',
      'appointed_retail_ops': 'Managing retail operations',
      'active_ops_desks': 'ACTIVE OPERATIONS DESKS',
      'branches_supervised': 'Store branches supervised',
      'supervised_staff': 'SUPERVISED STAFF MEMBERS',
      'cashiers_and_stock': 'Cashiers and stock team',
      'search_managers_hint': 'Search managers by name, phone, terminal, or ID...',
      'manager_name': 'MANAGER',
      'contact_phone': 'PHONE / CONTACT',
      'assigned_hq': 'BRANCH HEADQUARTERS',
      'shift_schedule': 'ASSIGNED SHIFT',
      'appoint_dialog_title': 'Appoint New Branch Manager',
      'edit_dialog_title': 'Edit Branch Manager Profile',
      'relieve_dialog_title': 'Relieve Manager Credentials',
      'relieve_confirm_msg': 'Are you sure you want to relieve this manager of managerial credentials?',
      'confirm_relieve': 'CONFIRM RELIEVE',
      'save_manager_profile': 'SAVE MANAGER PROFILE',
      'manager_full_name': 'Manager Full Name',
      'manager_phone': 'Phone Number',
      'manager_national_id': 'National ID / SSN',
      'branch_desk_hq': 'Assigned Branch Desk HQ',

      // ── Owner Tab 5: Global Staff Daily Reports ──────────
      'global_staff_title': 'Global Staff Daily Reports & Live Presence',
      'global_staff_desc': 'Real-time attendance, operational performance, and daily shift summaries across all staff roles.',
      'total_registered_staff': 'TOTAL REGISTERED STAFF',
      'active_cashiers': 'ACTIVE CASHIERS',
      'stock_supervisors': 'STOCK SUPERVISORS',
      'branch_managers': 'BRANCH MANAGERS',
      'search_staff_hint': 'Search staff by name, ID, phone, terminal...',
      'staff_member': 'STAFF MEMBER',
      'role': 'ROLE',
      'shift': 'SHIFT',
      'todays_report': 'TODAY\'S REPORT',
      'view_report': 'VIEW REPORT',

      // ── Owner Tab 6: Capital & System Override ────────────
      'override_title': 'Executive Capital & System Inventory Override',
      'override_desc': 'Administrative override settings for ownership handover, base treasury float adjustment, and bulk inventory calibration.',
      'high_privilege': 'HIGH PRIVILEGE',
      'core_base_capital': '1. Core Base Capital & Treasury Float (EGP)',
      'active_capital': 'Active Capital:',
      'base_capital_desc': 'The fundamental initial operating float and store treasury baseline used for ROI and financial modeling.',
      'enter_capital_amount': 'Enter new base capital amount in EGP',
      'save_base_capital': 'SAVE BASE CAPITAL',
      'store_bulk_override': '2. Store On-Shelf Inventory Bulk Override',
      'store_bulk_desc': 'Instantly set or overwrite physical floor inventory across all or specific categories during store handover or physical stocktake.',
      'apply_store_bulk': 'APPLY STORE BULK OVERRIDE',
      'wh_bulk_override': '3. Central Warehouse Reserve Stock Bulk Override',
      'wh_bulk_desc': 'Forcefully adjust warehouse reserve units across pallet bays and categories during logistics audit or initial warehouse handover.',
      'apply_wh_bulk': 'APPLY WH BULK OVERRIDE',
      'override_audit_history': '4. Executive Handover & Override History',
      'confirm_override': 'CONFIRM OVERRIDE',

      // ── Manager Tabs Common Texts ────────────────────────
      'add_new_staff': 'Add New Staff Member',
      'select_role': 'SELECT ROLE',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'national_id': 'National ID',
      'terminal_bay': 'Terminal / Bay',
      'save_staff': 'SAVE STAFF MEMBER',
      'morning_shift': 'Morning (08:00 - 16:00)',
      'evening_shift': 'Evening (16:00 - 00:00)',
      'night_shift': 'Night (00:00 - 08:00)',
      'full_shift': 'Full Shift (09:00 - 17:00)',

      // ── Receipt & Checkout Details ───────────────────────
      'receipt_title': 'TAX INVOICE / OFFICIAL RECEIPT',
      'subtotal': 'Subtotal',
      'vat_tax': 'VAT (14%)',
      'grand_total': 'Grand Total',
      'cash_paid': 'Cash Tendered',
      'change_due': 'Change Due',
      'payment_method': 'Payment Method',
      'items_count': 'Items Count',
      'unit_price': 'Unit Price',
      'line_total': 'Total',
      'print_receipt': 'PRINT RECEIPT',
      'reprint_receipt': 'REPRINT RECEIPT',

      // ── Online Orders & Delivery ──────────────────────────
      'kpi_pending_online': 'PENDING WEB / APP ORDERS',
      'kpi_preparing_online': 'ORDERS PREPARING (PACKING)',
      'kpi_delivery_online': 'OUT FOR DELIVERY (COD)',
      'order_pending_desc': 'Requires immediate Accept / Reject',
      'order_preparing_desc': 'Scan products before courier dispatch',
      'order_delivery_desc': 'Strict Cash on Delivery Collection',
      'filter_all_orders': 'All Orders',
      'filter_pending': 'Pending',
      'filter_preparing': 'Preparing',
      'filter_delivery': 'Out for Delivery',
      'filter_cancelled': 'Cancelled',
      'order_number': 'Order #',
      'accept_order': 'ACCEPT ORDER',
      'reject_order': 'REJECT',
      'customer_info': 'CUSTOMER INFORMATION',
      'delivery_address': 'Delivery Address:',
      'scan_packing_hint': 'Scan item barcode to verify packing...',
      'verify_item': 'VERIFY ITEM',
      'missing_item': 'MISSING ITEM?',
      'print_and_dispatch': 'PRINT RECEIPT & DISPATCH (OUT FOR DELIVERY)',
      'select_order_hint': 'Select an order to inspect details and scan packing items.',
      'no_orders_match': 'No orders match this status filter.',
      'payment_cod_notice': 'Payment strictly Cash on Delivery (COD)',
      'item_out_of_stock': 'Item Out of Stock',
      'replace_similar_opt': 'OPTION 1: REPLACE WITH SIMILAR ITEM',
      'cancel_order_opt': 'OPTION 2: CUSTOMER PREFERS CANCELLATION',
      'cancel_entire_order': 'CANCEL ENTIRE ORDER',
      'confirm_replacement': 'CONFIRM REPLACEMENT',

      // ── Product Categories ───────────────────────────────
      'cat_beverages': 'Beverages',
      'cat_dairy': 'Dairy & Eggs',
      'cat_bakery': 'Bakery',
      'cat_snacks': 'Snacks',
      'cat_pantry': 'Pantry',
      'cat_meat': 'Meat & Poultry',
      'cat_household': 'Household',
      'cat_produce': 'Produce',

      // ── Order Status Display Labels ───────────────────────
      'status_pending': 'Pending',
      'status_preparing': 'Preparing',
      'status_out_for_delivery': 'Out for Delivery',
      'status_cancelled': 'Cancelled',
      'status_delivered': 'Delivered',

      // ── KPI Unit Labels ───────────────────────────────────
      'kpi_orders_unit': 'Orders',
      'kpi_in_prep_unit': 'In Prep',
      'kpi_en_route_unit': 'En Route',

      // ── Field Labels ─────────────────────────────────────
      'label_phone': 'Phone',
      'label_email': 'Email',
      'label_barcode': 'Barcode',
      'label_cod': 'COD',
      'label_items': 'items',
      'ordered_products': 'ORDERED PRODUCTS',

      // ── Reject Dialog ─────────────────────────────────────
      'reject_order_title': 'Reject Order',
      'reject_reason_hint': 'Reason for rejection',
      'confirm_reject': 'CONFIRM REJECT',

      // ── Snackbar & Banner Messages ────────────────────────
      'scan_no_match': 'Scanned barcode does not match any item in this order.',
      'dispatch_snackbar': 'Order {id} receipt printed and dispatched! Status: "Out for Delivery".',
      'dispatched_notice': 'Receipt Printed & Dispatched to Courier. Driver collecting COD payment upon delivery.',
      'order_cancelled_label': 'Order Cancelled',
      'rejected_by_cashier': 'Rejected by cashier',
    },
    'ar': {
      // ── App Brand & Header ──────────────────────────────
      'app_title': 'سوبرماركت سايبورغ',
      'warehouse_desk': 'منصة المستودع والمخازن',
      'manager_desk': 'منصة مدير الفرع',
      'cashier_desk': 'نقطة بيع الكاشير',
      'owner_desk': 'منصة المالك والإدارة العليا',
      'switch_role': 'تبديل الدور',
      'dark_mode': 'الوضع الليلي',
      'light_mode': 'الوضع المضيء',
      'language_name': 'عربي / RTL',
      'system_tagline': 'الإمداد اللوجستي المركزي والتحكم بنقاط البيع وتجديد المخزون',
      'system_footer': 'محرك سايبورغ لنقاط البيع v2.4 • فرع مصر الجديدة الرئيسي • مزامنة لحظية متعددة الأدوار',

      // ── Roles & Identity ─────────────────────────────────
      'role_owner': 'المالك / الإدارة العليا',
      'role_manager': 'مدير الفرع',
      'role_cashier': 'الكاشير',
      'role_stock_manager': 'مسؤول المستودع',
      'owner_desc': 'التقارير المالية المجمعة والرقابة وهوامش الأرباح الشاملة.',
      'manager_desc': 'المرتجعات، خصم التوالف الآلي، مناوبات الموظفين، وإذن توريد المخازن.',
      'cashier_desc': 'مسح الباركود فائق السرعة وإدارة السلة وطباعة الإيصالات.',
      'stock_manager_desc': 'شحنات المستودع الواردة واعتماد طلبات التجديد وتتبع الأرفف.',
      'login_title': 'اختر الدور للدخول إلى النظام',
      'login_subtitle': 'بنية برمجية متعددة الأدوار مع مزامنة لحظية فورية',
      'authenticate_as': 'تسجيل الدخول بصفة',
      'enter_pin': 'أدخل الرقم السري الأمني',
      'user_id': 'رقم الموظف',
      'login_button': 'دخول إلى مساحة العمل',
      'instant_access': 'دخول سريع ومباشر: ',
      'dr_nabil_title': 'د. نبيل • المؤسس والمالك',

      // ── Badges ───────────────────────────────────────────
      'badge_executive': 'بوابة الإدارة العليا',
      'badge_operations': 'مكتب العمليات',
      'badge_pos_lane': 'نقطة بيع الكاشير',
      'badge_warehouse_console': 'منصة المستودع',
      'badge_owner': 'المالك',
      'badge_manager': 'المدير',
      'badge_cashier': 'كاشير',
      'badge_stock_mgr': 'المستودع',

      // ── Owner Login Specifics ────────────────────────────
      'owner_email': 'البريد الإلكتروني للمالك',
      'owner_password': 'كلمة المرور الرئيسية للمالك',
      'enter_owner_dashboard': 'دخول لوحة تحكم المالك',
      'enter_dashboard': 'دخول لوحة التحكم',
      'invalid_owner_credentials': 'بيانات الاعتماد غير صالحة. يرجى التحقق من البريد الإلكتروني وكلمة المرور للمالك.',
      'invalid_credentials': 'بيانات الاعتماد غير صالحة',
      'please_enter_email_password': 'يرجى إدخال البريد الإلكتروني وكلمة المرور للمالك.',
      'please_enter_id_pin': 'يرجى إدخال رقم الموظف والرقم السري الأمني.',

      // ── Common Actions & Statuses ────────────────────────
      'approve': 'موافقة واعتماد',
      'deny': 'رفض الطلب',
      'reject': 'رفض',
      'accept': 'قبول الطلب',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'close': 'إغلاق',
      'save': 'حفظ البيانات',
      'edit': 'تعديل',
      'relieve': 'إعفاء',
      'delete': 'حذف',
      'add': 'إضافة',
      'search': 'بحث...',
      'scan': 'مسح الباركود',
      'filter': 'تصفية',
      'export': 'تصدير التقرير',
      'print': 'طباعة',
      'view_slip': 'عرض إذن الصرف',
      'view_receipt': 'عرض الفاتورة الكاملة',
      'simulate': 'محاكاة المسح',
      'all': 'الكل',
      'pending': 'قيد الانتظار',
      'approved': 'معتمد',
      'denied': 'مرفوض',
      'fulfilled': 'تم الصرف والتسليم',
      'out_for_delivery': 'خرج للتوصيل',
      'delivered': 'تم التسليم',
      'active': 'نشط',
      'healthy': 'مخزون وفير',
      'low_stock': 'مخزون منخفض',
      'out_of_stock': 'نفذ من المستودع',
      'depleted': 'منتهي بالكامل',
      'online': 'متصل',
      'offline': 'غير متصل',
      'cashiers': 'الكاشير',
      'stock': 'مسؤولو المستودع',
      'managers': 'مديرو الفروع',

      // ── Owner Dashboard Tabs ─────────────────────────────
      'tab_owner_store_inventory': 'مخزون المتجر',
      'tab_owner_wh_inventory': 'مخزون المستودع المركزي',
      'tab_owner_financials': 'التقارير المالية الشاملة',
      'tab_owner_managers': 'إدارة مديري الفروع',
      'tab_owner_staff_reports': 'تقارير الموظفين اليومية والورديات',
      'tab_owner_override': 'رأس المال والمعايرة الشاملة',
      'owner_executive_suite': 'منصة المالك والإدارة العليا',
      'owner_tagline': 'الرقابة المالية المركزية، تقييم الأصول وإدارة رأس المال',

      // ── Manager Dashboard Tabs ───────────────────────────
      'tab_returns': 'المرتجعات والاسترداد',
      'tab_damaged': 'البضائع التالفة',
      'tab_online_cashiers': 'الكاشير المتصلون',
      'tab_employees': 'إدارة الموظفين',
      'tab_attendance': 'سجل الحضور والانصراف',
      'tab_inventory': 'المخزون والنواقص',
      'tab_stock_receiving': 'استلام الشحنات',
      'tab_warehouse_approvals': 'طلبات المستودع',

      // ── Cashier Dashboard Tabs ───────────────────────────
      'tab_online_orders': 'طلبات الأونلاين (دفع عند الاستلام)',
      'tab_instore_pos': 'كاشير نقطة البيع',
      'tab_previous_receipts': 'سجل الفواتير السابقة',

      // ── Stock Manager Dashboard Tabs ─────────────────────
      'tab_wh_dashboard': 'لوحة تحكم المستودع',
      'tab_store_requests': 'طلبات نواقص الفرع',
      'tab_wh_low_stock': 'نواقص المستودع المركزي',
      'tab_add_product': 'إضافة صنف جديد',
      'tab_fulfill_requests': 'صرف وتسليم طلبيات الفرع',
      'tab_import_restock': 'توريد وإدخال شحنة',
      'tab_audit_log': 'سجل العمليات والرقابة',

      // ── Table Column Headers ─────────────────────────────
      'col_code': 'الكود',
      'col_barcode': 'الباركود',
      'col_product': 'اسم الصنف',
      'col_category': 'التصنيف',
      'col_price': 'السعر',
      'col_store_stock': 'مخزون الفرع',
      'col_wh_stock': 'مخزون المستودع',
      'col_wh_threshold': 'الحد الأدنى',
      'col_status': 'الحالة',
      'col_actions': 'إجراءات',
      'col_req_id': 'رقم الطلب',
      'col_qty': 'الكمية',
      'col_supplier': 'المورد',
      'col_decision': 'ملاحظة القرار',
      'col_time': 'التوقيت',
      'col_cashier': 'الكاشير',
      'col_terminal': 'نقطة البيع',
      'col_total': 'الإجمالي',
      'col_customer': 'العميل',
      'col_manager': 'اسم المدير',
      'col_phone': 'الهاتف والتواصل',
      'col_branch': 'المقر الإداري للفرع',
      'col_shift': 'الوردية المحددة',

      // ── Metrics & KPIs ───────────────────────────────────
      'kpi_total_sales': 'إجمالي الإيرادات اللحظية',
      'kpi_active_cashiers': 'نقاط الكاشير النشطة',
      'kpi_transactions': 'عمليات البيع المكتملة',
      'kpi_total_skus': 'إجمالي الأصناف المسجلة',
      'kpi_total_units': 'إجمالي قطع المستودع',
      'kpi_low_wh_stock': 'نواقص المستودع الحرجة',
      'kpi_out_of_stock': 'أصناف نفذت بالكامل',
      'kpi_pending_approvals': 'طلبات بانتظار الاعتماد',
      'kpi_approved_reorders': 'طلبات تم اعتمادها',
      'kpi_fulfilled_store': 'شحنات سلمت للفرع',
      'kpi_denied_reorders': 'طلبات تم رفضها',
      'kpi_total_audit': 'إجمالي قيود الرقابة',
      'kpi_inbound_restocks': 'شحنات التوريد الواردة',
      'kpi_outbound_dispatches': 'شحنات الصرف الصادرة',

      // ── Owner Tab 1: Store Inventory ─────────────────────
      'store_inventory_title': 'مخزون صالة العرض بالمتجر لحظياً',
      'store_inventory_desc': 'كميات المخزون المعروضة حالياً على الأرفف وصالة العرض وممرات الشراء.',
      'store_live_feed': 'تحديث المتجر المباشر',
      'total_store_skus': 'إجمالي أصناف المتجر',
      'catalogued_store_skus': 'أصناف معروضة في ممرات الفرع',
      'store_onshelf_units': 'القطع المتوفرة على الأرفف',
      'units_on_shelves': 'جاهزة للشراء والمحاسبة الفورية',
      'store_shelf_valuation': 'القيمة الإجمالية لبضاعة الأرفف',
      'retail_selling_price': 'إجمالي القيمة البيعية للأصناف',
      'retail_price': 'سعر البيع للجمهور',
      'store_stock': 'مخزون المتجر',
      'shelf_status': 'حالة الأرفف',
      'search_store_hint': 'ابحث في مخزون المتجر بالاسم أو الباركود أو التصنيف...',

      // ── Owner Tab 2: Warehouse Inventory ─────────────────
      'warehouse_inventory_title': 'مخزون المستودع المركزي (المخزون الاحتياطي اللحظي)',
      'warehouse_inventory_desc': 'مستويات المخزون في مستودع التوزيع المركزي وحجرات التخزين والشحنات الواردة.',
      'central_logistics': 'الإمداد اللوجستي المركزي',
      'total_warehouse_skus': 'إجمالي أصناف المستودع',
      'catalogued_logistics': 'مسجلة في الإمداد اللوجستي',
      'reserve_units_bays': 'قطع المخزون الاحتياطي في الحجرات',
      'inbound_wh_stock': 'مخزون المستودع الوارد والاحتياطي',
      'warehouse_reserve_val': 'قيمة المخزون الاحتياطي بالمستودع',
      'reserve_asset_val': 'إجمالي تقييم أصول المستودع الاحتياطية',
      'search_wh_hint': 'ابحث في مخزون المستودع بالاسم أو الباركود أو التصنيف...',
      'wh_reserve_units': 'وحدات المستودع الاحتياطية',
      'reorder_threshold': 'حد إعادة الطلب والتنبيه',

      // ── Owner Tab 3: Comprehensive Financials ────────────
      'consolidated_financial_audit': 'التدقيق المالي المجمع وتحليل الأرباح والخسائر',
      'financial_audit_desc': 'مطابقة آلية فورية لمبيعات الكاشير وتحصيلات الدفع عند الاستلام وقيمة الأصول وخسائر التوالف.',
      'est_gross_margin': 'هامش الربح الإجمالي التقديري',
      'total_goods_val': 'إجمالي القيمة البيعية للأصول (المتجر + المستودع)',
      'store_wh_combined': 'بضاعة المتجر والمستودع المتاحة للبيع',
      'total_cogs': 'إجمالي تكلفة البضاعة المتاحة (COGS)',
      'cogs_baseline': 'أساس تكلفة الشراء بالجملة',
      'total_sales_rev': 'إجمالي إيرادات المبيعات المحققة',
      'combined_receipts': 'مبيعات الكاشير وطلبات الدفع عند الاستلام',
      'cash_in_drawer': 'إجمالي النقدية في الدرج والخزينة',
      'physical_cash': 'كاش الكاشير + متحصلات سائقي التوصيل',
      'losses_damages': 'إجمالي الخسائر والتوالف والمرتجعات',
      'shrinkage_writeoffs': 'التوالف ومنتهي الصلاحية والمستردات',
      'revenue_channels': 'تفصيل قنوات الإيرادات',
      'instore_pos_revenue': 'إيرادات نقاط البيع بالفرع:',
      'online_cod_revenue': 'إيرادات طلبات التوصيل (COD):',
      'total_recognized_rev': 'إجمالي الإيرادات المعتمدة:',
      'inventory_assets_val': 'تقييم أصول المخزون',
      'store_shelf_val_row': 'تقييم بضاعة صالة العرض:',
      'central_wh_pallets_row': 'تقييم شحنات المستودع المركزي:',
      'total_combined_retail_row': 'إجمالي الأصول البيعية المجمعة:',
      'est_wholesale_cogs_row': 'التكلفة الإجمالية بسعر الجملة:',
      'inventory_gross_markup_row': 'هامش الربح المتوقع غير المحقق:',
      'losses_refunds_shrinkage': 'الخسائر والمرتجعات والتوالف',
      'customer_returns_refunded': 'مبالغ مرتجعات العملاء:',
      'damaged_spoiled_loss': 'خسائر البضائع التالفة والهالكة:',
      'total_shrinkage_loss': 'إجمالي الخسائر التشغيلية والتوالف:',
      'recent_receipts_ledger': 'سجل أحدث إيصالات المبيعات والعمليات',
      'receipt_id': 'رقم الإيصال',
      'time': 'التوقيت',
      'terminal': 'نقطة البيع',
      'cashier': 'الكاشير',
      'payment_type': 'الدفع',
      'amount': 'المبلغ',

      // ── Owner Tab 4: Manager Management ──────────────────
      'manager_admin_title': 'إدارة وهيكل مديري الفروع',
      'manager_admin_desc': 'صلاحيات المالك لتعيين مديري الفروع وتعديل بياناتهم وتوزيع مقار العمل وسحب الصلاحيات.',
      'appoint_new_manager': 'تعيين مدير فرع جديد',
      'total_branch_managers': 'إجمالي مديري الفروع',
      'appointed_retail_ops': 'يديرون العمليات التشغيلية للفروع',
      'active_ops_desks': 'مكاتب العمليات النشطة',
      'branches_supervised': 'فروع تحت الإشراف المباشر',
      'supervised_staff': 'إجمالي موظفي الفروع',
      'cashiers_and_stock': 'فرق الكاشير ومسؤولي المستودع',
      'search_managers_hint': 'ابحث عن مدير بالاسم أو الهاتف أو المكتب أو الرقم...',
      'manager_name': 'اسم المدير',
      'contact_phone': 'الهاتف والتواصل',
      'assigned_hq': 'المقر الإداري للفرع',
      'shift_schedule': 'الوردية المحددة',
      'appoint_dialog_title': 'تعيين مدير فرع جديد',
      'edit_dialog_title': 'تعديل بيانات مدير الفرع',
      'relieve_dialog_title': 'سحب صلاحيات المدير',
      'relieve_confirm_msg': 'هل أنت متأكد من رغبتك في سحب صلاحيات الإدارة من هذا المدير؟',
      'confirm_relieve': 'تأكيد سحب الصلاحيات',
      'save_manager_profile': 'حفظ بيانات المدير',
      'manager_full_name': 'الاسم الكامل للمدير',
      'manager_phone': 'رقم الهاتف',
      'manager_national_id': 'الرقم القومي / الهوية',
      'branch_desk_hq': 'المكتب الإداري للفرع',

      // ── Owner Tab 5: Global Staff Daily Reports ──────────
      'global_staff_title': 'تقارير الموظفين اليومية والتواجد المباشر',
      'global_staff_desc': 'متابعة لحظية للحضور والأداء التشغيلي وملخصات الورديات لجميع الموظفين.',
      'total_registered_staff': 'إجمالي الموظفين المسجلين',
      'active_cashiers': 'الكاشير النشطون',
      'stock_supervisors': 'مسؤولو المستودع',
      'branch_managers': 'مديرو الفروع',
      'search_staff_hint': 'ابحث بالاسم أو الرقم أو الهاتف أو نقطة البيع...',
      'staff_member': 'الموظف',
      'role': 'الدور',
      'shift': 'الوردية',
      'todays_report': 'تقرير اليوم',
      'view_report': 'عرض التقرير',

      // ── Owner Tab 6: Capital & System Override ────────────
      'override_title': 'المعايرة التنفيذية لرأس المال والمخزون',
      'override_desc': 'إعدادات الإدارة العليا لعمليات التسليم وضبط رأس المال وتعديل المخزون المجمع.',
      'high_privilege': 'صلاحيات عليا',
      'core_base_capital': '١. رأس المال الأساسي وخزينة السيولة النقدية (ج.م)',
      'active_capital': 'رأس المال الفعلي:',
      'base_capital_desc': 'السيولة التشغيلية الأساسية وخزينة الفرع المستخدمة لحساب العائد على الاستثمار.',
      'enter_capital_amount': 'أدخل مبلغ رأس المال الأساسي الجديد بالجنيه',
      'save_base_capital': 'حفظ رأس المال الأساسي',
      'store_bulk_override': '٢. معايرة مخزون الأرفف وصالة العرض',
      'store_bulk_desc': 'تحديد أو تعديل كميات بضاعة الأرفف دفعة واحدة أثناء تسليم الوردية أو الجرد الفعلي.',
      'apply_store_bulk': 'تطبيق معايرة مخزون المتجر',
      'wh_bulk_override': '٣. معايرة مخزون المستودع المركزي',
      'wh_bulk_desc': 'تعديل كميات المخزون الاحتياطي بالمستودع دفعة واحدة أثناء الجرد اللوجستي أو التسليم.',
      'apply_wh_bulk': 'تطبيق معايرة المستودع',
      'override_audit_history': '٤. سجل عمليات التسليم والمعايرة السابقة',
      'confirm_override': 'تأكيد المعايرة',

      // ── Manager Tabs Common Texts ────────────────────────
      'add_new_staff': 'إضافة موظف جديد',
      'select_role': 'اختر الدور الوظيفي',
      'full_name': 'الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'national_id': 'الرقم القومي',
      'terminal_bay': 'نقطة البيع / حجرة المستودع',
      'save_staff': 'حفظ بيانات الموظف',
      'morning_shift': 'صباحية (08:00 - 16:00)',
      'evening_shift': 'مسائية (16:00 - 00:00)',
      'night_shift': 'ليلية (00:00 - 08:00)',
      'full_shift': 'دوام كامل (09:00 - 17:00)',

      // ── Receipt & Checkout Details ───────────────────────
      'receipt_title': 'فاتورة ضريبية رسمية / إيصال بيع',
      'subtotal': 'المجموع الفرعي',
      'vat_tax': 'ضريبة القيمة المضافة (١٤٪)',
      'grand_total': 'الإجمالي النهائي',
      'cash_paid': 'المبلغ المدفوع نقداً',
      'change_due': 'المتبقي للعميل',
      'payment_method': 'طريقة الدفع',
      'items_count': 'عدد المنتجات',
      'unit_price': 'سعر الوحدة',
      'line_total': 'الإجمالي',
      'print_receipt': 'طباعة الفاتورة',
      'reprint_receipt': 'إعادة طباعة الفاتورة',

      // ── Online Orders & Delivery ──────────────────────────
      'kpi_pending_online': 'طلبات الموقع والتطبيق المعلقة',
      'kpi_preparing_online': 'طلبات قيد التجهيز والتعبئة',
      'kpi_delivery_online': 'طلبات خرجت للتوصيل (COD)',
      'order_pending_desc': 'تتطلب قبولاً أو رفضاً فورياً',
      'order_preparing_desc': 'امسح الباركود للتحقق قبل تسليم السائق',
      'order_delivery_desc': 'تحصيل نقدي إلزامي عند الاستلام',
      'filter_all_orders': 'جميع الطلبات',
      'filter_pending': 'قيد المراجعة',
      'filter_preparing': 'قيد التجهيز',
      'filter_delivery': 'خرج للتوصيل',
      'filter_cancelled': 'ملغاة',
      'order_number': 'طلب رقم #',
      'accept_order': 'قبول الطلب',
      'reject_order': 'رفض الطلب',
      'customer_info': 'بيانات العميل',
      'delivery_address': 'عنوان التوصيل:',
      'scan_packing_hint': 'امسح باركود المنتج للتحقق من التعبئة...',
      'verify_item': 'تأكيد فحص الصنف',
      'missing_item': 'صنف غير متوفر؟',
      'print_and_dispatch': 'طباعة الفاتورة وإرسال الشحنة (خرج للتوصيل)',
      'select_order_hint': 'اختر طلباً لمعاينة التفاصيل وفحص أصناف الطرد.',
      'no_orders_match': 'لا توجد طلبات تطابق هذه التصفية.',
      'payment_cod_notice': 'الدفع نقداً عند الاستلام فقط (COD)',
      'item_out_of_stock': 'صنف غير متوفر بالمخزون',
      'replace_similar_opt': 'الخيار الأول: استبدال بصنف مشابه',
      'cancel_order_opt': 'الخيار الثاني: إلغاء الطلب بناءً على رغبة العميل',
      'cancel_entire_order': 'إلغاء الطلب بالكامل',
      'confirm_replacement': 'تأكيد استبدال الصنف',

      // ── Product Categories ───────────────────────────────
      'cat_beverages': 'مشروبات',
      'cat_dairy': 'ألبان وبيض',
      'cat_bakery': 'مخبوزات',
      'cat_snacks': 'وجبات خفيفة ومسليات',
      'cat_pantry': 'بقالة وتموين',
      'cat_meat': 'لحوم ودواجن',
      'cat_household': 'منظفات ومنزليات',
      'cat_produce': 'خضروات وفواكه',

      // ── Order Status Display Labels ───────────────────────
      'status_pending': 'قيد المراجعة',
      'status_preparing': 'قيد التجهيز',
      'status_out_for_delivery': 'خرج للتوصيل',
      'status_cancelled': 'ملغي',
      'status_delivered': 'تم التسليم',

      // ── KPI Unit Labels ───────────────────────────────────
      'kpi_orders_unit': 'طلب',
      'kpi_in_prep_unit': 'قيد التجهيز',
      'kpi_en_route_unit': 'في الطريق',

      // ── Field Labels ─────────────────────────────────────
      'label_phone': 'الهاتف',
      'label_email': 'البريد الإلكتروني',
      'label_barcode': 'الباركود',
      'label_cod': 'دفع عند الاستلام',
      'label_items': 'أصناف',
      'ordered_products': 'الأصناف المطلوبة',

      // ── Reject Dialog ─────────────────────────────────────
      'reject_order_title': 'رفض الطلب',
      'reject_reason_hint': 'سبب الرفض',
      'confirm_reject': 'تأكيد الرفض',

      // ── Snackbar & Banner Messages ────────────────────────
      'scan_no_match': 'الباركود الممسوح لا يتطابق مع أي صنف في هذا الطلب.',
      'dispatch_snackbar': 'تمت طباعة فاتورة الطلب {id} وإرساله! الحالة: «خرج للتوصيل».',
      'dispatched_notice': 'تمت طباعة الفاتورة وتسليم الشحنة للمندوب. يقوم السائق بتحصيل الدفع نقداً عند الاستلام.',
      'order_cancelled_label': 'الطلب ملغي',
      'rejected_by_cashier': 'رفضه الكاشير',
    },
  };

  /// Dynamic bilingual translator.
  /// Seamlessly resolves canonical keys, exact English text, or case-insensitive strings.
  String tr(String key) {
    final langCode = locale.languageCode;
    if (langCode == 'ar') {
      // 1. Direct key lookup in Arabic dictionary
      if (_localizedValues['ar']?.containsKey(key) ?? false) {
        return _localizedValues['ar']![key]!;
      }

      final trimmed = key.trim();
      if (_localizedValues['ar']?.containsKey(trimmed) ?? false) {
        return _localizedValues['ar']![trimmed]!;
      }

      // 2. Case-insensitive key lookup
      final lower = trimmed.toLowerCase();
      for (final entry in _localizedValues['ar']!.entries) {
        if (entry.key.toLowerCase() == lower) {
          return entry.value;
        }
      }

      // 3. Reverse lookup if English value was provided directly
      for (final enEntry in _localizedValues['en']!.entries) {
        if (enEntry.value.toLowerCase() == lower || enEntry.key.toLowerCase() == lower) {
          final arVal = _localizedValues['ar']![enEntry.key];
          if (arVal != null) return arVal;
        }
      }

      // 4. Common word and category replacements
      final arCat = _translateDynamicPhrases(trimmed);
      if (arCat != null) return arCat;
    }

    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String? _translateDynamicPhrases(String text) {
    final lower = text.toLowerCase();
    switch (lower) {
      case 'beverages': return 'مشروبات';
      case 'dairy & eggs': return 'ألبان وبيض';
      case 'bakery': return 'مخبوزات';
      case 'snacks': return 'مسليات ومقرمشات';
      case 'pantry': return 'بقالة ومؤن';
      case 'meat & poultry': return 'لحوم ودواجن';
      case 'household': return 'منظفات ومنزليات';
      case 'produce': return 'خضار وفواكه';
      case 'egp': return 'ج.م';
      case 'skus': return 'أصناف';
      case 'units': return 'قطع';
      case 'cash': return 'نقداً';
      case 'card': return 'بطاقة';
      case 'morning (08:00 - 16:00)': return 'صباحية (08:00 - 16:00)';
      case 'evening (16:00 - 00:00)': return 'مسائية (16:00 - 00:00)';
      case 'night (00:00 - 08:00)': return 'ليلية (00:00 - 08:00)';
      case 'full shift (09:00 - 17:00)': return 'دوام كامل (09:00 - 17:00)';
      default: return null;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension on [BuildContext] for ergonomic, reactive translations.
extension LocalizationContextExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).tr(key);
}

/// Extension on [String] for convenient inline translation calls.
extension LocalizationStringExtension on String {
  String tr(BuildContext context) => AppLocalizations.of(context).tr(this);
}
