// about roles 

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseActivityLogAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllActivityLogs() {
    return db.collection("activity-logs").snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getActivityLogById(String id) {
    return FirebaseFirestore.instance.collection('activity-logs').doc(id).get();
  }

  Future<String> addActivityLog(Map<String, dynamic> activityLog) async {
    try {
      await db.collection("activity-logs").add(activityLog);
      return "Successfully added activity log!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<void> updateStatusByDate (String id)  async {
    await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(db.collection('activity-logs').doc(id));

        if (!snapshot.exists) throw Exception("ActivityLog does not exist!");

        if (snapshot['status'] == "Ongoing" && DateTime.now().isAfter((snapshot['endDate'] as Timestamp).toDate())) {
          transaction.update(db.collection('activity-logs').doc(id), {
            'status': 'Completed',
          });
        } else if(snapshot['status'] == "Not Started" && DateTime.now().isAfter((snapshot['startDate'] as Timestamp).toDate()) && DateTime.now().isBefore((snapshot['endDate'] as Timestamp).toDate())) {
          transaction.update(db.collection('activity-logs').doc(id), {
            'status': 'Ongoing',
          });
        }
      });
  }

  Future<String> deleteActivityLog(String? id) async {
    try {
      await db.collection("activity-logs").doc(id).delete();
      return "Successfully deleted activity log!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> editActivityLog(String? id, Map<String, dynamic> edit) async {
    try {
      await db.collection("activity-logs").doc(id).update(edit);
      return "Successfully edited activity log!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }
}
