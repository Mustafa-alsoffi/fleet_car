import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../manage_worklogs/add_edit_worklog_page.dart';
import 'add_edit_car_page.dart';

class ManageCarPage extends StatefulWidget {
  @override
  _ManageCarPageState createState() => _ManageCarPageState();
}

class _ManageCarPageState extends State<ManageCarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _deleteCar(String id) async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;
    await _firestore.collection('cars').doc(id).delete();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Car Record'),
          content: Text('Are you sure you want to delete this car record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Cars'),
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
            child: StreamBuilder(
              stream: _firestore.collection('cars').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final cars = snapshot.data!.docs.map((doc) {
                  return Car.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                final filteredCars = cars.where((car) {
                  return car.make.toLowerCase().contains(_searchQuery) ||
                      car.model.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredCars.length,
                  itemBuilder: (context, index) {
                    final car = filteredCars[index];
                    return ListTile(
                      title: Text(car.make),
                      subtitle: Text(car.model),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // add an icon button to add a work log
                          IconButton(
                            icon: Icon(Icons.list_alt),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditWorkLogPage(
                                    car: car,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditCarPage(car: car),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteCar(car.id),
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
              builder: (context) => AddEditCarPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
