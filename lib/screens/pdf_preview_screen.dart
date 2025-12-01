import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';
import 'package:pdf/pdf.dart';

class PDFPreviewScreen extends StatelessWidget {
  final String name;
  final double roadmapProgress;
  final int feedbackAlerts;
  final double jobMatch;

  const PDFPreviewScreen({
    super.key,
    required this.name,
    required this.roadmapProgress,
    required this.feedbackAlerts,
    required this.jobMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📄 Career Report Preview')),
      body: PdfPreview(
        build: (format) => PDFService.generateCareerReport(
          name: name,
          roadmapProgress: roadmapProgress,
          feedbackAlerts: feedbackAlerts,
          jobMatch: jobMatch,
        ),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'career_report.pdf',
      ),
    );
  }
}
