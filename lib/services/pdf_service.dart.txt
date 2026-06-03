import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';

class PdfService {
  static final HiveService _hive = HiveService();

  // ━━━ FORMAT AMOUNT ━━━
  static String _fmt(double amount) {
    final f = NumberFormat('#,###', 'en_US');
    return 'Sh. ${f.format(amount)}';
  }

  // ━━━ FORMAT DATE ━━━
  static String _fmtDate(DateTime d) =>
      DateFormat('dd/MM/yyyy').format(d);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // GENERATE MONTHLY PDF REPORT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static Future<String?> generateMonthlyReport(
    BuildContext context,
    int month,
    int year,
  ) async {
    try {
      final pdf = pw.Document();

      // Data
      final userName = _hive.getUserName();
      final transactions = _hive.getMonthTransactions(month, year);
      final income = _hive.getMonthIncome(month, year);
      final expense = _hive.getMonthExpense(month, year);
      final balance = income - expense;
      final categoryData = _hive.getExpenseByCategory(month, year);
      final monthName = DateFormat('MMMM yyyy').format(
        DateTime(year, month),
      );

      // Colors
      final green = PdfColor.fromHex('#1B5E20');
      final lightGreen = PdfColor.fromHex('#E8F5E9');
      final red = PdfColor.fromHex('#C62828');
      final lightRed = PdfColor.fromHex('#FFEBEE');
      final grey = PdfColor.fromHex('#616161');
      final lightGrey = PdfColor.fromHex('#F5F5F5');
      final white = PdfColors.white;
      final black = PdfColor.fromHex('#212121');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => [
            // ━━━ HEADER ━━━
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: green,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'HESABU ZANGU',
                        style: pw.TextStyle(
                          color: white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Ripoti ya Mapato na Matumizi',
                        style: pw.TextStyle(color: white, fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        monthName,
                        style: pw.TextStyle(
                          color: white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Mtumiaji: $userName',
                        style: pw.TextStyle(color: white, fontSize: 11),
                      ),
                      pw.Text(
                        'Tarehe: ${_fmtDate(DateTime.now())}',
                        style: pw.TextStyle(color: white, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ━━━ SUMMARY BOXES ━━━
            pw.Row(
              children: [
                // Mapato
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: lightGreen,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(
                          color: green.shade(0.3), width: 1),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('MAPATO YOTE',
                            style: pw.TextStyle(
                                color: green,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text(_fmt(income),
                            style: pw.TextStyle(
                                color: green,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                // Matumizi
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: lightRed,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(
                          color: red.shade(0.3), width: 1),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('MATUMIZI YOTE',
                            style: pw.TextStyle(
                                color: red,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text(_fmt(expense),
                            style: pw.TextStyle(
                                color: red,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                // Salio
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: balance >= 0 ? lightGreen : lightRed,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(
                          color: balance >= 0
                              ? green.shade(0.3)
                              : red.shade(0.3),
                          width: 1),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            balance >= 0 ? 'FAIDA ✓' : 'HASARA ✗',
                            style: pw.TextStyle(
                                color:
                                    balance >= 0 ? green : red,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text(_fmt(balance.abs()),
                            style: pw.TextStyle(
                                color:
                                    balance >= 0 ? green : red,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            // ━━━ TRANSACTIONS TABLE ━━━
            pw.Text(
              'ORODHA YA REKODI ZOTE',
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: black),
            ),
            pw.SizedBox(height: 8),

            // Table header
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: pw.BoxDecoration(color: green),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('TAREHE',
                          style: pw.TextStyle(
                              color: white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('AINA',
                          style: pw.TextStyle(
                              color: white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('MAELEZO',
                          style: pw.TextStyle(
                              color: white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('MAPATO',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              color: white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('MATUMIZI',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              color: white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold))),
                ],
              ),
            ),

            // Table rows
            ...transactions.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              final isEven = i % 2 == 0;
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: isEven ? lightGrey : white,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(_fmtDate(t.date),
                            style: pw.TextStyle(
                                fontSize: 9, color: grey))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                            '${t.categoryIcon} ${t.category}',
                            style: pw.TextStyle(
                                fontSize: 9, color: black))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                            t.note.isEmpty ? '—' : t.note,
                            style: pw.TextStyle(
                                fontSize: 9, color: grey))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            t.isIncome ? _fmt(t.amount) : '—',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9,
                                color: green,
                                fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            t.isExpense ? _fmt(t.amount) : '—',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9,
                                color: red,
                                fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              );
            }),

            // Table footer
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: pw.BoxDecoration(color: lightGrey),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 8,
                      child: pw.Text('JUMLA',
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: black))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(_fmt(income),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: green,
                              fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(_fmt(expense),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: red,
                              fontWeight: pw.FontWeight.bold))),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // ━━━ CATEGORY BREAKDOWN ━━━
            if (categoryData.isNotEmpty) ...[
              pw.Text(
                'MATUMIZI KWA AINA',
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: black),
              ),
              pw.SizedBox(height: 8),
              ...categoryData.entries
                  .toList()
                  .sorted((a, b) => b.value.compareTo(a.value))
                  .map((e) {
                final pct = expense > 0
                    ? (e.value / expense * 100).toStringAsFixed(1)
                    : '0';
                return pw.Container(
                  margin:
                      const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: lightRed,
                    borderRadius:
                        pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                          child: pw.Text(e.key,
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  color: black))),
                      pw.Text('$pct%',
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: grey)),
                      pw.SizedBox(width: 16),
                      pw.Text(_fmt(e.value),
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: red,
                              fontWeight:
                                  pw.FontWeight.bold)),
                    ],
                  ),
                );
              }),
            ],

            pw.SizedBox(height: 24),

            // ━━━ FOOTER ━━━
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Hesabu Zangu — Imetengenezwa Tanzania 🇹🇿 | ${_fmtDate(DateTime.now())}',
                style: pw.TextStyle(fontSize: 9, color: grey),
              ),
            ),
          ],
        ),
      );

      // ━━━ SAVE FILE ━━━
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'HesabuZangu_${monthName.replaceAll(' ', '_')}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Open file
      await OpenFile.open(file.path);

      return file.path;
    } catch (e) {
      debugPrint('PDF Error: $e');
      return null;
    }
  }
}

// Helper extension
extension ListSorted<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) {
    final copy = [...this];
    copy.sort(compare);
    return copy;
  }
}
