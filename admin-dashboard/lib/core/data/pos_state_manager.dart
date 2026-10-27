import 'package:flutter/foundation.dart';
import 'mock_data.dart';

/// Available application roles in the Cyborg Supermarket POS system.
enum UserRole {
  owner,
  manager,
  cashier,
  stockManager,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner / Executive';
      case UserRole.manager:
        return 'Store Manager';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.stockManager:
        return 'Stock Manager';
    }
  }

  String get badgeLabel {
    switch (this) {
      case UserRole.owner:
        return 'OWNER';
      case UserRole.manager:
        return 'MANAGER';
      case UserRole.cashier:
        return 'CASHIER';
      case UserRole.stockManager:
        return 'STOCK MGR';
    }
  }
}

/// Active user session information.
class UserSession {
  final String userId;
  final String name;
  final UserRole role;
  final String? terminalId;
  final String? shiftId;

  const UserSession({
    required this.userId,
    required this.name,
    required this.role,
    this.terminalId,
    this.shiftId,
  });
}

/// Dynamic product model with mutable live store and warehouse inventory stock.
class LiveStoreProduct {
  final int id;
  final String barcode;
  final String code;
  final String nameEn;
  final String nameAr;
  final double price;
  final String category;
  int stock; // In-store stock available for register checkout
  final int minThreshold;
  int warehouseStock; // Central warehouse stock
  final int minWarehouseThreshold;

  LiveStoreProduct({
    required this.id,
    required this.barcode,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.category,
    required this.stock,
    this.minThreshold = 50,
    this.warehouseStock = 450,
    this.minWarehouseThreshold = 100,
  });

  bool get isLowStock => stock <= minThreshold;
  bool get isOutOfStock => stock <= 0;
  bool get isWarehouseLowStock => warehouseStock <= minWarehouseThreshold;

  LiveStoreProduct copyWith({
    int? stock,
    int? warehouseStock,
  }) {
    return LiveStoreProduct(
      id: id,
      barcode: barcode,
      code: code,
      nameEn: nameEn,
      nameAr: nameAr,
      price: price,
      category: category,
      stock: stock ?? this.stock,
      minThreshold: minThreshold,
      warehouseStock: warehouseStock ?? this.warehouseStock,
      minWarehouseThreshold: minWarehouseThreshold,
    );
  }
}

/// Log record for returned products sold by cashiers.
class ReturnedProductRecord {
  final String returnId;
  final String barcode;
  final String productCode;
  final String productName;
  final int quantity;
  final double refundAmount;
  final String originalCashier;
  final String originalReceiptNo;
  final String reason;
  final DateTime timestamp;
  final String status;

  ReturnedProductRecord({
    required this.returnId,
    required this.barcode,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.refundAmount,
    required this.originalCashier,
    required this.originalReceiptNo,
    required this.reason,
    required this.timestamp,
    this.status = 'Returned',
  });
}

/// Log record for damaged stock automatically deducted from cashier POS inventory.
class DamagedGoodRecord {
  final String damageId;
  final String barcode;
  final String productCode;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalLoss;
  final String reason;
  final String loggedBy;
  final DateTime timestamp;

  DamagedGoodRecord({
    required this.damageId,
    required this.barcode,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalLoss,
    required this.reason,
    required this.loggedBy,
    required this.timestamp,
  });
}

/// Model representing an active cashier with live sales performance statistics.
class OnlineCashierStats {
  final String cashierId;
  final String name;
  final String terminalId;
  final String shiftId;
  final DateTime shiftStartTime;
  String status; // 'Active', 'In Transaction', 'Idle'
  double totalSales;
  double cashSales;
  double visaSales;
  int transactionCount;
  int totalItemsSold;
  List<Map<String, dynamic>> recentTransactions;

  OnlineCashierStats({
    required this.cashierId,
    required this.name,
    required this.terminalId,
    required this.shiftId,
    required this.shiftStartTime,
    this.status = 'Active',
    this.totalSales = 0.0,
    this.cashSales = 0.0,
    this.visaSales = 0.0,
    this.transactionCount = 0,
    this.totalItemsSold = 0,
    List<Map<String, dynamic>>? recentTransactions,
  }) : recentTransactions = recentTransactions ?? [];

  double get averageBasketValue =>
      transactionCount == 0 ? 0.0 : totalSales / transactionCount;

  Duration get shiftDuration => DateTime.now().difference(shiftStartTime);
}

/// Model for employees managed by Store Manager (Cashiers & Stock Managers).
class EmployeeProfile {
  final String id;
  String name;
  UserRole role;
  String phone;
  String nationalId;
  String shiftSchedule; // e.g. "Morning (08:00 - 16:00)"
  String assignedTerminal; // e.g. "POS-01", "POS-02", "Warehouse Bay 1"
  DateTime hireDate;
  bool isActive;

  EmployeeProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.nationalId,
    required this.shiftSchedule,
    required this.assignedTerminal,
    required this.hireDate,
    this.isActive = true,
  });
}

/// Model for employee shift attendance logs with automatic lateness calculation.
class AttendanceLogEntry {
  final String entryId;
  final String employeeId;
  final String employeeName;
  final UserRole role;
  final String shiftName;
  final DateTime scheduledStartTime;
  final DateTime actualPunchInTime;
  final int latenessMinutes;
  final String status; // 'On-Time', 'Late', 'Absent'
  final String notes;

  AttendanceLogEntry({
    required this.entryId,
    required this.employeeId,
    required this.employeeName,
    required this.role,
    required this.shiftName,
    required this.scheduledStartTime,
    required this.actualPunchInTime,
    required this.latenessMinutes,
    required this.status,
    this.notes = '',
  });

  bool get isLate => latenessMinutes > 5;
}

/// Store low stock reorder request sent by Store Manager to Stock Manager for Approval/Denial.
class StockReorderRequest {
  final String requestId;
  final String productBarcode;
  final String productCode;
  final String productName;
  final int currentStock;
  final int requiredQuantity;
  final String requestedBy;
  final DateTime requestTime;
  String status; // 'Pending Approval/Denial', 'Approved', 'Denied', 'Fulfilled'
  String? reviewedBy;
  DateTime? reviewTime;
  String? decisionNote;
  bool isFulfilled;
  DateTime? fulfilledTime;

  StockReorderRequest({
    required this.requestId,
    required this.productBarcode,
    required this.productCode,
    required this.productName,
    required this.currentStock,
    required this.requiredQuantity,
    required this.requestedBy,
    required this.requestTime,
    this.status = 'Pending Approval/Denial',
    this.reviewedBy,
    this.reviewTime,
    this.decisionNote,
    this.isFulfilled = false,
    this.fulfilledTime,
  });
}

/// Warehouse restock request sent by Stock Manager to Store Manager (when warehouse itself is low).
class WarehouseRestockRequest {
  final String requestId;
  final String productBarcode;
  final String productCode;
  final String productName;
  final int currentWarehouseStock;
  final int requestedQuantity;
  final String supplier;
  final String requestedBy;
  final DateTime requestTime;
  String status; // 'Awaiting Store Manager Approval', 'Approved', 'Rejected'
  String? decisionNote;
  String? reviewedBy;
  DateTime? reviewTime;

  WarehouseRestockRequest({
    required this.requestId,
    required this.productBarcode,
    required this.productCode,
    required this.productName,
    required this.currentWarehouseStock,
    required this.requestedQuantity,
    required this.supplier,
    required this.requestedBy,
    required this.requestTime,
    this.status = 'Awaiting Store Manager Approval',
    this.decisionNote,
    this.reviewedBy,
    this.reviewTime,
  });
}

