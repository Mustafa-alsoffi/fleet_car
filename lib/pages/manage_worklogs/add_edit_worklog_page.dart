import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/car_model.dart';
import '../../models/work_log_model.dart';
import '../../services/work_log_service.dart';

class AddEditWorkLogPage extends StatefulWidget {
  final WorkLog? workLog;
  final Car car;

  AddEditWorkLogPage({this.workLog, required this.car});

  @override
  _AddEditWorkLogPageState createState() => _AddEditWorkLogPageState();
}

class _AddEditWorkLogPageState extends State<AddEditWorkLogPage> {
  final _formKey = GlobalKey<FormState>();
  final _workLogService = WorkLogService();

  late TextEditingController _carIdController;
  late TextEditingController _personInChargeController;
  late TextEditingController _workPerformedController;
  late TextEditingController _dateController;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _carIdController = TextEditingController(text: widget.car.id ?? '');
    _personInChargeController =
        TextEditingController(text: widget.workLog?.personInCharge ?? '');
    _workPerformedController =
        TextEditingController(text: widget.workLog?.workPerformed ?? '');
    _selectedDate = widget.workLog?.date ?? DateTime.now();
    _dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(_selectedDate!));
  }

  @override
  void dispose() {
    _carIdController.dispose();
    _personInChargeController.dispose();
    _workPerformedController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate!,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveWorkLog() {
    if (_formKey.currentState!.validate()) {
      final workLog = WorkLog(
        id: widget.workLog?.id ?? '',
        carId: widget.car.id ?? '', // Associate with car ID
        personInCharge: _personInChargeController.text,
        workPerformed: _workPerformedController.text,
        date: _selectedDate!,
      );

      if (widget.workLog == null) {
        _workLogService.createWorkLog(workLog);
      } else {
        _workLogService.updateWorkLog(workLog);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workLog == null ? 'Add Work Log' : 'Edit Work Log'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // add the necessary widgets to display the car details
              // add title that says 'Car Details'
              Text(
                'Car Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Image.network(widget.car.picture,
                  height: 200, width: 200, fit: BoxFit.cover),
              SizedBox(height: 10),
              Text('Maker:        ${widget.car.make}'),
              Text('Model:        ${widget.car.model}'),
              Text('Year:           ${widget.car.year}'),
              Text('Availability: ${widget.car.availabilityStatus}'),
              SizedBox(height: 20),
              // add a divider
              Divider(),
              SizedBox(height: 20),
              // add title that says 'Work Log Details'
              Text(
                'Work Log Form:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _personInChargeController,
                decoration: InputDecoration(labelText: 'Person In Charge'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Person In Charge';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _workPerformedController,
                decoration: InputDecoration(labelText: 'Work Performed'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Work Performed';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorkLog,
                child: Text(widget.workLog == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
