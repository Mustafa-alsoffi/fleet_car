import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import 'add_edit_car_page.dart';

class ManageCarPage extends StatefulWidget {
  @override
  _ManageCarPageState createState() => _ManageCarPageState();
}

class _ManageCarPageState extends State<ManageCarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addCar(Car car) async {
    await _firestore.collection('cars').add(car.toMap());
  }

  Future<void> _updateCar(Car car) async {
    await _firestore.collection('cars').doc(car.id).update(car.toMap());
  }

  Future<void> _deleteCar(String id) async {
    await _firestore.collection('cars').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    // add car variable to pass to AddEditCarPage
    Car? car;
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Cars'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('cars').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final cars = snapshot.data!.docs.map((doc) {
            return Car.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              car = cars[index];
              return ListTile(
                title: Text(car?.make ?? ''),
                subtitle: Text(car?.model ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Implement edit functionality
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditCarPage(car: cars[index]),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteCar(cars[index].id),
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
