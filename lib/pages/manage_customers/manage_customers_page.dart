import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';
import 'add_edit_customer_page.dart';

class ManageCustomersPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CustomerService _customerService = CustomerService();

  Customer? customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Customers'),
      ),
      body: StreamBuilder<List<Customer>>(
        stream: _customerService.getCustomers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data!;

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              customer = customers[index];
              return ListTile(
                title: Text(customer!.name),
                subtitle: Text('${customer!.location}, ${customer!.position}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // pass customer object to next page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditCustomerPage(customer: customer),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () =>
                          _customerService.deleteCustomer(customer!.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // pass customer object to next page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCustomerPage(customer: null),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
