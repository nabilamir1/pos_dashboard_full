/// Mock data layer for the Cashier System UI.
/// Provides static product lists, cart items, and receipt data
/// so that the UI is fully functional without any backend or database.

class MockProduct {
  final int id;
  final String barcode;
  final String code;
  final String nameEn;
  final String nameAr;
  final double price;
  final String category;
  final int stock;

  const MockProduct({
    required this.id,
    required this.barcode,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.category,
    required this.stock,
  });
}

class MockCartLine {
  final int productId;
  final String barcode;
  final String nameEn;
  final String nameAr;
  int quantity;
  final double unitPrice;

  MockCartLine({
    required this.productId,
    required this.barcode,
    required this.nameEn,
    required this.nameAr,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => quantity * unitPrice;

  MockCartLine copy() => MockCartLine(
        productId: productId,
        barcode: barcode,
        nameEn: nameEn,
        nameAr: nameAr,
        quantity: quantity,
        unitPrice: unitPrice,
      );
}

/// Mock receipt model representing a completed transaction.
class MockReceipt {
  final String receiptNo;
  final DateTime timestamp;
  final List<MockCartLine> items;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod; // 'CASH' or 'VISA'
  final double? tenderedAmount;
  final double? changeAmount;
  final String cashierName;
  final String terminalId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  MockReceipt({
    required this.receiptNo,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.tenderedAmount,
    this.changeAmount,
    required this.cashierName,
    this.terminalId = 'POS-01',
    this.customerName = 'Mohamed El-Sayed',
    this.customerPhone = '+20 100 234 5678',
    this.customerAddress = '15 Tahrir St, Cairo',
  });

  int get totalItemCount => items.fold(0, (acc, item) => acc + item.quantity);
}

/// Static catalog of 20 mock products spanning several grocery categories.
class MockData {
  MockData._();

  static const List<MockProduct> products = [
    MockProduct(id: 1,  barcode: '6221033001012', code: 'BEV-001', nameEn: 'Coca-Cola 330ml',          nameAr: 'كوكاكولا ٣٣٠ مل',         price: 12.00,  category: 'Beverages',    stock: 240),
    MockProduct(id: 2,  barcode: '6221033001029', code: 'BEV-002', nameEn: 'Pepsi 500ml',              nameAr: 'بيبسي ٥٠٠ مل',             price: 15.00,  category: 'Beverages',    stock: 180),
    MockProduct(id: 3,  barcode: '6221033001036', code: 'BEV-003', nameEn: 'Dasani Water 1.5L',        nameAr: 'مياه دسانى ١.٥ لتر',       price: 8.50,   category: 'Beverages',    stock: 500),
    MockProduct(id: 4,  barcode: '6223000103012', code: 'DAI-001', nameEn: 'Juhayna Full Cream Milk 1L', nameAr: 'لبن جهينة كامل ١ لتر',    price: 38.00,  category: 'Dairy',        stock: 120),
    MockProduct(id: 5,  barcode: '6223000103029', code: 'DAI-002', nameEn: 'Domty White Cheese 500g',  nameAr: 'جبنة دومتى بيضاء ٥٠٠ جم', price: 55.00,  category: 'Dairy',        stock: 90),
    MockProduct(id: 6,  barcode: '6223000206017', code: 'BAK-001', nameEn: 'Bisco Misr Biscuits 12pk', nameAr: 'بسكويت بسكو مصر ١٢ قطعة',  price: 42.00,  category: 'Bakery',       stock: 200),
    MockProduct(id: 7,  barcode: '6223000206024', code: 'BAK-002', nameEn: 'Molto Croissant Choco',    nameAr: 'كرواسون مولتو شوكولاتة',    price: 10.00,  category: 'Bakery',       stock: 320),
    MockProduct(id: 8,  barcode: '6224007400015', code: 'SNK-001', nameEn: 'Chipsy Cheese 65g',        nameAr: 'شيبسى بالجبنة ٦٥ جم',      price: 18.00,  category: 'Snacks',       stock: 400),
    MockProduct(id: 9,  barcode: '6224007400022', code: 'SNK-002', nameEn: 'Tiger Peanut Bar',         nameAr: 'تايجر فول سوداني',          price: 7.50,   category: 'Snacks',       stock: 350),
    MockProduct(id: 10, barcode: '6224011001012', code: 'CLE-001', nameEn: 'Persil Powder 2.5kg',      nameAr: 'برسيل بودرة ٢.٥ كيلو',     price: 125.00, category: 'Cleaning',     stock: 70),
    MockProduct(id: 11, barcode: '6224011001029', code: 'CLE-002', nameEn: 'Clorox Bleach 1L',         nameAr: 'كلوروكس ١ لتر',             price: 32.00,  category: 'Cleaning',     stock: 95),
    MockProduct(id: 12, barcode: '6225000301012', code: 'FRZ-001', nameEn: 'Koki Frozen Peas 400g',    nameAr: 'بسلة كوكى مجمدة ٤٠٠ جم',   price: 48.00,  category: 'Frozen',       stock: 150),
    MockProduct(id: 13, barcode: '6225000301029', code: 'FRZ-002', nameEn: 'Farm Frites 1kg',          nameAr: 'فارم فريتس ١ كيلو',         price: 65.00,  category: 'Frozen',       stock: 110),
    MockProduct(id: 14, barcode: '6226000401015', code: 'FRT-001', nameEn: 'Fresh Bananas 1kg',        nameAr: 'موز طازج ١ كيلو',           price: 35.00,  category: 'Fruits',       stock: 80),
    MockProduct(id: 15, barcode: '6226000401022', code: 'FRT-002', nameEn: 'Red Apple 1kg',            nameAr: 'تفاح أحمر ١ كيلو',          price: 65.00,  category: 'Fruits',       stock: 60),
    MockProduct(id: 16, barcode: '6227000501018', code: 'MEA-001', nameEn: 'Fresh Chicken 1kg',        nameAr: 'فراخ طازجة ١ كيلو',         price: 120.00, category: 'Meat',         stock: 45),
    MockProduct(id: 17, barcode: '6227000501025', code: 'MEA-002', nameEn: 'Beef Kofta 500g',          nameAr: 'كفتة لحم ٥٠٠ جم',           price: 145.00, category: 'Meat',         stock: 35),
    MockProduct(id: 18, barcode: '6228000601011', code: 'PER-001', nameEn: 'Sensodyne Toothpaste',     nameAr: 'سنسوداين معجون أسنان',       price: 85.00,  category: 'Personal Care', stock: 100),
    MockProduct(id: 19, barcode: '6228000601028', code: 'PER-002', nameEn: 'Head & Shoulders 400ml',   nameAr: 'هيد آند شولدرز ٤٠٠ مل',    price: 110.00, category: 'Personal Care', stock: 75),
    MockProduct(id: 20, barcode: '6229000701014', code: 'GRO-001', nameEn: 'Basmatic Rice 5kg',        nameAr: 'أرز بسمتى ٥ كيلو',          price: 160.00, category: 'Grocery',      stock: 55),
    MockProduct(id: 21, barcode: '1234567890123', code: '123-ORG', nameEn: 'Organic Orange Juice 1L',  nameAr: 'عصير برتقال عضوي ١ لتر',   price: 28.00,  category: 'Beverages',    stock: 85),
    MockProduct(id: 22, barcode: '1239876543210', code: '123-SNK', nameEn: 'Mixed Salted Nuts 250g',   nameAr: 'مكسرات مشكلة ٢٥٠ جم',       price: 75.00,  category: 'Snacks',       stock: 120),
    MockProduct(id: 23, barcode: '1235554443332', code: '123-CHK', nameEn: 'Dark Chocolate Bar 100g',  nameAr: 'شوكولاتة داكنة ١٠٠ جم',     price: 35.00,  category: 'Snacks',       stock: 160),
  ];

  /// Find a product by barcode string.
  static MockProduct? findByBarcode(String barcode) {
    final bc = barcode.trim();
    try {
      return products.firstWhere((p) => p.barcode == bc);
    } catch (_) {
      return null;
    }
  }

  /// Find a product by code string.
  static MockProduct? findByCode(String code) {
    final c = code.trim().toUpperCase();
    try {
      return products.firstWhere((p) => p.code.toUpperCase() == c);
    } catch (_) {
      return null;
    }
  }

  /// Search products by name or code.
  static List<MockProduct> search(String query) {
    if (query.isEmpty) return products;
    final q = query.toLowerCase();
    return products.where((p) {
      return p.nameEn.toLowerCase().contains(q) ||
          p.nameAr.contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.barcode.contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }

  /// All unique category names.
  static List<String> get categories {
    return products.map((p) => p.category).toSet().toList()..sort();
  }

  /// Initial sample receipts for demonstration and testing.
  static List<MockReceipt> initialReceipts({String cashierName = 'Ahmed Hassan'}) {
    final now = DateTime.now();
    return [
      MockReceipt(
        receiptNo: 'REC-904121',
        timestamp: now.subtract(const Duration(minutes: 25)),
        items: [
          MockCartLine(
            productId: 1,
            barcode: '6221033001012',
            nameEn: 'Coca-Cola 330ml',
            nameAr: 'كوكاكولا ٣٣٠ مل',
            quantity: 2,
            unitPrice: 12.00,
          ),
          MockCartLine(
            productId: 8,
            barcode: '6224007400015',
            nameEn: 'Chipsy Cheese 65g',
            nameAr: 'شيبسى بالجبنة ٦٥ جم',
            quantity: 1,
            unitPrice: 18.00,
          ),
        ],
        subtotal: 42.00,
        tax: 5.88,
        total: 47.88,
        paymentMethod: 'CASH',
        tenderedAmount: 50.00,
        changeAmount: 2.12,
        cashierName: cashierName,
      ),
      MockReceipt(
        receiptNo: 'REC-892104',
        timestamp: now.subtract(const Duration(minutes: 58)),
        items: [
          MockCartLine(
            productId: 20,
            barcode: '6229000701014',
            nameEn: 'Basmatic Rice 5kg',
            nameAr: 'أرز بسمتى ٥ كيلو',
            quantity: 1,
            unitPrice: 160.00,
          ),
          MockCartLine(
            productId: 4,
            barcode: '6223000103012',
            nameEn: 'Juhayna Full Cream Milk 1L',
            nameAr: 'لبن جهينة كامل ١ لتر',
            quantity: 2,
            unitPrice: 38.00,
          ),
        ],
        subtotal: 236.00,
        tax: 33.04,
        total: 269.04,
        paymentMethod: 'VISA',
        cashierName: cashierName,
      ),
    ];
  }
}

