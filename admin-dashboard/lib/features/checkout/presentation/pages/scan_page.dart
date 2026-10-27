import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mock_data.dart';
import '../widgets/product_catalog_dialog.dart';
import '../widgets/receipt_dialog.dart';
import '../widgets/qr_scan_dialog.dart';
import '../widgets/cash_payment_dialog.dart';
import '../widgets/previous_receipts_drawer.dart';

/// Main POS Cashier page.
///
/// Features:
/// 1. Cash Receipt Option: Receipt generation and display UI available for Cash payment flow.
/// 2. Shopping Cart UI: Dedicated Cart section displaying selected products, quantities,
///    individual unit prices, line totals, and running total before checkout.
/// 3. Previous Receipts History: Saved in mock state, accessible via side drawer, with
///    instant cart clearing on checkout completion for a new order.
/// 4. Visa Payment Shortcut: Distinct Visa Payment button bound to F2 shortcut.
/// 5. Product Search Feedback: UI feedback (SnackBar and inline text) showing "Product added successfully"
///    or "Product not found".
/// 6. Search Autocomplete: Dropdown suggestions appearing as the user types (e.g. "123").
class PosScanPage extends StatefulWidget {
  final String cashierName;
  final String shiftId;
  final VoidCallback? onLogout;

  const PosScanPage({
    Key? key,
    required this.cashierName,
    required this.shiftId,
    this.onLogout,
  }) : super(key: key);

  @override
  State<PosScanPage> createState() => _PosScanPageState();
}

