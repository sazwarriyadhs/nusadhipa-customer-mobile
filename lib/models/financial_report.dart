class ReportSummary {
  final int totalOrders;
  final double totalSales;
  final double totalDiscount;
  final double totalShipping;
  final double totalRevenue;

  ReportSummary({
    required this.totalOrders,
    required this.totalSales,
    required this.totalDiscount,
    required this.totalShipping,
    required this.totalRevenue,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
        totalSales: _num(json['total_sales']),
        totalDiscount: _num(json['total_discount']),
        totalShipping: _num(json['total_shipping']),
        totalRevenue: _num(json['total_revenue']),
      );
}

class StatusBreakdown {
  final String status;
  final int count;
  final double total;

  StatusBreakdown({
    required this.status,
    required this.count,
    required this.total,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) =>
      StatusBreakdown(
        status: (json['status'] ?? '').toString(),
        count: (json['count'] as num?)?.toInt() ?? 0,
        total: _num(json['total']),
      );

  String get label {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Bayar';
      case 'paid':
        return 'Dibayar';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Batal';
      default:
        return status;
    }
  }
}

class TransactionRow {
  final String orderNumber;
  final String status;
  final DateTime? placedAt;
  final double grandTotal;
  final String? buyerName;
  final int itemsCount;

  TransactionRow({
    required this.orderNumber,
    required this.status,
    this.placedAt,
    required this.grandTotal,
    this.buyerName,
    required this.itemsCount,
  });

  factory TransactionRow.fromJson(Map<String, dynamic> json) =>
      TransactionRow(
        orderNumber: (json['order_number'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        placedAt: _parseDate(json['placed_at']),
        grandTotal: _num(json['grand_total']),
        buyerName: json['buyer_name']?.toString(),
        itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
      );
}

class TopProduct {
  final String productName;
  final String variantName;
  final double totalQty;
  final double totalSales;

  TopProduct({
    required this.productName,
    required this.variantName,
    required this.totalQty,
    required this.totalSales,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        productName: (json['product_name'] ?? '').toString(),
        variantName: (json['variant_name'] ?? '').toString(),
        totalQty: _num(json['total_qty']),
        totalSales: _num(json['total_sales']),
      );
}

class DailySale {
  final DateTime? date;
  final int orders;
  final double total;

  DailySale({this.date, required this.orders, required this.total});

  factory DailySale.fromJson(Map<String, dynamic> json) => DailySale(
        date: _parseDate(json['date']),
        orders: (json['orders'] as num?)?.toInt() ?? 0,
        total: _num(json['total']),
      );
}

class FinancialReport {
  final DateTime? from;
  final DateTime? to;
  final ReportSummary summary;
  final List<StatusBreakdown> byStatus;
  final List<TransactionRow> transactions;
  final List<TopProduct> topProducts;
  final List<DailySale> dailySales;

  FinancialReport({
    this.from,
    this.to,
    required this.summary,
    required this.byStatus,
    required this.transactions,
    required this.topProducts,
    required this.dailySales,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>? ?? {};
    
    return FinancialReport(
      from: _parseDate(period['from']),
      to: _parseDate(period['to']),
      summary: ReportSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
      byStatus: (json['by_status'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StatusBreakdown.fromJson)
          .toList(),
      transactions: (json['transactions'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TransactionRow.fromJson)
          .toList(),
      topProducts: (json['top_products'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TopProduct.fromJson)
          .toList(),
      dailySales: (json['daily_sales'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DailySale.fromJson)
          .toList(),
    );
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