import 'package:cloud_firestore/cloud_firestore.dart';

class WorkLog {
  final String id;
  final String carId;
  final String personInCharge;
  final String workPerformed;
  final DateTime date;

  WorkLog({
    required this.id,
    required this.carId,
    required this.personInCharge,
    required this.workPerformed,
    required this.date,
  });

  factory WorkLog.fromMap(Map<String, dynamic> data, String id) {
    return WorkLog(
      id: id,
      carId: data['carId'] ?? '',
      personInCharge: data['personInCharge'] ?? '',
      workPerformed: data['workPerformed'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'personInCharge': personInCharge,
      'workPerformed': workPerformed,
      'date': date,
    };
  }
}
