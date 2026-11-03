import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:nodara/core/utils/date_format.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/certificate.dart';

/// Usa fuentes incluidas en PDF para generar el archivo sin descargar recursos.
class HoursReportPdf {
  Future<Uint8List> generate(
    Certificate certificate,
    List<Application> applications,
  ) async {
    final document = pw.Document(
      title: 'Reporte de horas NODARA',
      author: 'NODARA',
    );
    final blue = PdfColor.fromInt(0xFF093DB2);
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'NODARA',
              style: pw.TextStyle(
                fontSize: 24,
                color: blue,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Reporte de horas de voluntariado',
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 18),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${certificate.codigo}  |  Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        build: (_) => [
          pw.Text('Voluntario: ${certificate.nombre}'),
          pw.SizedBox(height: 6),
          pw.Text('Fecha de emisión: ${fechaLarga(certificate.emitidoEn)}'),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Actividad',
              'Organización',
              'Finalización',
              'Horas',
            ],
            data: applications
                .map(
                  (item) => [
                    item.oportunidadTitulo,
                    item.orgNombre,
                    fechaLarga(item.actualizadaEn),
                    '${item.horasQueCuentan}',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(color: blue),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellPadding: const pw.EdgeInsets.all(8),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(.7),
            },
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Total acreditado: ${certificate.totalHoras} horas',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // El QR contiene el código real; no inventamos una web de validación.
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: certificate.codigo,
                width: 90,
                height: 90,
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Código de validación',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(certificate.codigo),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Escanea o copia el código y consúltalo en Perfil > Validar certificado de NODARA.',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Este reporte incluye únicamente actividades completadas y horas acreditadas por las organizaciones.',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
    return document.save();
  }
}
