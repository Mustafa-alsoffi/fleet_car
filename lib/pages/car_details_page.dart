import 'package:flutter/material.dart';

import '../models/car_model.dart';
import '../models/customer_model.dart';
import '../models/work_log_model.dart';
import '../services/customer_service.dart';
import '../services/work_log_service.dart';

class CarDetailsPage extends StatelessWidget {
  final Car car;
  final WorkLogService _workLogService = WorkLogService();
  final CustomerService _customerService = CustomerService();

  CarDetailsPage({required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${car.model} Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Image.network(car.picture,
                    height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Car Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Model: ${car.model}'),
                        Text('Make: ${car.make}'),
                        Text('Year: ${car.year}'),
                        Text('Mileage: ${car.mileage}'),
                        Text('Availability Status: ${car.availabilityStatus}'),
                        Text('Condition Status: ${car.conditionStatus}'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Work Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<List<WorkLog>>(
                stream: _workLogService.getWorkLogsByCarId(car.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No work logs found'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var workLog = snapshot.data![index];
                        return ListTile(
                          title: Text(workLog.workPerformed),
                          subtitle: Text(
                              'Person In Charge: ${workLog.personInCharge}\nDate: ${workLog.date}'),
                        );
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                'Associated Customers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<List<Customer>>(
                stream: _customerService.getCustomersByCarId(car.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No customers found'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var customer = snapshot.data![index];
                        return ListTile(
                          title: Text(customer.name),
                          subtitle: Text(
                              'Location: ${customer.location}\nPosition: ${customer.position}'),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
