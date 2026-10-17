import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/business.dart';
import '../models/financial_report.dart';
import 'pdf_service.dart';

class ReportService {
  /// Generate Laporan Keuangan PDF
  static Future<Uint8List> generateFinancialReport({
    required Business? business,
    required FinancialReport report,
  }) async {
    final doc = pw.Document(
      title: "Laporan Keuangan",
      author: business?.legalName ?? "NUSA-DHIPA",
      subject: "Laporan Keuangan Periode ${_formatDate(report.from)} - ${_formatDate(report.to)}",
    );

    final header = await PdfService.buildHeader(
      business: business,
      documentTitle: "Laporan Keuangan",
      documentNumber: "RPT-${DateFormat('yyyyMMdd').format(DateTime.now())}",
      documentDate: "Periode: ${_formatDate(report.from)} - ${_formatDate(report.to)}",
    );

    final footer = await PdfService.buildFooter(
      documentTitle: "Laporan Keuangan",
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => header,
        footer: (_) => footer,
        build: (_) => [
          pw.SizedBox(height: 20),

          // ===== RINGKASAN =====
          _sectionTitle("RINGKASAN"),
          pw.SizedBox(height: 10),
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [
                  PdfColor.fromInt(0xFFE5232E),
                  PdfColor.fromInt(0xFF98182A),
                ],
              ),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _summaryBox(
                        "TOTAL PENDAPATAN",
                        PdfService.formatRupiah(report.summary.totalRevenue),
                        big: true,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryBox(
                        "TOTAL ORDER",
                        "${report.summary.totalOrders}",
                        big: true,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColors.white),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _summaryBox(
                        "Penjualan",
                        PdfService.formatRupiah(report.summary.totalSales),
                        small: true,
                      ),
                    ),
                    pw.Expanded(
                      child: _summaryBox(
                        "Diskon",
                        PdfService.formatRupiah(report.summary.totalDiscount),
                        small: true,
                      ),
                    ),
                    pw.Expanded(
                      child: _summaryBox(
                        "Ongkir",
                        PdfService.formatRupiah(report.summary.totalShipping),
                        small: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ===== STATUS BREAKDOWN =====
          _sectionTitle("STATUS PESANAN"),
          pw.SizedBox(height: 10),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: const PdfColor.fromInt(0xFFECECF0)),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                pw.Container(
                  color: const PdfColor.fromInt(0xFFF8FAFC),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text("Status", style: _headerStyle()),
                      ),
                      pw.Expanded(
                        child: pw.Text("Jumlah", style: _headerStyle(), textAlign: pw.TextAlign.right),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text("Total", style: _headerStyle(), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                ),
                ...report.byStatus.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final s = entry.value;
                  final isEven = idx % 2 == 0;
                  return pw.Container(
                    color: isEven ? const PdfColor.fromInt(0xFFFAFAFB) : PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8,
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(s.label, style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            "${s.count}",
                            style: pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            PdfService.formatRupiah(s.total),
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ===== TOP PRODUK =====
          if (report.topProducts.isNotEmpty) ...[
            _sectionTitle("PRODUK TERLARIS"),
            pw.SizedBox(height: 10),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFECECF0)),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    color: const PdfColor.fromInt(0xFFF8FAFC),
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8,
                    ),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 24,
                          child: pw.Text("#", style: _headerStyle()),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text("Produk", style: _headerStyle()),
                        ),
                        pw.Expanded(
                          child: pw.Text("Qty", style: _headerStyle(), textAlign: pw.TextAlign.right),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text("Penjualan", style: _headerStyle(), textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  ...report.topProducts.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final p = entry.value;
                    final isEven = idx % 2 == 0;
                    return pw.Container(
                      color: isEven ? const PdfColor.fromInt(0xFFFAFAFB) : PdfColors.white,
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8,
                      ),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 24,
                            child: pw.Text("$idx", style: pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            flex: 4,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  p.productName,
                                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  p.variantName,
                                  style: pw.TextStyle(
                                    fontSize: 7.5,
                                    color: const PdfColor.fromInt(0xFF777782),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              p.totalQty.toStringAsFixed(0),
                              style: pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              PdfService.formatRupiah(p.totalSales),
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // ===== DETAIL TRANSAKSI =====
          _sectionTitle("DETAIL TRANSAKSI"),
          pw.SizedBox(height: 10),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: const PdfColor.fromInt(0xFFECECF0)),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                pw.Container(
                  color: const PdfColor.fromInt(0xFFF8FAFC),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text("Order", style: _headerStyle()),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text("Pembeli", style: _headerStyle()),
                      ),
                      pw.Expanded(
                        child: pw.Text("Tanggal", style: _headerStyle()),
                      ),
                      pw.Expanded(
                        child: pw.Text("Item", style: _headerStyle(), textAlign: pw.TextAlign.right),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text("Total", style: _headerStyle(), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                ),
                ...report.transactions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final t = entry.value;
                  final isEven = idx % 2 == 0;
                  return pw.Container(
                    color: isEven ? const PdfColor.fromInt(0xFFFAFAFB) : PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8,
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            t.orderNumber,
                            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            t.buyerName ?? "-",
                            style: pw.TextStyle(fontSize: 8.5),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            _formatDate(t.placedAt),
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            "${t.itemsCount}",
                            style: pw.TextStyle(fontSize: 8.5),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            PdfService.formatRupiah(t.grandTotal),
                            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Note
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFFFF8E1),
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFFD4A24C),
                width: 0.5,
              ),
            ),
            child: pw.Text(
              "Laporan ini digenerate otomatis dari sistem NUSA-DHIPA Marketplace. "
              "Data bersifat real-time sesuai transaksi yang tercatat.",
              style: pw.TextStyle(
                fontSize: 8,
                color: const PdfColor.fromInt(0xFF9C7220),
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.TextStyle _headerStyle() => pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: const PdfColor.fromInt(0xFF19191D),
      );

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: PdfColor.fromInt(0xFFE5232E),
            width: 4,
          ),
        ),
      ),
      padding: const pw.EdgeInsets.only(left: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF19191D),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static pw.Widget _summaryBox(String label, String value, {bool big = false, bool small = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: small ? 7 : 8,
            color: PdfColors.white,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: big ? 18 : 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return DateFormat("d MMM yyyy", "id_ID").format(dt);
  }
}