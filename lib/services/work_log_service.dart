import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/work_log_model.dart';

class WorkLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<WorkLog>> getWorkLogs() {
    return _firestore.collection('workLogs').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => WorkLog.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> createWorkLog(WorkLog workLog) async {
    await _firestore.collection('workLogs').add(workLog.toMap());
  }

  Future<void> updateWorkLog(WorkLog workLog) async {
    await _firestore
        .collection('workLogs')
        .doc(workLog.id)
        .update(workLog.toMap());
  }

  Future<void> deleteWorkLog(String id) async {
    await _firestore.collection('workLogs').doc(id).delete();
  }
}
