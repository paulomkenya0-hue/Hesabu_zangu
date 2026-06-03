import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../services/hive_service.dart';

class ExcelService {
  static final HiveService _hive = HiveService();

  static String _fmt(double amount) {
    final f = NumberFormat('#,###', 'en_US');
    return 'Sh. ${f.format(amount)}';
  }

  static String _fmtDate(DateTime d) =>
      DateFormat('dd/MM/yyyy').format(d);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // GENERATE EXCEL MONTHLY REPORT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static Future<String?> generateMonthlyExcel(
    BuildContext context,
    int month,
    int year,
  ) async {
    try {
      final excel = Excel.createExcel();
      final monthName =
          DateFormat('MMMM_yyyy').format(DateTime(year, month));
      final monthNameDisplay =
          DateFormat('MMMM yyyy').format(DateTime(year, month));
      final userName = _hive.getUserName();

      // ━━━ SHEET 1: REKODI ZOTE ━━━
      final Sheet sheet1 = excel['Rekodi Zote'];
      excel.setDefaultSheet('Rekodi Zote');

      // Styles
      final CellStyle headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#1B5E20'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
      );

      final CellStyle incomeStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#1B5E20'),
        bold: true,
      );

      final CellStyle expenseStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#C62828'),
        bold: true,
      );

      final CellStyle titleStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
        bold: true,
        fontSize: 14,
      );

      final CellStyle subTitleStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#616161'),
        fontSize: 10,
      );

      final CellStyle totalStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F5F5F5'),
        bold: true,
        fontSize: 11,
      );

      // ── Title rows ──
      _setCell(sheet1, 0, 0, 'HESABU ZANGU — RIPOTI YA MAPATO NA MATUMIZI',
          style: titleStyle);
      _setCell(sheet1, 1, 0, 'Mtumiaji: $userName   |   Mwezi: $monthNameDisplay   |   Tarehe: ${_fmtDate(DateTime.now())}',
          style: subTitleStyle);
      _setCell(sheet1, 2, 0, '');

      // ── Summary row ──
      final income = _hive.getMonthIncome(month, year);
      final expense = _hive.getMonthExpense(month, year);
      final balance = income - expense;

      _setCell(sheet1, 3, 0, 'MAPATO YOTE:', style: headerStyle);
      _setCell(sheet1, 3, 1, _fmt(income), style: incomeStyle);
      _setCell(sheet1, 3, 2, 'MATUMIZI YOTE:', style: headerStyle);
      _setCell(sheet1, 3, 3, _fmt(expense), style: expenseStyle);
      _setCell(sheet1, 3, 4,
          balance >= 0 ? 'FAIDA:' : 'HASARA:', style: headerStyle);
      _setCell(sheet1, 3, 5, _fmt(balance.abs()),
          style: balance >= 0 ? incomeStyle : expenseStyle);

      _setCell(sheet1, 4, 0, '');

      // ── Table Headers ──
      final headers = [
        'TAREHE',
        'AINA',
        'KATEGORIA',
        'MAELEZO',
        'MAPATO (Sh.)',
        'MATUMIZI (Sh.)',
      ];
      for (var i = 0; i < headers.length; i++) {
        _setCell(sheet1, 5, i, headers[i], style: headerStyle);
      }

      // Column widths
      sheet1.setColumnWidth(0, 14);
      sheet1.setColumnWidth(1, 12);
      sheet1.setColumnWidth(2, 22);
      sheet1.setColumnWidth(3, 28);
      sheet1.setColumnWidth(4, 18);
      sheet1.setColumnWidth(5, 18);

      // ── Transaction Rows ──
      final transactions = _hive.getMonthTransactions(month, year);
      var rowIndex = 6;
      double totalIncome = 0;
      double totalExpense = 0;

      for (var t in transactions) {
        final isIncome = t.isIncome;
        final rowStyle = CellStyle(
          backgroundColorHex: rowIndex % 2 == 0
              ? ExcelColor.fromHexString('#F9F9F9')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

        _setCell(sheet1, rowIndex, 0, _fmtDate(t.date),
            style: rowStyle);
        _setCell(
            sheet1, rowIndex, 1, isIncome ? 'Mapato' : 'Matumizi',
            style: CellStyle(
              fontColorHex: isIncome
                  ? ExcelColor.fromHexString('#1B5E20')
                  : ExcelColor.fromHexString('#C62828'),
              backgroundColorHex: rowIndex % 2 == 0
                  ? ExcelColor.fromHexString('#F9F9F9')
                  : ExcelColor.fromHexString('#FFFFFF'),
            ));
        _setCell(sheet1, rowIndex, 2,
            '${t.categoryIcon} ${t.category}',
            style: rowStyle);
        _setCell(
            sheet1, rowIndex, 3, t.note.isEmpty ? '—' : t.note,
            style: rowStyle);

        if (isIncome) {
          _setCell(sheet1, rowIndex, 4, t.amount,
              style: incomeStyle);
          _setCell(sheet1, rowIndex, 5, '—', style: rowStyle);
          totalIncome += t.amount;
        } else {
          _setCell(sheet1, rowIndex, 4, '—', style: rowStyle);
          _setCell(sheet1, rowIndex, 5, t.amount,
              style: expenseStyle);
          totalExpense += t.amount;
        }

        rowIndex++;
      }

      // ── Totals Row ──
      _setCell(sheet1, rowIndex, 0, 'JUMLA', style: totalStyle);
      _setCell(sheet1, rowIndex, 1, '', style: totalStyle);
      _setCell(sheet1, rowIndex, 2, '', style: totalStyle);
      _setCell(sheet1, rowIndex, 3,
          '${transactions.length} rekodi', style: totalStyle);
      _setCell(sheet1, rowIndex, 4, totalIncome,
          style: CellStyle(
            bold: true,
            fontColorHex: ExcelColor.fromHexString('#1B5E20'),
            backgroundColorHex:
                ExcelColor.fromHexString('#E8F5E9'),
          ));
      _setCell(sheet1, rowIndex, 5, totalExpense,
          style: CellStyle(
            bold: true,
            fontColorHex: ExcelColor.fromHexString('#C62828'),
            backgroundColorHex:
                ExcelColor.fromHexString('#FFEBEE'),
          ));

      // ━━━ SHEET 2: MATUMIZI KWA AINA ━━━
      final Sheet sheet2 = excel['Matumizi kwa Aina'];

      _setCell(sheet2, 0, 0, 'MATUMIZI KWA AINA — $monthNameDisplay',
          style: titleStyle);
      _setCell(sheet2, 1, 0, '');

      final catHeaders = ['AINA', 'JUMLA (Sh.)', 'ASILIMIA (%)'];
      for (var i = 0; i < catHeaders.length; i++) {
        _setCell(sheet2, 2, i, catHeaders[i], style: headerStyle);
      }
      sheet2.setColumnWidth(0, 28);
      sheet2.setColumnWidth(1, 18);
      sheet2.setColumnWidth(2, 16);

      final categoryData = _hive.getExpenseByCategory(month, year);
      final sorted = categoryData.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      var catRow = 3;
      for (var e in sorted) {
        final pct = expense > 0
            ? (e.value / expense * 100).toStringAsFixed(1)
            : '0.0';
        final rowStyle = CellStyle(
          backgroundColorHex: catRow % 2 == 0
              ? ExcelColor.fromHexString('#FFF5F5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );
        _setCell(sheet2, catRow, 0, e.key, style: rowStyle);
        _setCell(sheet2, catRow, 1, e.value, style: expenseStyle);
        _setCell(sheet2, catRow, 2, '$pct%', style: rowStyle);
        catRow++;
      }

      // Totals
      _setCell(sheet2, catRow, 0, 'JUMLA', style: totalStyle);
      _setCell(sheet2, catRow, 1, expense,
          style: CellStyle(
              bold: true,
              fontColorHex:
                  ExcelColor.fromHexString('#C62828'),
              backgroundColorHex:
                  ExcelColor.fromHexString('#FFEBEE')));
      _setCell(sheet2, catRow, 2, '100%', style: totalStyle);

      // ━━━ SHEET 3: MUHTASARI ━━━
      final Sheet sheet3 = excel['Muhtasari'];

      final summaryItems = [
        ['HESABU ZANGU — MUHTASARI', ''],
        ['Mtumiaji', userName],
        ['Mwezi', monthNameDisplay],
        ['Tarehe ya Ripoti', _fmtDate(DateTime.now())],
        ['', ''],
        ['MAPATO YOTE', _fmt(income)],
        ['MATUMIZI YOTE', _fmt(expense)],
        [balance >= 0 ? 'FAIDA' : 'HASARA', _fmt(balance.abs())],
        ['', ''],
        ['Idadi ya Rekodi', '${transactions.length}'],
        [
          'Mapato ya Rekodi',
          '${transactions.where((t) => t.isIncome).length}'
        ],
        [
          'Matumizi ya Rekodi',
          '${transactions.where((t) => t.isExpense).length}'
        ],
      ];

      sheet3.setColumnWidth(0, 24);
      sheet3.setColumnWidth(1, 20);

      for (var i = 0; i < summaryItems.length; i++) {
        final isHeader = i == 0 || i == 5 || i == 9;
        _setCell(sheet3, i, 0, summaryItems[i][0],
            style: isHeader ? headerStyle : null);
        _setCell(sheet3, i, 1, summaryItems[i][1],
            style: isHeader ? headerStyle : null);
      }

      // ━━━ DELETE DEFAULT SHEET ━━━
      excel.delete('Sheet1');

      // ━━━ SAVE FILE ━━━
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'HesabuZangu_$monthName.xlsx';
      final file = File('${dir.path}/$fileName');
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await OpenFile.open(file.path);
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Excel Error: $e');
      return null;
    }
  }

  // ━━━ HELPER: SET CELL ━━━
  static void _setCell(
    Sheet sheet,
    int row,
    int col,
    dynamic value, {
    CellStyle? style,
  }) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    if (value is double || value is int) {
      cell.value = DoubleCellValue(value.toDouble());
    } else {
      cell.value = TextCellValue(value.toString());
    }
    if (style != null) cell.cellStyle = style;
  }
}
