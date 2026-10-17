import 'dart:convert';

class OrderLineItem {
  final String productName;
  final String variantName;
  final String? sku;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  OrderLineItem({
    required this.productName,
    required this.variantName,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
        productName: (json['product_name'] ?? '').toString(),
        variantName: (json['variant_name'] ?? '').toString(),
        sku: json['sku']?.toString(),
        quantity: _toDouble(json['quantity']),
        unitPrice: _toDouble(json['unit_price']),
        lineTotal: _toDouble(json['line_total']),
      );
}

class OrderDetail {
  final String publicId;
  final String orderNumber;
  final String status;
  final String currency;
  final double subtotal;
  final double discountTotal;
  final double shippingTotal;
  final double grandTotal;
  final String shippingAddress;
  final String? customerNote;
  final DateTime? placedAt;
  final DateTime? paidAt;
  final DateTime? completedAt;
  final String buyerName;
  final String? buyerEmail;
  final List<OrderLineItem> items;
  final double? shippingDistanceKm;
  final double? shippingLat;
  final double? shippingLng;

  OrderDetail({
    required this.publicId,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.discountTotal,
    required this.shippingTotal,
    required this.grandTotal,
    required this.shippingAddress,
    this.customerNote,
    this.placedAt,
    this.paidAt,
    this.completedAt,
    required this.buyerName,
    this.buyerEmail,
    required this.items,
    this.shippingDistanceKm,
    this.shippingLat,
    this.shippingLng,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <OrderLineItem>[];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          items.add(OrderLineItem.fromJson(it));
        }
      }
    }

    return OrderDetail(
      publicId: (json['public_id'] ?? '').toString(),
      orderNumber: (json['order_number'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      currency: (json['currency'] ?? 'IDR').toString(),
      subtotal: _toDouble(json['subtotal']),
      discountTotal: _toDouble(json['discount_total']),
      shippingTotal: _toDouble(json['shipping_total']),
      grandTotal: _toDouble(json['grand_total']),
      shippingAddress: (json['shipping_address'] ?? '{}').toString(),
      customerNote: json['customer_note']?.toString(),
      placedAt: _parseDate(json['placed_at']),
      paidAt: _parseDate(json['paid_at']),
      completedAt: _parseDate(json['completed_at']),
      buyerName: (json['buyer_name'] ?? 'Pembeli').toString(),
      buyerEmail: json['buyer_email']?.toString(),
      items: items,
      shippingDistanceKm: json['shipping_distance_km'] != null
          ? _toDouble(json['shipping_distance_km'])
          : null,
      shippingLat: json['shipping_lat'] != null
          ? _toDouble(json['shipping_lat'])
          : null,
      shippingLng: json['shipping_lng'] != null
          ? _toDouble(json['shipping_lng'])
          : null,
    );
  }

  /// Parse shipping address JSON ke Map
  Map<String, dynamic> get addressMap {
    try {
      final decoded = jsonDecode(shippingAddress);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  String get statusLabel {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Sudah Dibayar';
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
}

double _toDouble(dynamic v) {
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