import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String id;
  String carId;
  String contactInfo;
  String location;
  String name;
  String position;

  Customer({
    required this.id,
    required this.carId,
    required this.contactInfo,
    required this.location,
    required this.name,
    required this.position,
  });

  factory Customer.fromMap(Map<String, dynamic> data, String documentId) {
    return Customer(
      id: documentId,
      carId: data['carId'],
      contactInfo: data['contactInfo'],
      location: data['location'],
      name: data['name'],
      position: data['position'],
    );
  }

  static Customer fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Customer.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'contactInfo': contactInfo,
      'location': location,
      'name': name,
      'position': position,
    };
  }
}
