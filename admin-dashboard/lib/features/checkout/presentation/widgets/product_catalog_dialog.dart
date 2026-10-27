import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mock_data.dart';

/// Product Catalog modal dialog.
///
/// Triggered by pressing **F10** or clicking the Catalog button.
/// Provides searchable text fields for "Name" and "Code",
/// and a responsive grid of product cards.
class ProductCatalogDialog extends StatefulWidget {
  /// Called when the user taps a product to add it to the cart.
  final void Function(MockProduct product) onProductSelected;

  const ProductCatalogDialog({Key? key, required this.onProductSelected})
      : super(key: key);

  @override
  State<ProductCatalogDialog> createState() => _ProductCatalogDialogState();
}

class _ProductCatalogDialogState extends State<ProductCatalogDialog> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedCategory;
  List<MockProduct> _results = MockData.products;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final nameQ = _nameController.text.toLowerCase().trim();
    final codeQ = _codeController.text.toUpperCase().trim();

    setState(() {
      _results = MockData.products.where((p) {
        final matchesName = nameQ.isEmpty ||
            p.nameEn.toLowerCase().contains(nameQ) ||
            p.nameAr.contains(nameQ);
        final matchesCode = codeQ.isEmpty ||
            p.code.toUpperCase().contains(codeQ) ||
            p.barcode.contains(codeQ);
        final matchesCat =
            _selectedCategory == null || p.category == _selectedCategory;
        return matchesName && matchesCode && matchesCat;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 700),
        decoration: AppDecorations.glassCard(radius: 20),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            _buildHeader(context),
            // ── Search fields ───────────────────────────────────
            _buildSearchBar(),
            // ── Category chips ──────────────────────────────────
            _buildCategoryChips(),
            // ── Product grid ────────────────────────────────────
            Expanded(child: _buildProductGrid()),
            // ── Footer ──────────────────────────────────────────
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: AppColors.emerald, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Catalog',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Search & browse products — Shortcut: F10',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          _keyBadge('F10'),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            tooltip: 'Close (Esc)',
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          // Search by Name
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: AppDecorations.searchField(
                hint: 'Search by Product Name…',
                prefixIcon: Icons.search_rounded,
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 12),

          // Search by Code
          Expanded(
            flex: 2,
            child: TextField(
              controller: _codeController,
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
              decoration: AppDecorations.searchField(
                hint: 'Search by Code / Barcode…',
                prefixIcon: Icons.qr_code_rounded,
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 12),

          // Clear button
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _nameController.clear();
                _codeController.clear();
                _selectedCategory = null;
                _applyFilters();
              },
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: const Text('Clear'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category filter chips ─────────────────────────────────────
  Widget _buildCategoryChips() {
    final categories = MockData.categories;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _categoryChip(null, 'All'),
          ...categories.map((c) => _categoryChip(c, c)),
        ],
      ),
    );
  }

  Widget _categoryChip(String? value, String label) {
    final selected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.textOnAccent : AppColors.textSecondary,
          ),
        ),
        selected: selected,
        selectedColor: AppColors.emerald,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: selected ? AppColors.emerald : AppColors.border,
        ),
        onSelected: (_) {
          _selectedCategory = value;
          _applyFilters();
        },
      ),
    );
  }

  // ── Product grid ──────────────────────────────────────────────
  Widget _buildProductGrid() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text(
              'No products match your search.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _results.length,
        itemBuilder: (_, i) => _productCard(_results[i]),
      ),
    );
  }

  Widget _productCard(MockProduct p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.emerald.withOpacity(0.06),
        onTap: () {
          widget.onProductSelected(p);
          Navigator.pop(context);
          print('[CATALOG] Selected product: ${p.nameEn} (${p.code})');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _categoryColor(p.category).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _categoryIcon(p.category),
                  color: _categoryColor(p.category),
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),

              // Name
              Text(
                p.nameEn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                p.nameAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),

              const Spacer(),

              // Price
              Text(
                '${p.price.toStringAsFixed(2)} EGP',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),

              // Code badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.textMuted.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(
            '${_results.length} of ${MockData.products.length} products shown',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.6),
            ),
          ),
          const Spacer(),
          Text(
            'Click a product to add to cart',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.emerald.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _keyBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Beverages':
        return AppColors.cyan;
      case 'Dairy':
        return AppColors.amber;
      case 'Bakery':
        return const Color(0xFFE97451);
      case 'Snacks':
        return AppColors.violet;
      case 'Cleaning':
        return AppColors.info;
      case 'Frozen':
        return const Color(0xFF67E8F9);
      case 'Fruits':
        return AppColors.success;
      case 'Meat':
        return AppColors.rose;
      case 'Personal Care':
        return const Color(0xFFC084FC);
      case 'Grocery':
        return AppColors.amber;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Beverages':
        return Icons.local_drink_rounded;
      case 'Dairy':
        return Icons.egg_rounded;
      case 'Bakery':
        return Icons.bakery_dining_rounded;
      case 'Snacks':
        return Icons.fastfood_rounded;
      case 'Cleaning':
        return Icons.cleaning_services_rounded;
      case 'Frozen':
        return Icons.ac_unit_rounded;
      case 'Fruits':
        return Icons.apple_rounded;
      case 'Meat':
        return Icons.restaurant_rounded;
      case 'Personal Care':
        return Icons.face_retouching_natural_rounded;
      case 'Grocery':
        return Icons.rice_bowl_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }
}