/// Stock receiving record confirmed by Store Manager from warehouse delivery.
class StockReceivingRecord {
  final String receivingId;
  final String poNumber;
  final String supplier;
  final String barcode;
  final String productCode;
  final String productName;
  final int quantityReceived;
  final String batchNumber;
  final DateTime expiryDate;
  final String receivedBy;
  final DateTime timestamp;
  final String status;

  StockReceivingRecord({
    required this.receivingId,
    required this.poNumber,
    required this.supplier,
    required this.barcode,
    required this.productCode,
    required this.productName,
    required this.quantityReceived,
    required this.batchNumber,
    required this.expiryDate,
    required this.receivedBy,
    required this.timestamp,
    this.status = 'Received & Available in POS',
  });
}

/// Single item line in an online customer order.
class OnlineOrderItem {
  final int productId;
  final String barcode;
  final String code;
  final String nameEn;
  final String nameAr;
  final double unitPrice;
  int quantity;
  bool isScanned; // Verified by cashier during packing

  OnlineOrderItem({
    required this.productId,
    required this.barcode,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.unitPrice,
    required this.quantity,
    this.isScanned = false,
  });

  double get lineTotal => unitPrice * quantity;
}

/// Model representing incoming online/web/app customer orders. Payment is strictly COD.
class OnlineOrder {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String? customerEmail;
  final String paymentMethod; // Strictly COD
  final List<OnlineOrderItem> items;
  String status; // 'Pending', 'Preparing', 'Out for Delivery', 'Cancelled'
  final DateTime createdAt;
  String? cancelReason;
  String? replacementNotes;
  bool receiptPrinted;

  OnlineOrder({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.customerEmail,
    this.paymentMethod = 'COD (Cash on Delivery)',
    required this.items,
    this.status = 'Pending',
    required this.createdAt,
    this.cancelReason,
    this.replacementNotes,
    this.receiptPrinted = false,
  });

  double get subtotal => items.fold(0.0, (acc, item) => acc + item.lineTotal);
  double get tax => subtotal * 0.14;
  double get total => subtotal + tax;
  int get totalItemCount => items.fold(0, (acc, item) => acc + item.quantity);
  bool get allItemsScanned => items.every((i) => i.isScanned);
}

/// Unified receipt model for both In-Store and Online orders.
class UnifiedReceiptRecord {
  final String receiptNo;
  final String source; // 'In-Store' or 'Online'
  final DateTime timestamp;
  final String cashierName;
  final String terminalId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final List<MockCartLine> items;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod; // 'CASH', 'VISA', 'COD'
  final double? tenderedAmount;
  final double? changeAmount;

  UnifiedReceiptRecord({
    required this.receiptNo,
    required this.source,
    required this.timestamp,
    required this.cashierName,
    required this.terminalId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.tenderedAmount,
    this.changeAmount,
  });

  int get totalItemCount => items.fold(0, (acc, i) => acc + i.quantity);
  bool get isOnline => source == 'Online';
}

/// Audit log entry for every Stock Manager and Manager inventory activity.
class AuditLogEntry {
  final String logId;
  final String actionType; // 'REQUEST_APPROVED', 'REQUEST_DENIED', 'FULFILLED', 'PRODUCT_ADDED', 'RESTOCKED', 'ORDER_DISPATCHED'
  final String productName;
  final String barcode;
  final int quantity;
  final String performedBy;
  final DateTime timestamp;
  final String referenceNo;
  final String notes;

  AuditLogEntry({
    required this.logId,
    required this.actionType,
    required this.productName,
    required this.barcode,
    required this.quantity,
    required this.performedBy,
    required this.timestamp,
    required this.referenceNo,
    this.notes = '',
  });
}

/// Centralized state manager for all multi-role POS workflows across Manager, Cashier, and Stock Manager.
class PosStateManager extends ChangeNotifier {
  static final PosStateManager instance = PosStateManager._internal();

  PosStateManager._internal() {
    _initData();
  }

  // ── Live Inventory (Store & Warehouse) ─────────────────────────
  final List<LiveStoreProduct> _products = [];
  List<LiveStoreProduct> get products => List.unmodifiable(_products);

  // ── Returns & Refunds ──────────────────────────────────────────
  final List<ReturnedProductRecord> _returns = [];
  List<ReturnedProductRecord> get returns => List.unmodifiable(_returns);

  // ── Damaged Goods ──────────────────────────────────────────────
  final List<DamagedGoodRecord> _damagedGoods = [];
  List<DamagedGoodRecord> get damagedGoods => List.unmodifiable(_damagedGoods);

  // ── Online Cashiers ────────────────────────────────────────────
  final List<OnlineCashierStats> _onlineCashiers = [];
  List<OnlineCashierStats> get onlineCashiers => List.unmodifiable(_onlineCashiers);

  // ── Employees & Shifts ─────────────────────────────────────────
  final List<EmployeeProfile> _employees = [];
  List<EmployeeProfile> get employees => List.unmodifiable(_employees);

  // ── Attendance Logs ────────────────────────────────────────────
  final List<AttendanceLogEntry> _attendanceLogs = [];
  List<AttendanceLogEntry> get attendanceLogs => List.unmodifiable(_attendanceLogs);

  // ── Store Stock Reorder Requests (Manager → Stock Manager) ──────
  final List<StockReorderRequest> _reorderRequests = [];
  List<StockReorderRequest> get reorderRequests => List.unmodifiable(_reorderRequests);

  // ── Warehouse Restock Requests (Stock Manager → Store Manager) ──
  final List<WarehouseRestockRequest> _warehouseRestockRequests = [];
  List<WarehouseRestockRequest> get warehouseRestockRequests => List.unmodifiable(_warehouseRestockRequests);

  // ── Stock Receiving Logs ───────────────────────────────────────
  final List<StockReceivingRecord> _receivingLogs = [];
  List<StockReceivingRecord> get receivingLogs => List.unmodifiable(_receivingLogs);

  // ── Online Orders (COD) ────────────────────────────────────────
  final List<OnlineOrder> _onlineOrders = [];
  List<OnlineOrder> get onlineOrders => List.unmodifiable(_onlineOrders);

  // ── Combined Receipts History (In-Store & Online) ──────────────
  final List<UnifiedReceiptRecord> _unifiedReceipts = [];
  List<UnifiedReceiptRecord> get unifiedReceipts => List.unmodifiable(_unifiedReceipts);

  // ── Audit & Warehouse Logs ─────────────────────────────────────
  final List<AuditLogEntry> _auditLogs = [];
  List<AuditLogEntry> get auditLogs => List.unmodifiable(_auditLogs);

  // ── Active Session ─────────────────────────────────────────────
  UserSession? _currentSession;
  UserSession? get currentSession => _currentSession;

  void setCurrentSession(UserSession? session) {
    _currentSession = session;
    notifyListeners();
  }

  void logout() {
    _currentSession = null;
    notifyListeners();
  }