class _PosScanPageState extends State<PosScanPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _barcodeCtrl = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();
  final List<MockCartLine> _lines = [];

  // Mock previous receipts history
  late final List<MockReceipt> _previousReceipts;

  // Catalog quick selection state
  String _selectedCategory = 'ALL';
  final TextEditingController _catalogSearchCtrl = TextEditingController();
  String _catalogQuery = '';

  // Autocomplete suggestions state
  List<MockProduct> _suggestions = [];
  bool _showSuggestions = false;

  // Search feedback state
  String? _feedbackText;
  bool? _feedbackSuccess;
  Timer? _feedbackTimer;

  String _statusMessage = 'System Ready · Waiting for barcode scan or item selection';
  bool _isOnline = true; // mock online state

  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _previousReceipts = MockData.initialReceipts(cashierName: widget.cashierName);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    HardwareKeyboard.instance.addHandler(_handleHardwareKey);

    _barcodeFocus.addListener(() {
      if (!_barcodeFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_barcodeFocus.hasFocus) {
            setState(() => _showSuggestions = false);
          }
        });
      } else if (_suggestions.isNotEmpty) {
        setState(() => _showSuggestions = true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barcodeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _feedbackTimer?.cancel();
    _glowController.dispose();
    _barcodeCtrl.dispose();
    _barcodeFocus.dispose();
    _catalogSearchCtrl.dispose();
    super.dispose();
  }

  // ── Cart calculations ─────────────────────────────────────────
  double get subtotal =>
      _lines.fold(0.0, (acc, line) => acc + line.lineTotal);
  double get tax => subtotal * 0.14; // 14% Egyptian VAT
  double get total => subtotal + tax;
  int get itemCount =>
      _lines.fold(0, (acc, line) => acc + line.quantity);

  // ── Autocomplete search handling ──────────────────────────────
  void _onBarcodeChanged(String val) {
    final query = val.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Match products whose codes or barcodes start with query (e.g. "123")
    final startsWithMatches = MockData.products.where((p) {
      final code = p.code.toLowerCase();
      final barcode = p.barcode.toLowerCase();
      final codeSuffix = code.contains('-') ? code.split('-').last : '';
      return code.startsWith(query) ||
          barcode.startsWith(query) ||
          codeSuffix.startsWith(query);
    }).toList();

    List<MockProduct> matched = startsWithMatches;
    if (matched.isEmpty) {
      // Fallback: contains match in code, barcode, or name
      matched = MockData.products.where((p) {
        final code = p.code.toLowerCase();
        final barcode = p.barcode.toLowerCase();
        final name = p.nameEn.toLowerCase();
        return code.contains(query) ||
            barcode.contains(query) ||
            name.contains(query);
      }).toList();
    }

    setState(() {
      _suggestions = matched.take(6).toList();
      _showSuggestions = _suggestions.isNotEmpty;
    });
  }

  void _selectProductSuggestion(MockProduct product) {
    _barcodeCtrl.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    _addProductToCart(product);
    _showFeedback(success: true, message: 'Product added successfully');
    _barcodeFocus.requestFocus();
  }

  // ── Mock barcode handling & feedback ──────────────────────────
  void _handleBarcodeSubmit(String rawBarcode) {
    final barcode = rawBarcode.trim();
    if (barcode.isEmpty) return;
    _barcodeCtrl.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    _barcodeFocus.requestFocus();

    // Check existing in cart
    final existingIdx = _lines.indexWhere((l) =>
        l.barcode == barcode ||
        l.nameEn.toLowerCase() == barcode.toLowerCase());
    if (existingIdx >= 0) {
      setState(() {
        _lines[existingIdx].quantity++;
        _statusMessage =
            'Incremented: ${_lines[existingIdx].nameEn} (Qty: ${_lines[existingIdx].quantity})';
      });
      _showFeedback(success: true, message: 'Product added successfully');
      print('[SCAN] Incremented: ${_lines[existingIdx].nameEn}');
      return;
    }

    // Lookup from mock data
    final product = MockData.findByBarcode(barcode) ??
        MockData.findByCode(barcode);

    if (product != null) {
      _addProductToCart(product);
      _showFeedback(success: true, message: 'Product added successfully');
    } else {
      // Check if a single suggestion matched
      final startsWith = MockData.products.where((p) {
        final code = p.code.toLowerCase();
        final bCode = p.barcode.toLowerCase();
        final q = barcode.toLowerCase();
        return code.startsWith(q) || bCode.startsWith(q);
      }).toList();

      if (startsWith.length == 1) {
        _addProductToCart(startsWith.first);
        _showFeedback(success: true, message: 'Product added successfully');
      } else {
        setState(() {
          _statusMessage = 'Product not found: $barcode';
        });
        _showFeedback(success: false, message: 'Product not found');
        print('[SCAN] Not found: $barcode');
      }
    }
  }

  void _showFeedback({required bool success, required String message}) {
    // 1. Floating SnackBar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: success ? AppColors.emerald : AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: success
                ? AppColors.emerald.withOpacity(0.4)
                : AppColors.error.withOpacity(0.4),
          ),
        ),
        duration: const Duration(milliseconds: 2500),
      ),
    );

    // 2. Inline feedback banner below search input
    _feedbackTimer?.cancel();
    setState(() {
      _feedbackText = message;
      _feedbackSuccess = success;
    });
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _feedbackText = null;
          _feedbackSuccess = null;
        });
      }
    });
  }

  void _addProductToCart(MockProduct product) {
    // Check if already in cart
    final existingIdx =
        _lines.indexWhere((l) => l.productId == product.id);
    if (existingIdx >= 0) {
      setState(() {
        _lines[existingIdx].quantity++;
        _statusMessage =
            'Incremented: ${product.nameEn} (Qty: ${_lines[existingIdx].quantity})';
      });
    } else {
      setState(() {
        _lines.add(MockCartLine(
          productId: product.id,
          barcode: product.barcode,
          nameEn: product.nameEn,
          nameAr: product.nameAr,
          quantity: 1,
          unitPrice: product.price,
        ));
        _statusMessage =
            'Added to Cart: ${product.nameEn} · ${product.price.toStringAsFixed(2)} EGP';
      });
    }
    print('[CART] Added ${product.nameEn} (${product.code})');
  }

  // ── Payment processing (mock) ─────────────────────────────────
  void _processPayment(String method) {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.amber, size: 18),
              SizedBox(width: 10),
              Text('Shopping Cart is empty. Scan or select items first.'),
            ],
          ),
          backgroundColor: AppColors.surface,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (method == 'CASH') {
      // Open cash payment dialog
      showDialog(
        context: context,
        builder: (_) => CashPaymentDialog(
          totalAmount: total,
          onConfirm: (tendered, change) {
            print(
                '[PAYMENT] Cash Confirmed — Total: ${total.toStringAsFixed(2)} · Tendered: $tendered · Change: $change');
            _completeTransaction(
              method: 'CASH',
              tendered: tendered,
              change: change,
            );
          },
        ),
      );
    } else {
      // VISA — directly process transaction & show receipt
      print('[PAYMENT] Visa Confirmed — Total: ${total.toStringAsFixed(2)} EGP');
      _completeTransaction(
        method: 'VISA',
      );
    }
  }

  /// Finalize transaction: saves receipt to mock state, clears cart instantly,
  /// and displays the receipt dialog.
  void _completeTransaction({
    required String method,
    double? tendered,
    double? change,
  }) {
    final receiptNo =
        'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final timestamp = DateTime.now();

    // Deep copy current cart items for the receipt record
    final receiptLines = _lines.map((l) => l.copy()).toList();
    final receiptSubtotal = subtotal;
    final receiptTax = tax;
    final receiptTotal = total;

    final receipt = MockReceipt(
      receiptNo: receiptNo,
      timestamp: timestamp,
      items: receiptLines,
      subtotal: receiptSubtotal,
      tax: receiptTax,
      total: receiptTotal,
      paymentMethod: method,
      tenderedAmount: tendered,
      changeAmount: change,
      cashierName: widget.cashierName,
      terminalId: 'POS-01',
    );

    // 1. Save to mock state
    // 2. Clear main cart INSTANTLY for new order
    setState(() {
      _previousReceipts.insert(0, receipt);
      _lines.clear();
      _statusMessage =
          'Order completed ($receiptNo) · Saved to history · Cart ready for next customer';
    });

    print(
        '[CHECKOUT] $method transaction completed ($receiptNo) · Total: ${receiptTotal.toStringAsFixed(2)} EGP · Main cart cleared');

    // 3. Display receipt dialog (both for Cash and Visa)
    showDialog(
      context: context,
      builder: (_) => ReceiptDialog(
        cartLines: receipt.items,
        subtotal: receipt.subtotal,
        tax: receipt.tax,
        total: receipt.total,
        paymentMethod: receipt.paymentMethod,
        cashierName: receipt.cashierName,
        terminalId: receipt.terminalId,
        tenderedAmount: receipt.tenderedAmount,
        changeAmount: receipt.changeAmount,
        customReceiptNo: receipt.receiptNo,
        customDate: receipt.timestamp,
      ),
    ).then((_) {
      _barcodeFocus.requestFocus();
    });
  }

  // ── Drawer & Dialog openers ───────────────────────────────────
  void _openReceiptsDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openCatalogDialog() {
    showDialog(
      context: context,
      builder: (_) => ProductCatalogDialog(
        onProductSelected: (p) {
          _addProductToCart(p);
          _showFeedback(success: true, message: 'Product added successfully');
        },
      ),
    );
  }

  void _openQrScanDialog() {
    showDialog(
      context: context,
      builder: (_) => QrScanDialog(
        onProductScanned: (p) {
          _addProductToCart(p);
          _showFeedback(success: true, message: 'Product added successfully');
        },
      ),
    );
  }

  void _reorderReceiptItems(MockReceipt receipt) {
    setState(() {
      for (final item in receipt.items) {
        final existingIdx =
            _lines.indexWhere((l) => l.productId == item.productId);
        if (existingIdx >= 0) {
          _lines[existingIdx].quantity += item.quantity;
        } else {
          _lines.add(item.copy());
        }
      }
      _statusMessage =
          'Re-ordered ${receipt.items.length} items from ${receipt.receiptNo}';
    });
  }

  // ── Keyboard shortcuts ────────────────────────────────────────
  bool _handleHardwareKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        // F1: Cash payment flow
        _processPayment('CASH');
        print('[SHORTCUT] F1 → Triggered Cash payment');
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.f2) {
        // F2: Distinct Visa payment flow
        _processPayment('VISA');
        print('[SHORTCUT] F2 → Triggered Visa payment');
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.f3) {
        // F3: Previous receipts drawer
        _openReceiptsDrawer();
        print('[SHORTCUT] F3 → Previous Receipts Drawer');
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.f10) {
        _openCatalogDialog();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (_showSuggestions) {
          setState(() => _showSuggestions = false);
          return true;
        }
        if (_lines.isNotEmpty) {
          setState(() {
            _lines.clear();
            _statusMessage = 'Cart cleared / voided';
          });
          print('[SHORTCUT] ESC → Cart voided');
        }
        return true;
      }
    }
    return false;
  }

  // ═════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showSuggestions) {
          setState(() => _showSuggestions = false);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        endDrawer: PreviousReceiptsDrawer(
          receipts: _previousReceipts,
          onReorder: _reorderReceiptItems,
        ),
        body: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Row(
                children: [
                  // ── Left: Fast Scan & Catalog Grid ────────────
                  Expanded(child: _buildCatalogAndScanArea()),

                  // ── Right: Dedicated Shopping Cart Section ───
                  _buildShoppingCartSection(),
                ],
              ),
            ),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TOP BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Terminal badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppGradients.emerald,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.point_of_sale_rounded,
                    size: 16, color: AppColors.textOnAccent),
                SizedBox(width: 6),
                Text('POS 01',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.textOnAccent,
                      letterSpacing: 1,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Cashier info
          const Icon(Icons.person_rounded,
              size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            widget.cashierName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.shiftId,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Action buttons: Catalog, QR Scan
          _topBarButton(
            icon: Icons.inventory_2_rounded,
            label: 'Catalog',
            shortcut: 'F10',
            color: AppColors.cyan,
            onTap: _openCatalogDialog,
          ),
          const SizedBox(width: 8),
          _topBarButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'QR Scan',
            shortcut: '',
            color: AppColors.violet,
            onTap: _openQrScanDialog,
          ),

          const SizedBox(width: 12),

          // Previous Receipts Button with live counter badge
          _previousReceiptsButton(),

          const Spacer(),

          // Online status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnline
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.amber.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOnline ? AppColors.success : AppColors.amber,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isOnline ? AppColors.success : AppColors.amber,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onLogout != null) ...[
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout_rounded, size: 14),
              label: const Text('SWITCH ROLE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rose,
                side: BorderSide(color: AppColors.rose.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _previousReceiptsButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _openReceiptsDrawer,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.12),
            border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_rounded, size: 16, color: AppColors.cyan),
              const SizedBox(width: 6),
              const Text(
                'Previous Receipts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_previousReceipts.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOnAccent,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'F3',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBarButton({
    required IconData icon,
    required String label,
    required String shortcut,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (shortcut.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shortcut,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LEFT: Fast Scanning & Product Catalog Quick-Add
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCatalogAndScanArea() {
    final categories = ['ALL', ...MockData.categories];

    // Filter products by category & search query
    final filteredProducts = MockData.products.where((p) {
      if (_selectedCategory != 'ALL' && p.category != _selectedCategory) {
        return false;
      }
      if (_catalogQuery.isNotEmpty) {
        final q = _catalogQuery.toLowerCase();
        final match = p.nameEn.toLowerCase().contains(q) ||
            p.nameAr.contains(q) ||
            p.code.toLowerCase().contains(q) ||
            p.barcode.contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Barcode Input & Autocomplete Dropdown ──────────────
          _buildBarcodeInput(),

          const SizedBox(height: 16),

          // ── Category Filters & Search ─────────────────────────
          Row(
            children: [
              // Search in catalog
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _catalogSearchCtrl,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Filter catalog by name or code...',
                      hintStyle: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 16, color: AppColors.textMuted),
                      suffixIcon: _catalogQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 14),
                              onPressed: () {
                                _catalogSearchCtrl.clear();
                                setState(() => _catalogQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) =>
                        setState(() => _catalogQuery = val.trim()),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Categories scrollable pills
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, idx) {
                      final cat = categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return InkWell(
                        onTap: () => setState(() => _selectedCategory = cat),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.emerald.withOpacity(0.18)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.emerald
                                  : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.emerald
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Quick Tap Product Grid ────────────────────────────
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 40,
                            color: AppColors.textMuted.withOpacity(0.3)),
                        const SizedBox(height: 10),
                        const Text(
                          'No matching products found',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 1.15,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, idx) {
                      return _buildProductCard(filteredProducts[idx]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(MockProduct product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _addProductToCart(product);
          _showFeedback(success: true, message: 'Product added successfully');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top tag: Category & stock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                  Text(
                    '${product.stock} in stock',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Product names
              Text(
                product.nameEn,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.nameAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 8),

              // Price & Add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${product.price.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.emerald,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppGradients.emerald,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarcodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showSuggestions && _suggestions.isNotEmpty
                            ? AppColors.emerald
                            : AppColors.emerald.withOpacity(0.3),
                        width: _showSuggestions && _suggestions.isNotEmpty ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _barcodeCtrl,
                      focusNode: _barcodeFocus,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search product code (e.g. 123, BEV-001)...',
                        hintStyle:
                            const TextStyle(color: AppColors.textMuted, fontSize: 14),
                        prefixIcon: const Icon(Icons.qr_code_scanner_rounded,
                            color: AppColors.emerald),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_barcodeCtrl.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    size: 16, color: AppColors.textMuted),
                                onPressed: () {
                                  _barcodeCtrl.clear();
                                  _onBarcodeChanged('');
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.search_rounded,
                                  color: AppColors.textMuted),
                              onPressed: () =>
                                  _handleBarcodeSubmit(_barcodeCtrl.text),
                              tooltip: 'Search Code',
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Enter ↵',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _onBarcodeChanged,
                      onSubmitted: _handleBarcodeSubmit,
                    ),
                  ),

                  // Autocomplete dropdown floating directly below the input
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Positioned(
                      top: 56,
                      left: 0,
                      right: 0,
                      child: _buildSuggestionsDropdown(),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // QR Scan button
            _actionButton(
              icon: Icons.qr_code_scanner_rounded,
              label: 'QR Scan',
              color: AppColors.violet,
              gradient: AppGradients.violet,
              onTap: _openQrScanDialog,
            ),
            const SizedBox(width: 8),

            // Add button
            _actionButton(
              icon: Icons.add_shopping_cart_rounded,
              label: 'Add Item',
              color: AppColors.emerald,
              gradient: AppGradients.emerald,
              onTap: () => _handleBarcodeSubmit(_barcodeCtrl.text),
            ),
          ],
        ),

        // Inline feedback banner below input
        if (_feedbackText != null) _buildInlineFeedback(),
      ],
    );
  }

  Widget _buildSuggestionsDropdown() {
    return Material(
      elevation: 20,
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.emerald.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.emerald.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.emerald),
                      const SizedBox(width: 6),
                      Text(
                        'MATCHING CODES FOR "${_barcodeCtrl.text.trim()}"',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_suggestions.length} products · Click to add',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Suggestions List
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: AppColors.border.withOpacity(0.4),
                  indent: 14,
                  endIndent: 14,
                ),
                itemBuilder: (ctx, idx) {
                  final product = _suggestions[idx];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectProductSuggestion(product),
                      hoverColor: AppColors.emerald.withOpacity(0.12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            // Code badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.emerald.withOpacity(0.35)),
                              ),
                              child: Text(
                                product.code,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product names & barcode
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.nameEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        product.nameAr,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${product.barcode}',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Price & Select indicator
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${product.price.toStringAsFixed(2)} EGP',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.sky,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline_rounded,
                                        size: 11, color: AppColors.emerald.withOpacity(0.9)),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.emerald.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineFeedback() {
    final isSuccess = _feedbackSuccess ?? true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.emerald.withOpacity(0.12)
            : AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess
              ? AppColors.emerald.withOpacity(0.35)
              : AppColors.error.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 16,
            color: isSuccess ? AppColors.emerald : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            _feedbackText!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSuccess ? AppColors.emerald : AppColors.error,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => setState(() => _feedbackText = null),
            child: Icon(Icons.close_rounded,
                size: 14,
                color: isSuccess ? AppColors.emerald : AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  RIGHT: DEDICATED SHOPPING CART UI SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildShoppingCartSection() {
    return Container(
      width: 480,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cart Header ───────────────────────────────────────
          _buildCartHeader(),

          // ── Selected Products List ────────────────────────────
          Expanded(child: _buildCartProductsList()),

          // ── Running Total & Checkout Actions ──────────────────
          _buildCartFooter(),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.emerald,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_cart_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Shopping Cart',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.emerald.withOpacity(0.4)),
                      ),
                      child: Text(
                        '$itemCount items',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_lines.length} distinct products in current order',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Clear Cart button
          if (_lines.isNotEmpty)
            Tooltip(
              message: 'Clear Cart (ESC)',
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _lines.clear();
                    _statusMessage = 'Cart cleared';
                  });
                  print('[CART] Cleared');
                },
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartProductsList() {
    if (_lines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(Icons.remove_shopping_cart_rounded,
                    size: 48, color: AppColors.textMuted.withOpacity(0.4)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Shopping Cart is Empty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Scan a barcode, select from the catalog, or type code in search to add items.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _lines.length,
      itemBuilder: (ctx, idx) {
        final line = _lines[idx];
        return _buildCartLineCard(line, idx);
      },
    );
  }

  Widget _buildCartLineCard(MockCartLine line, int idx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Row 1: Product name, barcode, and delete button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Index
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Title & Arabic subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.nameEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          line.nameAr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${line.barcode}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Remove button
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  setState(() => _lines.removeAt(idx));
                  print('[CART] Removed ${line.nameEn}');
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: AppColors.error),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.border.withOpacity(0.5)),
          const SizedBox(height: 8),

          // Row 2: Individual Unit Price, Quantity controls, and Line Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Individual Unit Price clearly displayed
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UNIT PRICE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${line.unitPrice.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Quantity controls (- qty +)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _cartQtyButton(
                      icon: Icons.remove,
                      onTap: () {
                        setState(() {
                          if (line.quantity > 1) {
                            line.quantity--;
                          } else {
                            _lines.removeAt(idx);
                          }
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${line.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _cartQtyButton(
                      icon: Icons.add,
                      onTap: () => setState(() => line.quantity++),
                    ),
                  ],
                ),
              ),

              // Line Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'LINE TOTAL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${line.lineTotal.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.sky,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cartQtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }

  // ── Running Total & Checkout Actions Footer ───────────────────
  Widget _buildCartFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Running Total Breakdown ───────────────────────────
          const Text(
            'RUNNING TOTAL',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),

          _summaryRow('Subtotal', '${subtotal.toStringAsFixed(2)} EGP'),
          _summaryRow('VAT (14%)', '${tax.toStringAsFixed(2)} EGP'),

          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Big Running Total Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL DUE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Inclusive of taxes',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Text(
                  '${total.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: total > 0 ? AppColors.sky : AppColors.textMuted,
                    shadows: total > 0
                        ? [
                            Shadow(
                              color: AppColors.sky.withOpacity(
                                  0.4 * _glowController.value),
                              blurRadius: 14,
                            )
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Checkout Action Buttons ───────────────────────────
          // Two distinct buttons: Cash Payment & Visa Payment (F2)
          Row(
            children: [
              // Distinct Cash Payment Button (F1)
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _processPayment('CASH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: AppColors.emerald.withOpacity(0.35),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payments_rounded,
                            size: 20, color: AppColors.textOnAccent),
                        SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CASH PAY',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: AppColors.textOnAccent,
                              ),
                            ),
                            Text(
                              'Press F1',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textOnAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Distinct Visa Payment Button (F2)
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _processPayment('VISA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyanDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: AppColors.cyan.withOpacity(0.35),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card_rounded,
                            size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VISA PAY',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Press F2',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Void Cart Button (ESC)
          SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _lines.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _lines.clear();
                        _statusMessage = 'Cart voided';
                      });
                      print('[ACTION] Cart voided');
                    },
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.error),
              label: const Text(
                'VOID CART (ESC)',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STATUS BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          // Keyboard shortcuts hint
          ..._shortcutHints(),
        ],
      ),
    );
  }

  List<Widget> _shortcutHints() {
    const hints = [
      ('F1', 'Cash Pay'),
      ('F2', 'Visa Pay'),
      ('F3', 'Receipts'),
      ('F10', 'Catalog'),
      ('ESC', 'Void'),
    ];
    return hints
        .map(
          (h) => Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: Text(
                    h.$1,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  h.$2,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
