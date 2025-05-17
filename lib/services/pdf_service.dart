import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/supply_report.dart';

class PDFService {
  static Future<File> generateSupplyReport(SupplyReport report, String reportMessage) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Supply Status Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Paragraph(text: reportMessage),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/supply_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('Could not open the file');
    }

    return file;
  }

  static pw.Widget _buildSection(String title, String content, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            content,
            style: pw.TextStyle(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSupplyTable(SupplyReport report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Supply', isHeader: true),
            _buildTableCell('Remaining', isHeader: true),
            _buildTableCell('Required', isHeader: true),
            _buildTableCell('Days Left', isHeader: true),
            _buildTableCell('Status', isHeader: true),
          ],
        ),
        // Data rows
        ...report.supplies.entries.map((entry) {
          final supply = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell(supply['name']),
              _buildTableCell(supply['remaining']),
              _buildTableCell(supply['required']),
              _buildTableCell(supply['days']),
              _buildTableCell(
                supply['status'],
                color: supply['status'] == 'Critical'
                    ? PdfColors.red
                    : supply['status'] == 'Low'
                        ? PdfColors.orange
                        : PdfColors.green,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildAIInsights(Map<String, dynamic> insights) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.blue),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'AI Analysis',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildInsightSection('Key Insights', insights['insights']),
              _buildInsightSection('Recommendations', insights['recommendations']),
              _buildInsightSection('Risk Assessment', insights['risks']),
              _buildInsightSection('Suggested Actions', insights['actions']),
              _buildInsightSection('Supply Chain Efficiency', insights['efficiency']),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInsightSection(String title, String content) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            content,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
          ),
        ],
      ),
    );
  }
} 