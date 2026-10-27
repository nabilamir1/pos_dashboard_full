import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mock_data.dart';

/// QR / Barcode Scan dialog with a mock camera preview.
///
/// Simulates scanning behaviour by showing an animated "viewfinder"
/// and auto-resolving to a random mock product after a short delay.
class QrScanDialog extends StatefulWidget {
  /// Called when a product is "scanned" (mocked).
  final void Function(MockProduct product) onProductScanned;

  const QrScanDialog({Key? key, required this.onProductScanned})
      : super(key: key);

  @override
  State<QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<QrScanDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLineController;
  bool _isScanning = true;
  MockProduct? _scannedProduct;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate a scan completing after 3 seconds
    _scanTimer = Timer(const Duration(seconds: 3), _simulateScan);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _simulateScan() {
    if (!mounted) return;
    final rng = Random();
    final product =
        MockData.products[rng.nextInt(MockData.products.length)];
    setState(() {
      _isScanning = false;
      _scannedProduct = product;
    });
    print('[QR SCAN] Mock-scanned: ${product.nameEn} (${product.barcode})');
  }

  void _reScan() {
    setState(() {
      _isScanning = true;
      _scannedProduct = null;
    });
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 3), _simulateScan);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        decoration: AppDecorations.glassCard(radius: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildCameraPreview(),
            if (_scannedProduct != null) _buildResult(),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.qr_code_scanner_rounded,
                color: AppColors.cyan, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR / Barcode Scanner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Point camera at product barcode',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.close_rounded, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Mock camera preview ───────────────────────────────────────
  Widget _buildCameraPreview() {
    return Container(
      height: 260,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Dark "camera" background with noise simulation
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: CustomPaint(painter: _CameraNoisePainter()),
            ),
          ),

          // Viewfinder corners
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isScanning
                      ? AppColors.cyan.withOpacity(0.6)
                      : AppColors.success,
                  width: 2,
                ),
              ),
            ),
          ),

          // Animated scan line
          if (_isScanning)
            AnimatedBuilder(
              animation: _scanLineController,
              builder: (_, __) {
                final offset =
                    40 + (_scanLineController.value * 180);
                return Positioned(
                  top: offset,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.cyan,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Status overlay
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isScanning) ...[
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Scanning…',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.check_circle_rounded,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      const Text(
                        'Product detected!',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scan result ───────────────────────────────────────────────
  Widget _buildResult() {
    final p = _scannedProduct!;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emerald.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emerald.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: AppColors.emerald, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nameEn,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.barcode}  ·  ${p.code}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${p.price.toStringAsFixed(2)} EGP',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _reScan,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Re-scan'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _scannedProduct == null
                  ? null
                  : () {
                      widget.onProductScanned(_scannedProduct!);
                      Navigator.pop(context);
                    },
              icon: const Icon(Icons.add_shopping_cart_rounded,
                  size: 18, color: AppColors.textOnAccent),
              label: const Text('Add to Cart',
                  style: TextStyle(color: AppColors.textOnAccent)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                disabledBackgroundColor:
                    AppColors.emerald.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a subtle noise pattern to simulate a dark camera feed.
class _CameraNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rng = Random(42); // deterministic seed for stable render

    // Dark base
    paint.color = const Color(0xFF080D18);
    canvas.drawRect(Offset.zero & size, paint);

    // Noise dots
    for (int i = 0; i < 300; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final brightness = rng.nextInt(30) + 10;
      paint.color = Color.fromARGB(40, brightness, brightness, brightness);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

