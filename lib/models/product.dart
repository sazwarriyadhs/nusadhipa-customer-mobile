class Product {
  final String publicId;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? brand;
  final String categoryName;
  final String categorySlug;
  final String businessName;
  final String businessSlug;
  final double minPrice;
  final double maxPrice;
  final int availableStock;
  final String? imageUrl;

  Product({
    required this.publicId,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.brand,
    required this.categoryName,
    required this.categorySlug,
    required this.businessName,
    required this.businessSlug,
    required this.minPrice,
    required this.maxPrice,
    required this.availableStock,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return Product(
      publicId: (json['public_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      shortDescription: json['short_description']?.toString(),
      brand: json['brand']?.toString(),
      categoryName: (json['category_name'] ?? '').toString(),
      categorySlug: (json['category_slug'] ?? '').toString(),
      businessName: (json['business_name'] ?? '').toString(),
      businessSlug: (json['business_slug'] ?? '').toString(),
      minPrice: parseDouble(json['min_price']),
      maxPrice: parseDouble(json['max_price']),
      availableStock: parseInt(json['available_stock']),
      imageUrl: json['image_url']?.toString(),
    );
  }

  String get priceDisplay {
    if (minPrice <= 0) return 'Harga belum tersedia';
    if (maxPrice > minPrice) {
      return 'Rp ${_fmt(minPrice)} - Rp ${_fmt(maxPrice)}';
    }
    return 'Rp ${_fmt(minPrice)}';
  }

  String _fmt(double value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: (json['name'] ?? '').toString(),
        slug: (json['slug'] ?? '').toString(),
        description: json['description']?.toString(),
        imageUrl: json['image_url']?.toString(),
      );
}