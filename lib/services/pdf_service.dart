import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/business.dart';

/// Data bank tenant — sementara hardcode
const kBankName = "OCBC NISP";
const kBankAccount = "020678903331";
const kBankHolder = "PT Sauri Unggul Sejahtera";

class PdfService {
  static final _currency = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  static String formatRupiah(num value) => _currency.format(value);

  static String formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return DateFormat("d MMM yyyy", "id_ID").format(dt);
  }

  /// Load logo tenant dari asset
  static Future<Uint8List?> _loadTenantLogo() async {
    try {
      final bytes = await rootBundle.load("assets/branding/sauri_logo.png");
      return bytes.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Load logo platform NUSA-DHIPA
  static Future<Uint8List?> _loadPlatformLogo() async {
    try {
      final bytes =
          await rootBundle.load("assets/branding/logo_nusadhipa.png");
      return bytes.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Terbilang — konversi angka ke kata
  static String terbilang(num value) {
    final n = value.toInt();
    if (n == 0) return "nol rupiah";

    const satuan = [
      "", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh",
      "delapan", "sembilan", "sepuluh", "sebelas"
    ];

    String convert(int x) {
      if (x < 12) return satuan[x];
      if (x < 20) return "${convert(x - 10)} belas";
      if (x < 100) return "${convert(x ~/ 10)} puluh ${convert(x % 10)}".trim();
      if (x < 200) return "seratus ${convert(x - 100)}".trim();
      if (x < 1000) return "${convert(x ~/ 100)} ratus ${convert(x % 100)}".trim();
      if (x < 2000) return "seribu ${convert(x - 1000)}".trim();
      if (x < 1000000) return "${convert(x ~/ 1000)} ribu ${convert(x % 1000)}".trim();
      if (x < 1000000000) return "${convert(x ~/ 1000000)} juta ${convert(x % 1000000)}".trim();
      if (x < 1000000000000) {
        return "${convert(x ~/ 1000000000)} miliar ${convert(x % 1000000000)}".trim();
      }
      return "${convert(x ~/ 1000000000000)} triliun ${convert(x % 1000000000000)}".trim();
    }

    final kata = convert(n).replaceAll(RegExp(r"\s+"), " ").trim();
    return "${kata[0].toUpperCase()}${kata.substring(1)} rupiah";
  }

  /// Build header PDF — logo tenant + nama + info legal
  static Future<pw.Widget> buildHeader({
    required Business? business,
    required String documentTitle,
    required String documentNumber,
    required String documentDate,
  }) async {
    final logoBytes = await _loadTenantLogo();
    final logoImage = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    final businessName = business?.businessName ?? "Toko Saya";
    final legalName = business?.legalName ?? businessName;
    final address = business?.address ?? "-";
    final nib = business?.nib ?? "-";
    final npwp = business?.taxNumber ?? "-";

    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE5232E), width: 2),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo tenant
          if (logoImage != null)
            pw.Container(
              width: 70,
              height: 70,
              padding: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: const PdfColor.fromInt(0xFFE5232E),
                  width: 1.5,
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 70,
              height: 70,
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFFF0F1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  businessName.substring(0, 1).toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFFE5232E),
                  ),
                ),
              ),
            ),
          pw.SizedBox(width: 14),

          // Info business
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  legalName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF19191D),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  businessName,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: const PdfColor.fromInt(0xFF777782),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  address,
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: const PdfColor.fromInt(0xFF777782),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "NIB: $nib  ·  NPWP: $npwp",
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: const PdfColor.fromInt(0xFF777782),
                  ),
                ),
              ],
            ),
          ),

          // Dokumen info (kanan)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                documentTitle.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFFE5232E),
                  letterSpacing: 1.5,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFFFF0F1),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  documentNumber,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFFE5232E),
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                documentDate,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: const PdfColor.fromInt(0xFF777782),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build footer PDF — NUSA-DHIPA branding
  static Future<pw.Widget> buildFooter({
    required String documentTitle,
  }) async {
    final platformLogo = await _loadPlatformLogo();

    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFECECF0), width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            children: [
              if (platformLogo != null)
                pw.Container(
                  height: 14,
                  child: pw.Image(
                    pw.MemoryImage(platformLogo),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              pw.SizedBox(width: 6),
              pw.Text(
                "Powered by NUSA-DHIPA Marketplace",
                style: pw.TextStyle(
                  fontSize: 7.5,
                  color: const PdfColor.fromInt(0xFF777782),
                ),
              ),
            ],
          ),
          pw.Text(
            "Dokumen ini digenerate secara elektronik",
            style: pw.TextStyle(
              fontSize: 7,
              color: const PdfColor.fromInt(0xFF777782),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Preview PDF (buka print dialog / simpan)
  static Future<void> previewPdf({
    required Uint8List bytes,
    required String filename,
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: filename,
    );
  }

  /// Share PDF via WhatsApp/email/dll
  static Future<void> sharePdf({
    required Uint8List bytes,
    required String filename,
  }) async {
    // Simpan dulu ke temporary folder
    final dir = Directory.systemTemp;
    final file = File("${dir.path}/$filename");
    await file.writeAsBytes(bytes);

    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }
}