class Order {
  final String publicId;
  final String orderNumber;
  final String status;
  final String currency;
  final double grandTotal;
  final double subtotal;
  final double shippingTotal;
  final DateTime? placedAt;
  final DateTime? paidAt;
  final DateTime? completedAt;
  final String buyerName;
  final String? buyerEmail;
  final int itemsCount;
  final double totalQuantity;
  final double? shippingDistanceKm;
  final double? shippingLat;
  final double? shippingLng;

  Order({
    required this.publicId,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.grandTotal,
    required this.subtotal,
    required this.shippingTotal,
    this.placedAt,
    this.paidAt,
    this.completedAt,
    required this.buyerName,
    this.buyerEmail,
    required this.itemsCount,
    required this.totalQuantity,
    this.shippingDistanceKm,
    this.shippingLat,
    this.shippingLng,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        publicId: (json['public_id'] ?? '').toString(),
        orderNumber: (json['order_number'] ?? '').toString(),
        status: (json['status'] ?? 'pending_payment').toString(),
        currency: (json['currency'] ?? 'IDR').toString(),
        grandTotal: _num(json['grand_total']),
        subtotal: _num(json['subtotal']),
        shippingTotal: _num(json['shipping_total']),
        placedAt: _parseDate(json['placed_at']),
        paidAt: _parseDate(json['paid_at']),
        completedAt: _parseDate(json['completed_at']),
        buyerName: (json['buyer_name'] ?? 'Pembeli').toString(),
        buyerEmail: json['buyer_email']?.toString(),
        itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
        totalQuantity: _num(json['total_quantity']),
        shippingDistanceKm: json['shipping_distance_km'] != null
            ? _num(json['shipping_distance_km'])
            : null,
        shippingLat: json['shipping_lat'] != null
            ? _num(json['shipping_lat'])
            : null,
        shippingLng: json['shipping_lng'] != null
            ? _num(json['shipping_lng'])
            : null,
      );

  String get statusLabel {
    switch (status) {
      case 'pending_payment':
        return 'Baru';
      case 'paid':
        return 'Dibayar';
      case 'processing':
        return 'Diproses';
      case 'partially_shipped':
        return 'Sebagian Dikirim';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'refunded':
        return 'Refund';
      default:
        return status;
    }
  }

  /// Apakah order gratis ongkir
  bool get isFreeShipping => shippingTotal <= 0;

  /// Label jarak
  String get distanceLabel {
    if (shippingDistanceKm == null) return '';
    return '${shippingDistanceKm!.toStringAsFixed(1)} km';
  }

  /// Label ongkir
  String get shippingLabel {
    if (isFreeShipping) return 'GRATIS';
    return 'Rp ${_formatRupiahNumber(shippingTotal)}';
  }

  String get grandTotalDisplay {
    final s = grandTotal.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }
}

class Shipment {
  final int id;
  final String orderNumber;
  final String orderPublicId;
  final String? courier;
  final String? serviceName;
  final String? trackingNumber;
  final String status;
  final double shippingCost;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? destinationCity;

  Shipment({
    required this.id,
    required this.orderNumber,
    required this.orderPublicId,
    this.courier,
    this.serviceName,
    this.trackingNumber,
    required this.status,
    required this.shippingCost,
    this.shippedAt,
    this.deliveredAt,
    this.destinationCity,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        id: (json['id'] as num?)?.toInt() ?? 0,
        orderNumber: (json['order_number'] ?? '').toString(),
        orderPublicId: (json['order_public_id'] ?? '').toString(),
        courier: json['courier']?.toString(),
        serviceName: json['service_name']?.toString(),
        trackingNumber: json['tracking_number']?.toString(),
        status: (json['status'] ?? 'pending').toString(),
        shippingCost: _num(json['shipping_cost']),
        shippedAt: _parseDate(json['shipped_at']),
        deliveredAt: _parseDate(json['delivered_at']),
        destinationCity: json['destination_city']?.toString(),
      );

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'ready':
        return 'Siap Kirim';
      case 'picked_up':
        return 'Diambil Kurir';
      case 'in_transit':
        return 'Dalam Perjalanan';
      case 'delivered':
        return 'Terkirim';
      case 'failed':
        return 'Gagal';
      case 'returned':
        return 'Dikembalikan';
      default:
        return status;
    }
  }
}

double _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}

/// Format angka jadi format Rupiah dengan pemisah ribuan
String _formatRupiahNumber(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}