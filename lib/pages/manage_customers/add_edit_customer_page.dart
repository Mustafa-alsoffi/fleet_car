import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';

class AddEditCustomerPage extends StatefulWidget {
  final Customer? customer;

  AddEditCustomerPage({this.customer});

  @override
  _AddEditCustomerPageState createState() => _AddEditCustomerPageState();
}

class _AddEditCustomerPageState extends State<AddEditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactInfoController = TextEditingController();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _contactInfoController.text = widget.customer!.contactInfo;
      _locationController.text = widget.customer!.location;
      _nameController.text = widget.customer!.name;
      _positionController.text = widget.customer!.position;
    }
  }

  @override
  void dispose() {
    _contactInfoController.dispose();
    _locationController.dispose();
    _nameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id ?? '',
        contactInfo: _contactInfoController.text,
        location: _locationController.text,
        name: _nameController.text,
        position: _positionController.text,
      );

      if (widget.customer == null) {
        _customerService.createCustomer(customer);
      } else {
        _customerService.updateCustomer(customer);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _contactInfoController,
                decoration: InputDecoration(labelText: 'Contact Info'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact info';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Position'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter position';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
