import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0', 'id_ID');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: line),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'product-image-${product.slug}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        product.imageUrl ?? '',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: line,
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: brandRed),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => Container(
                          color: line,
                          child: const Icon(Icons.image_not_supported, color: muted, size: 32),
                        ),
                      ),
                      if (product.maxPrice > product.minPrice)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Text(
                              'PROMO',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      if (onQuickAdd != null)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Material(
                            color: brandRed,
                            shape: const CircleBorder(),
                            elevation: 3,
                            shadowColor: brandRed.withValues(alpha: 0.5),
                            child: InkWell(
                              onTap: onQuickAdd,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: gold),
                      const SizedBox(width: 2),
                      Text('4.8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: muted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${currency.format(product.minPrice)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: brandRed, letterSpacing: -0.2),
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