  // ── Initialize Initial Mock Data ───────────────────────────────
  void _initData() {
    // 1. Initialize products
    for (final p in MockData.products) {
      _products.add(LiveStoreProduct(
        id: p.id,
        barcode: p.barcode,
        code: p.code,
        nameEn: p.nameEn,
        nameAr: p.nameAr,
        price: p.price,
        category: p.category,
        stock: p.stock,
        minThreshold: _calculateMinThreshold(p.category),
        warehouseStock: p.stock * 3,
        minWarehouseThreshold: 120,
      ));
    }

    // Low stock items for store
    final freshBananas = _products.firstWhere((p) => p.code == 'FRT-001', orElse: () => _products[13]);
    freshBananas.stock = 14;
    freshBananas.warehouseStock = 320;

    final freshChicken = _products.firstWhere((p) => p.code == 'MEA-001', orElse: () => _products[15]);
    freshChicken.stock = 8;
    freshChicken.warehouseStock = 240;

    final beefKofta = _products.firstWhere((p) => p.code == 'MEA-002', orElse: () => _products[16]);
    beefKofta.stock = 5;
    beefKofta.warehouseStock = 80; // Also low in warehouse!

    final basmatiRice = _products.firstWhere((p) => p.code == 'GRO-001', orElse: () => _products[19]);
    basmatiRice.stock = 12;
    basmatiRice.warehouseStock = 65; // Also low in warehouse!

    final now = DateTime.now();

    // 2. Initial online orders
    _onlineOrders.addAll([
      OnlineOrder(
        orderId: 'WEB-9041',
        customerName: 'Yasmine Mostafa',
        customerPhone: '+20 100 889 9123',
        customerAddress: 'Bldg 14, Rd 9, Maadi, Cairo',
        customerEmail: 'yasmine.m@example.com',
        paymentMethod: 'COD (Cash on Delivery)',
        createdAt: now.subtract(const Duration(minutes: 15)),
        status: 'Pending',
        items: [
          OnlineOrderItem(
            productId: 1,
            barcode: '6221033001012',
            code: 'BEV-001',
            nameEn: 'Coca-Cola 330ml',
            nameAr: 'كوكاكولا ٣٣٠ مل',
            unitPrice: 12.00,
            quantity: 4,
          ),
          OnlineOrderItem(
            productId: 4,
            barcode: '6223000103012',
            code: 'DAI-001',
            nameEn: 'Juhayna Full Cream Milk 1L',
            nameAr: 'لبن جهينة كامل ١ لتر',
            unitPrice: 38.00,
            quantity: 2,
          ),
          OnlineOrderItem(
            productId: 8,
            barcode: '6224007400015',
            code: 'SNK-001',
            nameEn: 'Chipsy Cheese 65g',
            nameAr: 'شيبسى بالجبنة ٦٥ جم',
            unitPrice: 18.00,
            quantity: 3,
          ),
        ],
      ),
      OnlineOrder(
        orderId: 'WEB-9038',
        customerName: 'Karim Abdel-Aziz',
        customerPhone: '+20 111 445 2210',
        customerAddress: '42 El-Horreya St, Heliopolis, Cairo',
        customerEmail: 'karim.az@example.com',
        paymentMethod: 'COD (Cash on Delivery)',
        createdAt: now.subtract(const Duration(minutes: 45)),
        status: 'Preparing',
        items: [
          OnlineOrderItem(
            productId: 20,
            barcode: '6229000701014',
            code: 'GRO-001',
            nameEn: 'Basmati Rice 5kg',
            nameAr: 'أرز بسمتى ٥ كيلو',
            unitPrice: 160.00,
            quantity: 1,
            isScanned: true,
          ),
          OnlineOrderItem(
            productId: 10,
            barcode: '6224011001012',
            code: 'CLE-001',
            nameEn: 'Persil Powder 2.5kg',
            nameAr: 'برسيل بودرة ٢.٥ كيلو',
            unitPrice: 125.00,
            quantity: 1,
          ),
        ],
      ),
      OnlineOrder(
        orderId: 'WEB-9030',
        customerName: 'Nouran Salem',
        customerPhone: '+20 122 778 3341',
        customerAddress: 'Villa 12, Compound Al-Rehab, New Cairo',
        customerEmail: 'nouran.s@example.com',
        paymentMethod: 'COD (Cash on Delivery)',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: 'Out for Delivery',
        items: [
          OnlineOrderItem(
            productId: 3,
            barcode: '6221033001036',
            code: 'BEV-003',
            nameEn: 'Dasani Water 1.5L',
            nameAr: 'مياه دسانى ١.٥ لتر',
            unitPrice: 8.50,
            quantity: 6,
            isScanned: true,
          ),
        ],
      ),
    ]);

    // 3. Initial unified receipts history
    _unifiedReceipts.addAll([
      UnifiedReceiptRecord(
        receiptNo: 'REC-904121',
        source: 'In-Store',
        timestamp: now.subtract(const Duration(minutes: 25)),
        cashierName: 'Ahmed Hassan',
        terminalId: 'POS-01',
        items: [
          MockCartLine(productId: 1, barcode: '6221033001012', nameEn: 'Coca-Cola 330ml', nameAr: 'كوكاكولا ٣٣٠ مل', quantity: 2, unitPrice: 12.00),
          MockCartLine(productId: 8, barcode: '6224007400015', nameEn: 'Chipsy Cheese 65g', nameAr: 'شيبسى بالجبنة ٦٥ جم', quantity: 1, unitPrice: 18.00),
        ],
        subtotal: 42.00,
        tax: 5.88,
        total: 47.88,
        paymentMethod: 'CASH',
        tenderedAmount: 50.00,
        changeAmount: 2.12,
      ),
      UnifiedReceiptRecord(
        receiptNo: 'REC-904118',
        source: 'In-Store',
        timestamp: now.subtract(const Duration(minutes: 48)),
        cashierName: 'Ahmed Hassan',
        terminalId: 'POS-01',
        items: [
          MockCartLine(productId: 20, barcode: '6229000701014', nameEn: 'Basmati Rice 5kg', nameAr: 'أرز بسمتى ٥ كيلو', quantity: 1, unitPrice: 160.00),
          MockCartLine(productId: 4, barcode: '6223000103012', nameEn: 'Juhayna Full Cream Milk 1L', nameAr: 'لبن جهينة كامل ١ لتر', quantity: 2, unitPrice: 38.00),
          MockCartLine(productId: 14, barcode: '6226000401015', nameEn: 'Fresh Bananas 1kg', nameAr: 'موز طازج ١ ك', quantity: 2, unitPrice: 19.06),
        ],
        subtotal: 274.12,
        tax: 38.38,
        total: 312.50,
        paymentMethod: 'VISA',
      ),
      UnifiedReceiptRecord(
        receiptNo: 'REC-WEB-9030',
        source: 'Online',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        cashierName: 'Layla Nour (Dispatcher)',
        terminalId: 'WEB-DISPATCH',
        customerName: 'Nouran Salem',
        customerPhone: '+20 122 778 3341',
        customerEmail: 'nouran.s@example.com',
        customerAddress: 'Villa 12, Compound Al-Rehab, New Cairo',
        items: [
          MockCartLine(productId: 3, barcode: '6221033001036', nameEn: 'Dasani Water 1.5L', nameAr: 'مياه دسانى ١.٥ لتر', quantity: 6, unitPrice: 8.50),
        ],
        subtotal: 51.00,
        tax: 7.14,
        total: 58.14,
        paymentMethod: 'COD',
      ),
      UnifiedReceiptRecord(
        receiptNo: 'REC-892104',
        source: 'In-Store',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
        cashierName: 'Sara Ibrahim',
        terminalId: 'POS-02',
        items: [
          MockCartLine(productId: 20, barcode: '6229000701014', nameEn: 'Basmati Rice 5kg', nameAr: 'أرز بسمتى ٥ كيلو', quantity: 1, unitPrice: 160.00),
          MockCartLine(productId: 4, barcode: '6223000103012', nameEn: 'Juhayna Full Cream Milk 1L', nameAr: 'لبن جهينة كامل ١ لتر', quantity: 2, unitPrice: 38.00),
        ],
        subtotal: 236.00,
        tax: 33.04,
        total: 269.04,
        paymentMethod: 'VISA',
      ),
    ]);

    // 4. Initial audit logs
    _auditLogs.addAll([
      AuditLogEntry(
        logId: 'AUD-901',
        actionType: 'RESTOCK_IMPORTED',
        productName: 'Chipsy Cheese 65g',
        barcode: '6224007400015',
        quantity: 200,
        performedBy: 'Stock Mgr Hossam El-Din',
        timestamp: now.subtract(const Duration(hours: 3)),
        referenceNo: 'PO-2026-8850',
        notes: 'Warehouse shipment logged into Bay 2',
      ),
      AuditLogEntry(
        logId: 'AUD-902',
        actionType: 'REQUEST_APPROVED',
        productName: 'Fresh Bananas 1kg',
        barcode: '6226000401015',
        quantity: 100,
        performedBy: 'Stock Mgr Hossam El-Din',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 10)),
        referenceNo: 'REQ-7001',
        notes: 'Approved store reorder for fresh fruit counter',
      ),
    ]);

    // Initial store requests
    _reorderRequests.addAll([
      StockReorderRequest(
        requestId: 'REQ-7001',
        productBarcode: '6226000401015',
        productCode: 'FRT-001',
        productName: 'Fresh Bananas 1kg',
        currentStock: 14,
        requiredQuantity: 100,
        requestedBy: 'Manager Tarek Mansour',
        requestTime: now.subtract(const Duration(hours: 1, minutes: 20)),
        status: 'Approved',
        reviewedBy: 'Stock Mgr Hossam El-Din',
        reviewTime: now.subtract(const Duration(hours: 1, minutes: 10)),
        decisionNote: 'Ready for fulfillment from Bay 1',
      ),
      StockReorderRequest(
        requestId: 'REQ-7002',
        productBarcode: '6227000501018',
        productCode: 'MEA-001',
        productName: 'Fresh Chicken 1kg',
        currentStock: 8,
        requiredQuantity: 60,
        requestedBy: 'Manager Tarek Mansour',
        requestTime: now.subtract(const Duration(hours: 2, minutes: 5)),
        status: 'Pending Approval/Denial',
      ),
    ]);

    // Initial warehouse restock requests
    _warehouseRestockRequests.addAll([
      WarehouseRestockRequest(
        requestId: 'WH-REQ-101',
        productBarcode: '6227000501025',
        productCode: 'MEA-002',
        productName: 'Beef Kofta 500g',
        currentWarehouseStock: 80,
        requestedQuantity: 300,
        supplier: 'Egyptian Meat Imports Co.',
        requestedBy: 'Stock Mgr Hossam El-Din',
        requestTime: now.subtract(const Duration(hours: 4)),
        status: 'Awaiting Store Manager Approval',
      ),
      WarehouseRestockRequest(
        requestId: 'WH-REQ-102',
        productBarcode: '6229000701014',
        productCode: 'GRO-001',
        productName: 'Basmati Rice 5kg',
        currentWarehouseStock: 65,
        requestedQuantity: 200,
        supplier: 'Al-Doha Grain Mills',
        requestedBy: 'Stock Mgr Hossam El-Din',
        requestTime: now.subtract(const Duration(hours: 2, minutes: 30)),
        status: 'Awaiting Store Manager Approval',
      ),
    ]);

    // Online cashiers
    _onlineCashiers.addAll([
      OnlineCashierStats(
        cashierId: '1001',
        name: 'Ahmed Hassan',
        terminalId: 'POS-01',
        shiftId: 'SHIFT-8810',
        shiftStartTime: now.subtract(const Duration(hours: 4, minutes: 20)),
        status: 'Active',
        totalSales: 4850.50,
        cashSales: 2900.00,
        visaSales: 1950.50,
        transactionCount: 38,
        totalItemsSold: 142,
        recentTransactions: [
          {'receipt': 'REC-904121', 'time': '10 mins ago', 'total': 47.88, 'type': 'CASH', 'items': 3},
          {'receipt': 'REC-904118', 'time': '22 mins ago', 'total': 312.50, 'type': 'VISA', 'items': 9},
        ],
      ),
      OnlineCashierStats(
        cashierId: '1002',
        name: 'Sara Ibrahim',
        terminalId: 'POS-02',
        shiftId: 'SHIFT-8812',
        shiftStartTime: now.subtract(const Duration(hours: 3, minutes: 45)),
        status: 'In Transaction',
        totalSales: 6320.00,
        cashSales: 3100.00,
        visaSales: 3220.00,
        transactionCount: 46,
        totalItemsSold: 198,
      ),
      OnlineCashierStats(
        cashierId: '1003',
        name: 'Mohamed Ali',
        terminalId: 'POS-03',
        shiftId: 'SHIFT-8815',
        shiftStartTime: now.subtract(const Duration(hours: 1, minutes: 30)),
        status: 'Idle',
        totalSales: 1890.00,
        cashSales: 1200.00,
        visaSales: 690.00,
        transactionCount: 14,
        totalItemsSold: 56,
      ),
      OnlineCashierStats(
        cashierId: '1004',
        name: 'Layla Nour',
        terminalId: 'WEB-DISPATCH',
        shiftId: 'SHIFT-8820',
        shiftStartTime: now.subtract(const Duration(hours: 2, minutes: 10)),
        status: 'Active',
        totalSales: 8940.00,
        cashSales: 4500.00,
        visaSales: 4440.00,
        transactionCount: 29,
        totalItemsSold: 215,
      ),
    ]);

    // Initial employees
    _employees.addAll([
      EmployeeProfile(
        id: 'EMP-1001',
        name: 'Ahmed Hassan',
        role: UserRole.cashier,
        phone: '+20 100 234 5678',
        nationalId: '29801011234567',
        shiftSchedule: 'Morning (08:00 - 16:00)',
        assignedTerminal: 'POS-01',
        hireDate: DateTime(2023, 3, 15),
      ),
      EmployeeProfile(
        id: 'EMP-1002',
        name: 'Sara Ibrahim',
        role: UserRole.cashier,
        phone: '+20 101 987 6543',
        nationalId: '29905141234890',
        shiftSchedule: 'Morning (08:00 - 16:00)',
        assignedTerminal: 'POS-02',
        hireDate: DateTime(2023, 6, 1),
      ),
      EmployeeProfile(
        id: 'EMP-1003',
        name: 'Mohamed Ali',
        role: UserRole.cashier,
        phone: '+20 102 334 4556',
        nationalId: '29711201239912',
        shiftSchedule: 'Evening (16:00 - 00:00)',
        assignedTerminal: 'POS-03',
        hireDate: DateTime(2023, 9, 10),
      ),
      EmployeeProfile(
        id: 'EMP-2001',
        name: 'Hossam El-Din',
        role: UserRole.stockManager,
        phone: '+20 109 445 6677',
        nationalId: '29503151237788',
        shiftSchedule: 'Full Shift (09:00 - 17:00)',
        assignedTerminal: 'Warehouse Bay 1',
        hireDate: DateTime(2022, 11, 20),
      ),
      EmployeeProfile(
        id: 'EMP-3001',
        name: 'Tarek Mansour',
        role: UserRole.manager,
        phone: '+20 100 556 7890',
        nationalId: '29001011234567',
        shiftSchedule: 'Branch Operations (08:00 - 18:00)',
        assignedTerminal: 'Main Branch HQ Desk',
        hireDate: DateTime(2022, 1, 10),
      ),
      EmployeeProfile(
        id: 'EMP-3002',
        name: 'Mona El-Shazly',
        role: UserRole.manager,
        phone: '+20 102 778 9900',
        nationalId: '29204051239988',
        shiftSchedule: 'Evening Operations (14:00 - 23:00)',
        assignedTerminal: 'Downtown Branch Desk',
        hireDate: DateTime(2023, 4, 1),
      ),
    ]);

    // Attendance
    _attendanceLogs.addAll([
      AttendanceLogEntry(
        entryId: 'ATT-301',
        employeeId: 'EMP-1001',
        employeeName: 'Ahmed Hassan',
        role: UserRole.cashier,
        shiftName: 'Morning (08:00 - 16:00)',
        scheduledStartTime: DateTime(now.year, now.month, now.day, 8, 0),
        actualPunchInTime: DateTime(now.year, now.month, now.day, 7, 56),
        latenessMinutes: 0,
        status: 'On-Time',
      ),
      AttendanceLogEntry(
        entryId: 'ATT-302',
        employeeId: 'EMP-1002',
        employeeName: 'Sara Ibrahim',
        role: UserRole.cashier,
        shiftName: 'Morning (08:00 - 16:00)',
        scheduledStartTime: DateTime(now.year, now.month, now.day, 8, 0),
        actualPunchInTime: DateTime(now.year, now.month, now.day, 8, 24),
        latenessMinutes: 24,
        status: 'Late (+24m)',
      ),
    ]);
  }

  int _calculateMinThreshold(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'meat':
        return 30;
      case 'dairy':
      case 'bakery':
        return 40;
      default:
        return 50;
    }
  }

  // ── Product Helpers ────────────────────────────────────────────
  LiveStoreProduct? findProductByBarcode(String barcode) {
    final bc = barcode.trim();
    try {
      return _products.firstWhere((p) => p.barcode == bc);
    } catch (_) {
      return null;
    }
  }

  // ── Online Orders Operations (Cashier Role) ───────────────────
  void acceptOnlineOrder(String orderId) {
    final order = _onlineOrders.firstWhere((o) => o.orderId == orderId);
    order.status = 'Preparing';
    _logAudit(
      actionType: 'ORDER_ACCEPTED',
      productName: 'Order ${order.orderId}',
      barcode: '',
      quantity: order.totalItemCount,
      performedBy: 'Cashier Dispatcher',
      refNo: order.orderId,
      notes: 'Order accepted for packing (COD)',
    );
    notifyListeners();
  }

  void rejectOnlineOrder(String orderId, String reason) {
    final order = _onlineOrders.firstWhere((o) => o.orderId == orderId);
    order.status = 'Cancelled';
    order.cancelReason = reason;
    _logAudit(
      actionType: 'ORDER_CANCELLED',
      productName: 'Order ${order.orderId}',
      barcode: '',
      quantity: order.totalItemCount,
      performedBy: 'Cashier Dispatcher',
      refNo: order.orderId,
      notes: 'Order rejected: $reason',
    );
    notifyListeners();
  }

  void handleMissingOnlineItem({
    required String orderId,
    required String missingBarcode,
    required String action, // 'REPLACE' or 'CANCEL'
    String? replacementBarcode,
    String? note,
  }) {
    final order = _onlineOrders.firstWhere((o) => o.orderId == orderId);

    if (action == 'CANCEL') {
      order.status = 'Cancelled';
      order.cancelReason = 'Customer opted to cancel due to out-of-stock item ($missingBarcode)';
    } else if (action == 'REPLACE' && replacementBarcode != null) {
      final replacementProd = findProductByBarcode(replacementBarcode);
      if (replacementProd != null) {
        final index = order.items.indexWhere((i) => i.barcode == missingBarcode);
        if (index != -1) {
          final oldItem = order.items[index];
          order.items[index] = OnlineOrderItem(
            productId: replacementProd.id,
            barcode: replacementProd.barcode,
            code: replacementProd.code,
            nameEn: replacementProd.nameEn,
            nameAr: replacementProd.nameAr,
            unitPrice: replacementProd.price,
            quantity: oldItem.quantity,
            isScanned: true,
          );
          order.replacementNotes = 'Replaced ${oldItem.nameEn} with ${replacementProd.nameEn} (Customer Approved). Note: $note';
        }
      }
    }
    notifyListeners();
  }

  void scanOnlineOrderItem(String orderId, String barcode) {
    final order = _onlineOrders.firstWhere((o) => o.orderId == orderId);
    final item = order.items.firstWhere((i) => i.barcode == barcode.trim(), orElse: () => order.items.first);
    item.isScanned = true;
    notifyListeners();
  }

  void dispatchOnlineOrder(String orderId) {
    final order = _onlineOrders.firstWhere((o) => o.orderId == orderId);
    order.status = 'Out for Delivery';
    order.receiptPrinted = true;

    // Record in unified receipts history
    _unifiedReceipts.insert(
      0,
      UnifiedReceiptRecord(
        receiptNo: 'REC-${order.orderId}',
        source: 'Online',
        timestamp: DateTime.now(),
        cashierName: 'Layla Nour',
        terminalId: 'WEB-DISPATCH',
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        customerEmail: order.customerEmail,
        customerAddress: order.customerAddress,
        items: order.items.map((i) {
          return MockCartLine(
            productId: i.productId,
            barcode: i.barcode,
            nameEn: i.nameEn,
            nameAr: i.nameAr,
            quantity: i.quantity,
            unitPrice: i.unitPrice,
          );
        }).toList(),
        subtotal: order.subtotal,
        tax: order.tax,
        total: order.total,
        paymentMethod: 'COD',
      ),
    );

    _logAudit(
      actionType: 'ORDER_DISPATCHED',
      productName: 'Order ${order.orderId}',
      barcode: '',
      quantity: order.totalItemCount,
      performedBy: 'Cashier Dispatcher',
      refNo: 'REC-${order.orderId}',
      notes: 'All items scanned & verified. Receipt printed & dispatched to courier (COD: ${order.total.toStringAsFixed(2)} EGP)',
    );

    notifyListeners();
  }

  // ── Unified Receipts (In-Store Checkout) ──────────────────────
  void recordInStoreReceipt({
    required List<MockCartLine> items,
    required double subtotal,
    required double tax,
    required double total,
    required String paymentMethod,
    double? tendered,
    double? change,
    required String cashierName,
    String terminalId = 'POS-01',
  }) {
    final receiptNo = 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Deduct in-store stock
    for (final line in items) {
      final p = findProductByBarcode(line.barcode);
      if (p != null) {
        p.stock = (p.stock - line.quantity).clamp(0, 999999);
      }
    }

    _unifiedReceipts.insert(
      0,
      UnifiedReceiptRecord(
        receiptNo: receiptNo,
        source: 'In-Store',
        timestamp: DateTime.now(),
        cashierName: cashierName,
        terminalId: terminalId,
        items: List.from(items),
        subtotal: subtotal,
        tax: tax,
        total: total,
        paymentMethod: paymentMethod,
        tenderedAmount: tendered,
        changeAmount: change,
      ),
    );

    // Update cashier stats
    final cashier = _onlineCashiers.firstWhere(
      (c) => c.name.toLowerCase().contains(cashierName.toLowerCase()),
      orElse: () => _onlineCashiers.first,
    );
    cashier.totalSales += total;
    cashier.transactionCount += 1;
    cashier.totalItemsSold += items.fold(0, (acc, i) => acc + i.quantity);
    if (paymentMethod == 'CASH') cashier.cashSales += total;
    if (paymentMethod == 'VISA') cashier.visaSales += total;

    cashier.recentTransactions.insert(0, {
      'receipt': receiptNo,
      'time': 'Just now',
      'total': total,
      'type': paymentMethod,
      'items': items.length,
    });

    notifyListeners();
  }

  // ── Stock Manager Role Operations ─────────────────────────────

  /// Add a brand new product to the warehouse system and catalog.
  void addNewProduct({
    required String barcode,
    required String code,
    required String nameEn,
    required String nameAr,
    required String category,
    required double price,
    required int initialWarehouseStock,
    required int initialStoreStock,
    int minThreshold = 50,
  }) {
    final newId = _products.length + 1;
    final newProd = LiveStoreProduct(
      id: newId,
      barcode: barcode,
      code: code,
      nameEn: nameEn,
      nameAr: nameAr,
      price: price,
      category: category,
      stock: initialStoreStock,
      minThreshold: minThreshold,
      warehouseStock: initialWarehouseStock,
      minWarehouseThreshold: 100,
    );

    _products.add(newProd);

    _logAudit(
      actionType: 'PRODUCT_ADDED',
      productName: nameEn,
      barcode: barcode,
      quantity: initialWarehouseStock,
      performedBy: 'Stock Mgr Hossam El-Din',
      refNo: code,
      notes: 'New product added to catalog with $initialWarehouseStock warehouse units',
    );

    notifyListeners();
  }

  /// Stock Manager approves store low stock reorder request.
  void approveStoreReorder(String requestId, {String? note}) {
    final req = _reorderRequests.firstWhere((r) => r.requestId == requestId);
    req.status = 'Approved';
    req.reviewedBy = 'Stock Mgr Hossam El-Din';
    req.reviewTime = DateTime.now();
    req.decisionNote = note ?? 'Approved for warehouse fulfillment';

    _logAudit(
      actionType: 'REQUEST_APPROVED',
      productName: req.productName,
      barcode: req.productBarcode,
      quantity: req.requiredQuantity,
      performedBy: 'Stock Mgr Hossam El-Din',
      refNo: req.requestId,
      notes: 'Store low stock request approved',
    );

    notifyListeners();
  }

  /// Stock Manager denies store low stock reorder request.
  void denyStoreReorder(String requestId, String reason) {
    final req = _reorderRequests.firstWhere((r) => r.requestId == requestId);
    req.status = 'Denied';
    req.reviewedBy = 'Stock Mgr Hossam El-Din';
    req.reviewTime = DateTime.now();
    req.decisionNote = reason;

    _logAudit(
      actionType: 'REQUEST_DENIED',
      productName: req.productName,
      barcode: req.productBarcode,
      quantity: req.requiredQuantity,
      performedBy: 'Stock Mgr Hossam El-Din',
      refNo: req.requestId,
      notes: 'Store request denied: $reason',
    );

    notifyListeners();
  }

  /// Fulfill store request: Scan barcode, deduct warehouse stock, increment store stock, and generate delivery receipt.
  bool fulfillStoreRequest({
    required String requestId,
    required String barcode,
  }) {
    final req = _reorderRequests.firstWhere((r) => r.requestId == requestId);
    final prod = findProductByBarcode(barcode);

    if (prod == null || prod.barcode != req.productBarcode) return false;

    // Deduct warehouse stock and add to store stock
    prod.warehouseStock = (prod.warehouseStock - req.requiredQuantity).clamp(0, 999999);
    prod.stock += req.requiredQuantity;

    req.status = 'Fulfilled';
    req.isFulfilled = true;
    req.fulfilledTime = DateTime.now();

    _logAudit(
      actionType: 'FULFILLED',
      productName: req.productName,
      barcode: req.productBarcode,
      quantity: req.requiredQuantity,
      performedBy: 'Stock Mgr Hossam El-Din',
      refNo: 'DELIV-${req.requestId}',
      notes: 'Scanned out of warehouse Bay 1. Delivered to store counter (+${req.requiredQuantity} units).',
    );

    notifyListeners();
    return true;
  }

  /// Send warehouse restock request from Stock Manager to Store Manager (when warehouse itself is low).
  void sendWarehouseRestockRequest({
    required String barcode,
    required int requestedQuantity,
    required String supplier,
  }) {
    final prod = findProductByBarcode(barcode);
    if (prod == null) return;

    final req = WarehouseRestockRequest(
      requestId: 'WH-REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      productBarcode: prod.barcode,
      productCode: prod.code,
      productName: prod.nameEn,
      currentWarehouseStock: prod.warehouseStock,
      requestedQuantity: requestedQuantity,
      supplier: supplier,
      requestedBy: 'Stock Mgr Hossam El-Din',
      requestTime: DateTime.now(),
      status: 'Awaiting Store Manager Approval',
    );

    _warehouseRestockRequests.insert(0, req);

    _logAudit(
      actionType: 'WH_RESTOCK_REQUESTED',
      productName: prod.nameEn,
      barcode: prod.barcode,
      quantity: requestedQuantity,
      performedBy: 'Stock Mgr Hossam El-Din',
      refNo: req.requestId,
      notes: 'Warehouse low stock request sent to Manager for approval',
    );

    notifyListeners();
  }

  /// Store Manager explicitly approves warehouse restock request sent by Stock Manager.
  void approveWarehouseRestockRequest(String requestId, {String? note}) {
    final req = _warehouseRestockRequests.firstWhere((r) => r.requestId == requestId);
    req.status = 'Approved';
    req.reviewedBy = 'Manager Tarek Mansour';
    req.reviewTime = DateTime.now();
    req.decisionNote = note ?? 'Approved by Store Manager. Supplier PO released for dispatch.';

    _logAudit(
      actionType: 'WH_RESTOCK_APPROVED',
      productName: req.productName,
      barcode: req.productBarcode,
      quantity: req.requestedQuantity,
      performedBy: 'Manager Tarek Mansour',
      refNo: req.requestId,
      notes: 'Store Manager authorized warehouse restock: ${req.decisionNote}',
    );

    notifyListeners();
  }

  /// Store Manager explicitly denies warehouse restock request sent by Stock Manager.
  void denyWarehouseRestockRequest(String requestId, String reason) {
    final req = _warehouseRestockRequests.firstWhere((r) => r.requestId == requestId);
    req.status = 'Rejected';
    req.reviewedBy = 'Manager Tarek Mansour';
    req.reviewTime = DateTime.now();
    req.decisionNote = reason;

    _logAudit(
      actionType: 'WH_RESTOCK_REJECTED',
      productName: req.productName,
      barcode: req.productBarcode,
      quantity: req.requestedQuantity,
      performedBy: 'Manager Tarek Mansour',
      refNo: req.requestId,
      notes: 'Store Manager rejected warehouse restock: $reason',
    );

    notifyListeners();
  }

  /// Helper to lookup full detailed receipt by receipt number
  UnifiedReceiptRecord? findReceiptByNo(String receiptNo) {
    final no = receiptNo.trim().toUpperCase();
    try {
      return _unifiedReceipts.firstWhere((r) => r.receiptNo.toUpperCase() == no);
    } catch (_) {
      return null;
    }
  }

  /// Get all full itemized receipts for a given cashier or terminal
  List<UnifiedReceiptRecord> getReceiptsForCashier(String cashierName, [String? terminalId]) {
    final nameLower = cashierName.trim().toLowerCase();
    final list = _unifiedReceipts.where((r) {
      final matchesName = r.cashierName.toLowerCase().contains(nameLower);
      final matchesTerminal = terminalId != null && r.terminalId == terminalId;
      return matchesName || matchesTerminal;
    }).toList();

    return list;
  }

  /// Import / Restock existing product in warehouse.
  void importRestockToWarehouse({
    required String barcode,
    required int quantity,
    required String supplier,
    required String poNumber,
    required String batchNumber,
  }) {
    final prod = findProductByBarcode(barcode);
    if (prod == null) return;

    prod.warehouseStock += quantity;

    _logAudit(
      actionType: 'RESTOCK_IMPORTED',
      productName: prod.nameEn,
      barcode: prod.barcode,
      quantity: quantity,
      performedBy: 'Stock Mgr Hossam El-Din',
      refNo: poNumber,
      notes: 'Imported $quantity units from $supplier (Batch: $batchNumber)',
    );

    notifyListeners();
  }

  // ── Existing Manager Actions ──────────────────────────────────
  bool processReturn({
    required String barcode,
    required int quantity,
    required String reason,
    required String cashierName,
    required String receiptNo,
  }) {
    final product = findProductByBarcode(barcode);
    if (product == null) return false;

    final refundTotal = product.price * quantity;
    final returnRecord = ReturnedProductRecord(
      returnId: 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      barcode: product.barcode,
      productCode: product.code,
      productName: product.nameEn,
      quantity: quantity,
      refundAmount: refundTotal,
      originalCashier: cashierName,
      originalReceiptNo: receiptNo,
      reason: reason,
      timestamp: DateTime.now(),
    );

    _returns.insert(0, returnRecord);
    if (reason.contains('Mind') || reason.contains('Wrong Item')) {
      product.stock += quantity;
    }

    _logAudit(
      actionType: 'RETURN_PROCESSED',
      productName: product.nameEn,
      barcode: barcode,
      quantity: quantity,
      performedBy: 'Manager',
      refNo: returnRecord.returnId,
      notes: 'Return processed for ${product.nameEn} ($quantity units)',
    );

    notifyListeners();
    return true;
  }

  bool logDamagedStock({
    required String barcode,
    required int quantity,
    required String reason,
    required String loggedBy,
  }) {
    final product = findProductByBarcode(barcode);
    if (product == null) return false;

    product.stock = (product.stock - quantity).clamp(0, 999999);

    final damageRecord = DamagedGoodRecord(
      damageId: 'DMG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      barcode: product.barcode,
      productCode: product.code,
      productName: product.nameEn,
      quantity: quantity,
      unitPrice: product.price,
      totalLoss: product.price * quantity,
      reason: reason,
      loggedBy: loggedBy,
      timestamp: DateTime.now(),
    );

    _damagedGoods.insert(0, damageRecord);

    _logAudit(
      actionType: 'DAMAGED_DEDUCTED',
      productName: product.nameEn,
      barcode: barcode,
      quantity: quantity,
      performedBy: loggedBy,
      refNo: damageRecord.damageId,
      notes: 'Damaged stock deducted from POS inventory: $reason',
    );

    notifyListeners();
    return true;
  }

  bool receiveWarehouseStock({
    required String poNumber,
    required String supplier,
    required String barcode,
    required int quantity,
    required String batchNumber,
    required DateTime expiryDate,
    required String receivedBy,
  }) {
    final product = findProductByBarcode(barcode);
    if (product == null) return false;

    product.stock += quantity;

    final receivingRecord = StockReceivingRecord(
      receivingId: 'RCV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      poNumber: poNumber,
      supplier: supplier,
      barcode: barcode,
      productCode: product.code,
      productName: product.nameEn,
      quantityReceived: quantity,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      receivedBy: receivedBy,
      timestamp: DateTime.now(),
    );

    _receivingLogs.insert(0, receivingRecord);

    _logAudit(
      actionType: 'STOCK_RECEIVED_STORE',
      productName: product.nameEn,
      barcode: barcode,
      quantity: quantity,
      performedBy: receivedBy,
      refNo: poNumber,
      notes: 'Received shipment from $supplier and made available in POS (+${quantity} units)',
    );

    notifyListeners();
    return true;
  }

  bool sendStockReorderRequest({
    required String barcode,
    required int requiredQuantity,
    required String requestedBy,
  }) {
    final product = findProductByBarcode(barcode);
    if (product == null) return false;

    final req = StockReorderRequest(
      requestId: 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      productBarcode: product.barcode,
      productCode: product.code,
      productName: product.nameEn,
      currentStock: product.stock,
      requiredQuantity: requiredQuantity,
      requestedBy: requestedBy,
      requestTime: DateTime.now(),
      status: 'Pending Approval/Denial',
    );

    _reorderRequests.insert(0, req);
    notifyListeners();
    return true;
  }

  void addEmployee({
    required String name,
    required UserRole role,
    required String phone,
    required String nationalId,
    required String shiftSchedule,
    required String assignedTerminal,
  }) {
    final newId = 'EMP-${1000 + _employees.length + 1}';
    final emp = EmployeeProfile(
      id: newId,
      name: name,
      role: role,
      phone: phone,
      nationalId: nationalId,
      shiftSchedule: shiftSchedule,
      assignedTerminal: assignedTerminal,
      hireDate: DateTime.now(),
    );
    _employees.add(emp);
    notifyListeners();
  }

  void updateEmployee({
    required String id,
    required String name,
    required UserRole role,
    required String phone,
    required String shiftSchedule,
    required String assignedTerminal,
  }) {
    final index = _employees.indexWhere((e) => e.id == id);
    if (index != -1) {
      _employees[index].name = name;
      _employees[index].role = role;
      _employees[index].phone = phone;
      _employees[index].shiftSchedule = shiftSchedule;
      _employees[index].assignedTerminal = assignedTerminal;
      notifyListeners();
    }
  }

  void removeEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  AttendanceLogEntry clockInEmployee({
    required String employeeId,
    required DateTime scheduledTime,
    required DateTime punchInTime,
    required String shiftName,
    String notes = '',
  }) {
    final emp = _employees.firstWhere((e) => e.id == employeeId);
    final diff = punchInTime.difference(scheduledTime).inMinutes;

    String statusText;
    int lateness;
    if (diff <= 5) {
      statusText = 'On-Time';
      lateness = 0;
    } else {
      statusText = 'Late (+$diff mins)';
      lateness = diff;
    }

    final entry = AttendanceLogEntry(
      entryId: 'ATT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      employeeId: emp.id,
      employeeName: emp.name,
      role: emp.role,
      shiftName: shiftName,
      scheduledStartTime: scheduledTime,
      actualPunchInTime: punchInTime,
      latenessMinutes: lateness,
      status: statusText,
      notes: notes,
    );

    _attendanceLogs.insert(0, entry);
    notifyListeners();
    return entry;
  }

  void _logAudit({
    required String actionType,
    required String productName,
    required String barcode,
    required int quantity,
    required String performedBy,
    required String refNo,
    String notes = '',
  }) {
    _auditLogs.insert(
      0,
      AuditLogEntry(
        logId: 'AUD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        actionType: actionType,
        productName: productName,
        barcode: barcode,
        quantity: quantity,
        performedBy: performedBy,
        timestamp: DateTime.now(),
        referenceNo: refNo,
        notes: notes,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // ── OWNER / EXECUTIVE DASHBOARD STATE & FINANCIAL METHODS ───────
  // ═════════════════════════════════════════════════════════════════

  double _baseCapital = 500000.0;
  double get baseCapital => _baseCapital;

  void setBaseCapital(double amount) {
    _baseCapital = amount;
    _logAudit(
      actionType: 'CAPITAL_OVERRIDE',
      productName: 'Base Capital Float',
      barcode: 'SYSTEM-CAPITAL',
      quantity: amount.toInt(),
      performedBy: 'Owner / Executive',
      refNo: 'EXEC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      notes: 'Base capital set to ${amount.toStringAsFixed(2)} EGP',
    );
    notifyListeners();
  }

  // ── Financial Calculation Getters ──────────────────────────────
  int get totalStoreStockUnits => _products.fold(0, (acc, p) => acc + p.stock);
  int get totalWarehouseStockUnits => _products.fold(0, (acc, p) => acc + p.warehouseStock);
  int get totalCombinedStockUnits => totalStoreStockUnits + totalWarehouseStockUnits;

  double get totalStoreInventoryValue =>
      _products.fold(0.0, (acc, p) => acc + (p.stock * p.price));
  double get totalWarehouseInventoryValue =>
      _products.fold(0.0, (acc, p) => acc + (p.warehouseStock * p.price));
  double get totalCombinedInventoryValue =>
      totalStoreInventoryValue + totalWarehouseInventoryValue;
  double get totalCostOfAvailableGoods => totalCombinedInventoryValue * 0.72;

  double get totalSalesRevenue =>
      _unifiedReceipts.fold(0.0, (acc, r) => acc + r.total);
  double get inStoreRevenue => _unifiedReceipts
      .where((r) => r.source != 'Online')
      .fold(0.0, (acc, r) => acc + r.total);
  double get onlineCodRevenue => _unifiedReceipts
      .where((r) => r.source == 'Online')
      .fold(0.0, (acc, r) => acc + r.total);

  double get totalCashInDrawer => _unifiedReceipts
      .where((r) => r.paymentMethod == 'CASH' || r.paymentMethod == 'COD')
      .fold(0.0, (acc, r) => acc + r.total);

  double get estimatedGrossProfit => totalSalesRevenue * 0.28;
  double get estimatedProfitMarginPct =>
      totalSalesRevenue > 0 ? (estimatedGrossProfit / totalSalesRevenue) * 100 : 28.0;

  double get totalRefundAmount =>
      _returns.fold(0.0, (acc, r) => acc + r.refundAmount);
  double get totalDamagedGoodsLoss =>
      _damagedGoods.fold(0.0, (acc, d) => acc + d.totalLoss);
  double get totalLossesAndDamages =>
      totalRefundAmount + totalDamagedGoodsLoss;

  // ── Bulk Stock Overrides (Handover / Reset) ────────────────────
  void bulkUpdateStoreStock({int? fixedValue, double? multiplier, int? addAmount, String? category}) {
    for (final p in _products) {
      if (category != null && category != 'ALL' && p.category != category) continue;
      if (fixedValue != null) {
        p.stock = fixedValue.clamp(0, 99999);
      } else if (multiplier != null) {
        p.stock = (p.stock * multiplier).round().clamp(0, 99999);
      } else if (addAmount != null) {
        p.stock = (p.stock + addAmount).clamp(0, 99999);
      }
    }
    _logAudit(
      actionType: 'BULK_STORE_OVERRIDE',
      productName: 'Store Shelf Inventory',
      barcode: 'SYSTEM-STORE-BULK',
      quantity: fixedValue ?? addAmount ?? 0,
      performedBy: 'Owner / Executive',
      refNo: 'EXEC-ST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      notes: 'Bulk updated store inventory levels (category: ${category ?? "ALL"})',
    );
    notifyListeners();
  }

  void bulkUpdateWarehouseStock({int? fixedValue, double? multiplier, int? addAmount, String? category}) {
    for (final p in _products) {
      if (category != null && category != 'ALL' && p.category != category) continue;
      if (fixedValue != null) {
        p.warehouseStock = fixedValue.clamp(0, 99999);
      } else if (multiplier != null) {
        p.warehouseStock = (p.warehouseStock * multiplier).round().clamp(0, 99999);
      } else if (addAmount != null) {
        p.warehouseStock = (p.warehouseStock + addAmount).clamp(0, 99999);
      }
    }
    _logAudit(
      actionType: 'BULK_WH_OVERRIDE',
      productName: 'Warehouse Reserve Inventory',
      barcode: 'SYSTEM-WH-BULK',
      quantity: fixedValue ?? addAmount ?? 0,
      performedBy: 'Owner / Executive',
      refNo: 'EXEC-WH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      notes: 'Bulk updated warehouse inventory levels (category: ${category ?? "ALL"})',
    );
    notifyListeners();
  }

  void updateProductStoreStock(String barcode, int newStock) {
    final p = findProductByBarcode(barcode);
    if (p != null) {
      p.stock = newStock.clamp(0, 99999);
      _logAudit(
        actionType: 'STORE_STOCK_OVERRIDE',
        productName: p.nameEn,
        barcode: barcode,
        quantity: newStock,
        performedBy: 'Owner / Executive',
        refNo: 'EXEC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        notes: 'Direct store stock override to $newStock units',
      );
      notifyListeners();
    }
  }

  void updateProductWarehouseStock(String barcode, int newWarehouseStock) {
    final p = findProductByBarcode(barcode);
    if (p != null) {
      p.warehouseStock = newWarehouseStock.clamp(0, 99999);
      _logAudit(
        actionType: 'WH_STOCK_OVERRIDE',
        productName: p.nameEn,
        barcode: barcode,
        quantity: newWarehouseStock,
        performedBy: 'Owner / Executive',
        refNo: 'EXEC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        notes: 'Direct warehouse stock override to $newWarehouseStock units',
      );
      notifyListeners();
    }
  }

  // ── Manager Management ─────────────────────────────────────────
  List<EmployeeProfile> get managers =>
      _employees.where((e) => e.role == UserRole.manager).toList();

  void addManager({
    required String name,
    required String phone,
    required String nationalId,
    required String shiftSchedule,
    required String assignedTerminal,
  }) {
    final newId = 'MGR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final manager = EmployeeProfile(
      id: newId,
      name: name,
      role: UserRole.manager,
      phone: phone,
      nationalId: nationalId,
      shiftSchedule: shiftSchedule,
      assignedTerminal: assignedTerminal,
      hireDate: DateTime.now(),
    );
    _employees.add(manager);
    _logAudit(
      actionType: 'MANAGER_ADDED',
      productName: 'Staff Administration',
      barcode: newId,
      quantity: 1,
      performedBy: 'Owner / Executive',
      refNo: 'MGR-REG',
      notes: 'New Store Manager appointed: $name ($assignedTerminal)',
    );
    notifyListeners();
  }

  void updateManager(
    String id, {
    String? name,
    String? phone,
    String? shiftSchedule,
    String? assignedTerminal,
    bool? isActive,
  }) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final m = _employees[idx];
      if (name != null) m.name = name;
      if (phone != null) m.phone = phone;
      if (shiftSchedule != null) m.shiftSchedule = shiftSchedule;
      if (assignedTerminal != null) m.assignedTerminal = assignedTerminal;
      if (isActive != null) m.isActive = isActive;
      notifyListeners();
    }
  }

  void removeManager(String id) {
    final emp = _employees.firstWhere((e) => e.id == id, orElse: () => _employees.first);
    _employees.removeWhere((e) => e.id == id);
    _logAudit(
      actionType: 'MANAGER_REMOVED',
      productName: 'Staff Administration',
      barcode: id,
      quantity: 1,
      performedBy: 'Owner / Executive',
      refNo: 'MGR-DEL',
      notes: 'Store Manager relieved of duties: ${emp.name}',
    );
    notifyListeners();
  }
}
