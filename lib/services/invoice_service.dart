import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/business.dart';
import '../models/order_detail.dart';
import 'pdf_service.dart';

class InvoiceService {
  /// Generate Invoice PDF dari OrderDetail
  static Future<Uint8List> generateInvoice({
    required Business? business,
    required OrderDetail order,
  }) async {
    final doc = pw.Document(
      title: "Invoice ${order.orderNumber}",
      author: business?.legalName ?? "NUSA-DHIPA",
      subject: "Invoice untuk order ${order.orderNumber}",
    );

    final header = await PdfService.buildHeader(
      business: business,
      documentTitle: "Invoice",
      documentNumber: order.orderNumber,
      documentDate: PdfService.formatDate(DateTime.now()),
    );

    final footer = await PdfService.buildFooter(
      documentTitle: "Invoice",
    );

    final address = order.addressMap;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => header,
        footer: (_) => footer,
        build: (_) => [
          pw.SizedBox(height: 20),

          // ===== INFO PEMBELI & INVOICE =====
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kepada
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "KEPADA:",
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF777782),
                        letterSpacing: 1,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      order.buyerName,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      address["phone"]?.toString() ?? "-",
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: const PdfColor.fromInt(0xFF777782),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      address["address"]?.toString() ?? "-",
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: const PdfColor.fromInt(0xFF777782),
                      ),
                    ),
                    if (address["city"] != null)
                      pw.Text(
                        "${address["city"]}, ${address["province"] ?? ""} ${address["postal_code"] ?? ""}",
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: const PdfColor.fromInt(0xFF777782),
                        ),
                      ),
                  ],
                ),
              ),

              // Info Invoice
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _infoRow("Tanggal", PdfService.formatDate(order.placedAt)),
                    _infoRow("Status", order.statusLabel),
                    _infoRow(
                      "Jatuh Tempo",
                      PdfService.formatDate(
                        order.placedAt?.add(const Duration(days: 7)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // ===== TABEL ITEMS =====
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFFECECF0),
              ),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                // Header tabel
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [
                        PdfColor.fromInt(0xFFE5232E),
                        PdfColor.fromInt(0xFF98182A),
                      ],
                    ),
                    borderRadius: pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(6),
                      topRight: pw.Radius.circular(6),
                    ),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 24,
                        child: pw.Text(
                          "No",
                          style: _tableHeaderStyle(),
                        ),
                      ),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text("Deskripsi", style: _tableHeaderStyle()),
                      ),
                      pw.SizedBox(
                        width: 40,
                        child: pw.Text(
                          "Qty",
                          style: _tableHeaderStyle(),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          "Harga",
                          style: _tableHeaderStyle(),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.SizedBox(
                        width: 90,
                        child: pw.Text(
                          "Total",
                          style: _tableHeaderStyle(),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rows
                ...order.items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final isEven = idx % 2 == 0;

                  return pw.Container(
                    color: isEven
                        ? const PdfColor.fromInt(0xFFFAFAFB)
                        : PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                          width: 24,
                          child: pw.Text(
                            "$idx",
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.productName,
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              if (item.variantName.isNotEmpty)
                                pw.Text(
                                  item.variantName,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: const PdfColor.fromInt(0xFF777782),
                                  ),
                                ),
                              if (item.sku != null)
                                pw.Text(
                                  "SKU: ${item.sku}",
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    color: const PdfColor.fromInt(0xFF777782),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        pw.SizedBox(
                          width: 40,
                          child: pw.Text(
                            item.quantity.toStringAsFixed(0),
                            style: pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.SizedBox(
                          width: 80,
                          child: pw.Text(
                            PdfService.formatRupiah(item.unitPrice),
                            style: pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.SizedBox(
                          width: 90,
                          child: pw.Text(
                            PdfService.formatRupiah(item.lineTotal),
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Total rows
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(
                        color: PdfColor.fromInt(0xFFECECF0),
                      ),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    children: [
                      _totalRow(
                        "Subtotal",
                        PdfService.formatRupiah(order.subtotal),
                      ),
                      if (order.discountTotal > 0)
                        _totalRow(
                          "Diskon",
                          "- ${PdfService.formatRupiah(order.discountTotal)}",
                        ),
                      _totalRow(
                        "Ongkos Kirim",
                        PdfService.formatRupiah(order.shippingTotal),
                      ),
                      pw.Divider(color: const PdfColor.fromInt(0xFFE5232E)),
                      _totalRow(
                        "TOTAL",
                        PdfService.formatRupiah(order.grandTotal),
                        bold: true,
                        big: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // ===== TERBILANG =====
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFFFF8E1),
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFFD4A24C),
                width: 0.5,
              ),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  "Terbilang: ",
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF9C7220),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    PdfService.terbilang(order.grandTotal),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontStyle: pw.FontStyle.italic,
                      color: const PdfColor.fromInt(0xFF9C7220),
                    ),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ===== INFO PEMBAYARAN & TTD =====
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Pembayaran
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF8FAFC),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFE5E9F0),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "PEMBAYARAN",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFFE5232E),
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        "Transfer ke:",
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: const PdfColor.fromInt(0xFF777782),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        kBankName,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "No. Rek: $kBankAccount",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFFE5232E),
                        ),
                      ),
                      pw.Text(
                        "a/n $kBankHolder",
                        style: pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 16),

              // Tanda tangan
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "Hormat kami,",
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 50),
                    pw.Container(
                      width: 160,
                      padding: const pw.EdgeInsets.only(top: 4),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                            color: PdfColor.fromInt(0xFF19191D),
                          ),
                        ),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            business?.legalName ?? "Pemilik Usaha",
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            "Direktur",
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: const PdfColor.fromInt(0xFF777782),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (order.customerNote != null) ...[
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFFF8E1),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Catatan:",
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    order.customerNote!,
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.TextStyle _tableHeaderStyle() => pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      );

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            "$label: ",
            style: pw.TextStyle(
              fontSize: 9,
              color: const PdfColor.fromInt(0xFF777782),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value, {
    bool bold = false,
    bool big = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: big ? 12 : 9,
              fontWeight:
                  bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: big
                  ? const PdfColor.fromInt(0xFFE5232E)
                  : const PdfColor.fromInt(0xFF19191D),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: big ? 12 : 9,
              fontWeight:
                  bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: big
                  ? const PdfColor.fromInt(0xFFE5232E)
                  : const PdfColor.fromInt(0xFF19191D),
            ),
          ),
        ],
      ),
    );
  }
}