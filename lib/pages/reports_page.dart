import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<File> _pdfReports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final reportDir = Directory(directory.path);
        List<FileSystemEntity> files = reportDir.listSync();

        setState(() {
          _pdfReports = files
              .where((file) => file.path.endsWith('.pdf'))
              .map((file) => File(file.path))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reports: $e')),
      );
    }
  }

  Future<void> _generatePdfAndSave() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Monthly Report', style: pw.TextStyle(fontSize: 40)),
        ),
      ),
    );

    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final file = File(
            '${directory.path}/monthly_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to ${file.path}')),
        );

        _loadReports(); // Reload the reports list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access storage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating or saving PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _generatePdfAndSave,
            child: Text('Generate Monthly Report'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pdfReports.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_pdfReports[index].path.split('/').last),
                  onTap: () => OpenFile.open(_pdfReports[index].path),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
