import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _loading = true;
  bool _addingToCart = false;
  String? _error;
  Map<String, dynamic>? _product;
  String _sellingMode = 'retail';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final product = await ApiService().getProduct(widget.slug);
      if (!mounted) return;

      if (product is Map<String, dynamic>) {
        setState(() {
          _product = product;
          _loading = false;
          _sellingMode = 'retail';
        });
      } else {
        setState(() {
          _error = 'Format data tidak valid';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? _getVariant() {
    final variants = _product?['variants'];
    if (variants is! List || variants.isEmpty || variants.first is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(variants.first as Map);
  }

  dynamic _getVariantId() => _getVariant()?['id'];

  String _getImageUrl() {
    final images = _product?['images'];
    if (images is! List || images.isEmpty || images.first is! Map) {
      return '';
    }
    return images.first['image_url']?.toString() ?? '';
  }

  String _salesMode() {
    return (_getVariant()?['sales_mode'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  double? _validPrice(dynamic value) {
    if (value == null) return null;
    final parsed = double.tryParse(value.toString());
    if (parsed == null || !parsed.isFinite || parsed <= 0) return null;
    return parsed;
  }

  double? _getSelectedPrice() {
    final variant = _getVariant();
    if (variant == null) return null;

    if (_salesMode() == 'package') {
      return _validPrice(variant['retail_price']) ??
          _validPrice(variant['price']);
    }

    if (_salesMode() == 'weight') {
      if (_sellingMode == 'b2b') {
        return _validPrice(variant['b2b_price']);
      }
      return _validPrice(variant['retail_price']) ??
          _validPrice(variant['price']);
    }

    return null;
  }

  int _initialQuantity() {
    if (_salesMode() == 'weight' && _sellingMode == 'b2b') {
      return 100;
    }
    return 1;
  }

  String _unitLabel() {
    if (_salesMode() == 'weight') return 'kg';
    if (_salesMode() == 'package') return 'unit';
    return '';
  }

  String _formatPrice(double value) {
    final rounded = value.round();
    final digits = rounded.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  bool _canAddToCart() {
    final variant = _getVariant();
    if (variant == null || _getVariantId() == null) return false;

    final mode = _salesMode();
    if (mode != 'package' && mode != 'weight') return false;

    if (mode == 'weight' &&
        _sellingMode != 'retail' &&
        _sellingMode != 'b2b') {
      return false;
    }

    final price = _getSelectedPrice();
    if (price == null) return false;

    final stock = num.tryParse(
      (variant['available_stock'] ?? '').toString(),
    );
    if (stock != null && stock < _initialQuantity()) return false;

    return true;
  }

  Future<void> _addToCart() async {
    if (_addingToCart) return;

    if (!_canAddToCart()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga, stok, atau konfigurasi produk tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final variantId = _getVariantId();
    final quantity = _initialQuantity();
    final mode = _salesMode() == 'package' ? 'package' : _sellingMode;
    final unit = _unitLabel();
    final productName = _product?['name']?.toString() ?? 'Produk';

    setState(() => _addingToCart = true);

    try {
      await ApiService().addToCart(
        variantId,
        quantity,
        sellingMode: mode,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$productName ($quantity $unit) ditambahkan ke keranjang',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // TAMPILKAN ERROR ASLI DARI API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _addingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: brandRed)),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: Center(child: Text('Gagal load produk: $_error')),
      );
    }

    final p = _product!;
    final imageUrl = _getImageUrl();
    final salesMode = _salesMode();
    final selectedPrice = _getSelectedPrice();
    final isWeight = salesMode == 'weight';
    final isPackage = salesMode == 'package';
    final canAdd = _canAddToCart();

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: Text(p['name']?.toString() ?? 'Detail Produk'),
        backgroundColor: Colors.white,
        foregroundColor: ink,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 250,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['name']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isWeight) ...[
                    const Text(
                      'Pilih jenis pembelian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Retail · 1 kg'),
                            selected: _sellingMode == 'retail',
                            selectedColor: brandRed.withValues(alpha: 0.14),
                            onSelected: _addingToCart
                                ? null
                                : (_) {
                                    setState(() => _sellingMode = 'retail');
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_validPrice(_getVariant()?['b2b_price']) != null)
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('B2B · 100 kg'),
                              selected: _sellingMode == 'b2b',
                              selectedColor: brandRed.withValues(alpha: 0.14),
                              onSelected: _addingToCart
                                  ? null
                                  : (_) {
                                      setState(() => _sellingMode = 'b2b');
                                    },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ] else if (isPackage) ...[
                    const Text(
                      'Jenis pembelian: Kemasan',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    const Text(
                      'Konfigurasi penjualan produk tidak valid.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    selectedPrice == null
                        ? 'Harga tidak tersedia'
                        : 'Rp ${_formatPrice(selectedPrice)} / ${_unitLabel()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: brandRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p['business_name']?.toString() ?? '',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p['short_description']?.toString() ?? '',
                    style: const TextStyle(fontSize: 14, color: ink),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: canAdd && !_addingToCart ? _addToCart : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Produk belum dapat dibeli (cek stok/harga)'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAdd ? brandRed : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _addingToCart
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'TAMBAH KE KERANJANG',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  if (!canAdd) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Produk belum dapat dibeli. Periksa harga dan ketersediaan stok.',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
