import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _customerCollection =
      FirebaseFirestore.instance.collection('customers');

  Stream<List<Customer>> getCustomers() {
    // try first
    try {
      return _customerCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Customer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      // if there is an error, print it
      print('Error getting customers: $e');
      // return an empty list
      return Stream.value([]);
    }
  }

  Stream<List<Customer>> getCustomersByCarId(String carId) {
    return _firestore
        .collection('customers')
        .where('carId', isEqualTo: carId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  Future<void> createCustomer(Customer customer) async {
    await _customerCollection.add(customer.toMap());
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customerCollection.doc(customer.id).update(customer.toMap());
  }

  Future<void> deleteCustomer(String customerId) async {
    await _customerCollection.doc(customerId).delete();
  }
}
