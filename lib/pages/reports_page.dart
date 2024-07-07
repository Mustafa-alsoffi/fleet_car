import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../services/car_service.dart'; // Import the CarService
import '../../services/customer_service.dart'; // Import the CustomerService

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<File> _pdfReports = [];
  final CarService _carService = CarService();
  final CustomerService _customerService = CustomerService();

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

    // Fetch data from services
    final cars = await _carService.getAllCars();
    final customers = await _customerService.getAllCustomers();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Monthly Report', style: pw.TextStyle(fontSize: 40)),
              pw.SizedBox(height: 20),
              pw.Text('Cars:', style: pw.TextStyle(fontSize: 24)),
              ...cars.map(
                  (car) => pw.Text('${car.make} ${car.model} (${car.year})')),
              pw.SizedBox(height: 20),
              pw.Text('Customers:', style: pw.TextStyle(fontSize: 24)),
              ...customers.map((customer) =>
                  pw.Text('${customer.name} - ${customer.contactInfo}')),
            ],
          );
        },
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
            '${directory.path}/monthly_report_${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}_${DateTime.now().hour}:${DateTime.now().minute}.pdf');
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

  Future<void> _deleteReport(File report) async {
    try {
      await report.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report deleted: ${report.path}')),
      );
      _loadReports(); // Reload the reports list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting report: $e')),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a card explaining the purpose of the page and that these reports are generated monthly
          Container(
            width: 250,
            child: Card(
              color: Colors.blue[50],
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.info, color: Colors.blue),
                      ),
                      TextSpan(
                        text: '\n These reports are generated monthly.',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pdfReports.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_pdfReports[index].path.split('/').last),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteReport(_pdfReports[index]),
                  ),
                  onTap: () => OpenFile.open(_pdfReports[index].path),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        onPressed: _generatePdfAndSave,
        label: Text('Generate Report', style: TextStyle(fontSize: 12)),
        icon: Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
