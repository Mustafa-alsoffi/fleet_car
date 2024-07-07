import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  String id;
  String availabilityStatus;
  String carId;
  String conditionStatus;
  List<String> customerIds;
  String licensePlate;
  String make;
  int mileage;
  String model;
  String picture;
  int year;
  // add created on and updated on fields
  String createdOn;
  String? updatedOn;

  Car({
    required this.id,
    this.availabilityStatus = 'unavailable',
    required this.carId,
    this.conditionStatus = 'red',
    required this.customerIds,
    this.licensePlate = '',
    this.make = '',
    this.mileage = 0,
    this.model = '',
    this.picture = '',
    this.year = 0,
    this.createdOn = '',
    this.updatedOn = '',
  });

  factory Car.fromMap(Map<String, dynamic> data, String documentId) {
    return Car(
      id: documentId,
      availabilityStatus: data['availabilityStatus'],
      carId: data['carId'],
      conditionStatus: data['conditionStatus'],
      customerIds: List<String>.from(data['customerIds']),
      licensePlate: data['licensePlate'],
      make: data['make'] ?? '',
      mileage: data['mileage'] ?? 0,
      model: data['model'],
      picture: data['picture'],
      year: data['year'],
      createdOn: data['createdOn'] ?? DateTime.now().toString(),
      updatedOn: data['updatedOn'] ?? DateTime.now().toString(),
    );
  }

  factory Car.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Car(
      id: doc.id,
      make: doc['make'],
      model: doc['model'],
      carId: doc['carId'],
      picture: doc['picture'],
      year: doc['year'],
      mileage: doc['mileage'],
      licensePlate: doc['licensePlate'],
      availabilityStatus: doc['availabilityStatus'],
      conditionStatus: doc['conditionStatus'],
      customerIds: List<String>.from(doc['customerIds']),
      createdOn: doc['createdOn'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'availabilityStatus': availabilityStatus,
      'carId': carId,
      'conditionStatus': conditionStatus,
      'customerIds': customerIds,
      'licensePlate': licensePlate,
      'make': make,
      'mileage': mileage,
      'model': model,
      'picture': picture,
      'year': year,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
    };
  }
}
