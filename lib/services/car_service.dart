import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/car_model.dart';

class CarService {
  final CollectionReference _carsCollection =
      FirebaseFirestore.instance.collection('cars');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> createCar({
    required String carId,
    required String availabilityStatus,
    required String conditionStatus,
    required List<String> customerIds,
    required String licensePlate,
    required String make,
    required int mileage,
    required String model,
    required String picture,
    required int year,
    required String createdOn,
    required String updatedOn,
  }) async {
    try {
      await _carsCollection.doc(carId).set({
        'carId': carId,
        'availabilityStatus': availabilityStatus,
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
      });
      print('Car created successfully');
    } catch (e) {
      print('Error creating car: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCars() async {
    try {
      QuerySnapshot querySnapshot = await _carsCollection.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting cars: $e');
      return [];
    }
  }

  Future<List<Car>> getAllCars() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('cars').get();
      return querySnapshot.docs.map((doc) {
        return Car.fromDocumentSnapshot(doc);
      }).toList();
    } catch (e) {
      print('Error getting cars: $e');
      return [];
    }
  }

  Stream<List<Car>> getCarsStream() {
    return _carsCollection
        .orderBy('createdOn', descending: true)
        .limit(10)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) =>
                Car.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // add getCarById method
  Future<Car> getCarById(String carId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _carsCollection.doc(carId).get();
      return Car.fromMap(
          documentSnapshot.data() as Map<String, dynamic>, documentSnapshot.id);
    } catch (e) {
      print('Error getting car by id: $e');
      return Car(
        id: '',
        availabilityStatus: 'unavailable',
        carId: '',
        conditionStatus: 'red',
        customerIds: [],
        licensePlate: '',
        make: '',
        mileage: 0,
        model: '',
        picture: '',
        year: 0,
        createdOn: '',
        updatedOn: '',
      );
    }
  }

  // get the number of availabe cars using the status field
  Future<int> getAvailableCars() async {
    try {
      QuerySnapshot querySnapshot = await _carsCollection
          .where('availabilityStatus', isEqualTo: 'available')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting available cars: $e');
      return 0;
    }
  }

// update a car
  Future<void> updateCar({
    required String carId,
    required String availabilityStatus,
    required String conditionStatus,
    required List<String> customerIds,
    required String licensePlate,
    required String make,
    required int mileage,
    required String model,
    required String picture,
    required int year,
    required String updatedOn,
  }) async {
    try {
      await _carsCollection.doc(carId).update({
        'availabilityStatus': availabilityStatus,
        'conditionStatus': conditionStatus,
        'customerIds': customerIds,
        'licensePlate': licensePlate,
        'make': make,
        'mileage': mileage,
        'model': model,
        'picture': picture,
        'year': year,
        'updatedOn': updatedOn,
      });
      print('Car updated successfully');
    } catch (e) {
      print('Error updating car: $e');
    }
  }

  Future<void> deleteCar(String carId) async {
    try {
      await _carsCollection.doc(carId).delete();
      print('Car deleted successfully');
    } catch (e) {
      print('Error deleting car: $e');
    }
  }
}
