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
  String? _error;
  Map<String, dynamic>? _product;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final product = await ApiService().getProduct(widget.slug);
      if (!mounted) return;
      if (product is Map<String, dynamic>) {
        setState(() { _product = product; _loading = false; });
      } else {
        setState(() { _error = 'Format data tidak valid'; _loading = false; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _getImageUrl() {
    final images = _product?['images'] as List<dynamic>?;
    if (images == null || images.isEmpty) return '';
    return images[0]['image_url']?.toString() ?? '';
  }

  String _getPrice() {
    final variants = _product?['variants'] as List<dynamic>?;
    if (variants == null || variants.isEmpty) return '0';
    return variants[0]['price']?.toString() ?? '0';
  }

  dynamic _getVariantId() {
    final variants = _product?['variants'] as List<dynamic>?;
    if (variants == null || variants.isEmpty) return null;
    return variants[0]['id'];
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
    final price = _getPrice();

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
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 64, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['name']?.toString() ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp $price',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brandRed),
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
                      onPressed: () async {
                        final variantId = _getVariantId();
                        if (variantId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❌ Varian tidak tersedia')),
                          );
                          return;
                        }
                        try {
                          await ApiService().addToCart(variantId, 1, sellingMode: 'package');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✅ ${p['name']} ditambahkan ke keranjang')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('❌ Gagal: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('TAMBAH KE KERANJANG', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

