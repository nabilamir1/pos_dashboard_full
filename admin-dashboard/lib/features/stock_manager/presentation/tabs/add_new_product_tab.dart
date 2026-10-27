import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/pos_state_manager.dart';

/// Tab 4: Add New Product Tab
/// Allows Stock Manager to type or scan a new barcode, configure product attributes,
/// and save it directly to the warehouse inventory and POS catalog.
class AddNewProductTab extends StatefulWidget {
  const AddNewProductTab({super.key});

  @override
  State<AddNewProductTab> createState() => _AddNewProductTabState();
}

class _AddNewProductTabState extends State<AddNewProductTab> {
  final _formKey = GlobalKey<FormState>();

  final _barcodeCtrl = TextEditingController(text: '6229988771122');
  final _codeCtrl = TextEditingController(text: 'GRO-015');
  final _nameEnCtrl = TextEditingController(text: 'Al-Doha Egyptian White Rice 1kg');
  final _nameArCtrl = TextEditingController(text: 'أرز مصرى فاخر الضحى ١ ك');
  final _priceCtrl = TextEditingController(text: '34.50');
  final _whStockCtrl = TextEditingController(text: '300');
  final _storeStockCtrl = TextEditingController(text: '60');
  final _thresholdCtrl = TextEditingController(text: '50');

  String _selectedCategory = 'Grocery';

  final List<String> _categories = [
    'Beverages',
    'Dairy',
    'Bakery',
    'Fruits',
    'Meat',
    'Snacks',
    'Grocery',
    'Cleaning',
  ];

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _codeCtrl.dispose();
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _priceCtrl.dispose();
    _whStockCtrl.dispose();
    _storeStockCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _simulateBarcodeScan() {
    final randomDigits = 100000000000 + Random().nextInt(899999999999);
    final generatedBarcode = '622$randomDigits'.substring(0, 13);
    setState(() {
      _barcodeCtrl.text = generatedBarcode;
      _codeCtrl.text = 'SKU-${Random().nextInt(900) + 100}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulated Barcode Scanned: $generatedBarcode'),
        backgroundColor: AppColors.neonCyan,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final barcode = _barcodeCtrl.text.trim();
    final code = _codeCtrl.text.trim().toUpperCase();
    final nameEn = _nameEnCtrl.text.trim();
    final nameAr = _nameArCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final whStock = int.tryParse(_whStockCtrl.text.trim()) ?? 0;
    final storeStock = int.tryParse(_storeStockCtrl.text.trim()) ?? 0;
    final threshold = int.tryParse(_thresholdCtrl.text.trim()) ?? 50;

    PosStateManager.instance.addNewProduct(
      barcode: barcode,
      code: code,
      nameEn: nameEn,
      nameAr: nameAr,
      category: _selectedCategory,
      price: price,
      initialWarehouseStock: whStock,
      initialStoreStock: storeStock,
      minThreshold: threshold,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product "$nameEn" added to warehouse with $whStock units!'),
        backgroundColor: AppColors.emerald,
      ),
    );

    // Reset with new simulated values
    _simulateBarcodeScan();
    setState(() {
      _nameEnCtrl.clear();
      _nameArCtrl.clear();
      _priceCtrl.text = '25.00';
      _whStockCtrl.text = '200';
      _storeStockCtrl.text = '50';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: Add Product Form ─────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.cyborgCard(
                radius: 16,
                isDark: isDark,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_box_rounded, color: AppColors.neonCyan, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register New Warehouse SKU',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Scan barcode or enter manually to expand inventory catalog',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondary : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Barcode & SKU Code
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('BARCODE (EAN-13 / UPC)', isDark),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _barcodeCtrl,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.textWhite : Colors.black87,
                                      ),
                                      decoration: _inputDecoration('Scan or type barcode', isDark),
                                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _simulateBarcodeScan,
                                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                                    label: const Text('SCAN'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.electricPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('SKU CODE', isDark),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _codeCtrl,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neonCyan,
                                ),
                                decoration: _inputDecoration('e.g. GRO-015', isDark),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Product Names (English & Arabic)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('PRODUCT NAME (ENGLISH)', isDark),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameEnCtrl,
                                style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                                decoration: _inputDecoration('e.g. Al-Doha Rice 1kg', isDark),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('PRODUCT NAME (ARABIC)', isDark),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameArCtrl,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(color: isDark ? AppColors.textWhite : Colors.black87),
                                decoration: _inputDecoration('مثال: أرز الضحى ١ كيلو', isDark),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Category & Retail Price
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('CATEGORY', isDark),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    dropdownColor: isDark ? AppColors.card : Colors.white,
                                    items: _categories.map((c) {
                                      return DropdownMenuItem<String>(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: TextStyle(
                                            color: isDark ? AppColors.textWhite : Colors.black87,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCategory = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('RETAIL PRICE (EGP)', isDark),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _priceCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.textWhite : Colors.black87,
                                ),
                                decoration: _inputDecoration('0.00 EGP', isDark),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Initial Quantities
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('INITIAL WAREHOUSE STOCK', isDark),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _whStockCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.neonCyan),
                                decoration: _inputDecoration('Units in Bay', isDark),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('INITIAL STORE POS STOCK', isDark),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _storeStockCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.electricPurpleLight),
                                decoration: _inputDecoration('Units on shelf', isDark),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('MIN THRESHOLD', isDark),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _thresholdCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.amber),
                                decoration: _inputDecoration('Alert level', isDark),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveProduct,
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: const Text('SAVE PRODUCT TO WAREHOUSE & POS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonCyan,
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),

          // ── Right: Live Card Preview ───────────────────────────────────────
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE CATALOG PREVIEW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.textMuted : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),

                // Preview Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.neonCyan, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.electricPurple.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.electricPurple.withOpacity(0.4)),
                            ),
                            child: Text(
                              _selectedCategory.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.electricPurpleLight,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
                            ),
                            child: const Text(
                              'READY TO SYNC',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.emerald),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Text(
                        _nameEnCtrl.text.isEmpty ? 'Product Name (English)' : _nameEnCtrl.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nameArCtrl.text.isEmpty ? 'اسم المنتج بالعربية' : _nameArCtrl.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surface : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _previewRow('SKU Code:', _codeCtrl.text.isEmpty ? 'SKU-000' : _codeCtrl.text, isDark),
                            const SizedBox(height: 6),
                            _previewRow('Barcode:', _barcodeCtrl.text.isEmpty ? '-------------' : _barcodeCtrl.text, isDark, mono: true),
                            const SizedBox(height: 6),
                            _previewRow('Retail Price:', '${_priceCtrl.text.isEmpty ? "0.00" : _priceCtrl.text} EGP', isDark, isHighlight: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Text('WH STOCK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.neonCyan)),
                                  const SizedBox(height: 4),
                                  Text('${_whStockCtrl.text.isEmpty ? "0" : _whStockCtrl.text} units', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.electricPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.electricPurple.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Text('POS STORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.electricPurpleLight)),
                                  const SizedBox(height: 4),
                                  Text('${_storeStockCtrl.text.isEmpty ? "0" : _storeStockCtrl.text} units', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.cyborgCard(radius: 12, isDark: isDark),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.neonCyan, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Saving this product immediately records an audit log and registers the item for barcode scanning in both In-Store POS and Online Cashier dispatch.',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: isDark ? AppColors.textMuted : Colors.black54,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? AppColors.border : const Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _previewRow(String label, String value, bool isDark, {bool mono = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontFamily: mono ? 'monospace' : null,
            fontWeight: FontWeight.w800,
            color: isHighlight
                ? AppColors.neonCyan
                : (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
