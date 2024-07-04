import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';
import 'add_edit_customer_page.dart';

class ManageCustomersPage extends StatefulWidget {
  @override
  _ManageCustomersPageState createState() => _ManageCustomersPageState();
}

class _ManageCustomersPageState extends State<ManageCustomersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CustomerService _customerService = CustomerService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Customer>>(
              stream: _customerService.getCustomers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final customers = snapshot.data!;
                final filteredCustomers = customers.where((customer) {
                  return customer.name.toLowerCase().contains(_searchQuery) ||
                      customer.location.toLowerCase().contains(_searchQuery) ||
                      customer.position.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle:
                          Text('${customer.location}, ${customer.position}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
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
                                _customerService.deleteCustomer(customer.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
