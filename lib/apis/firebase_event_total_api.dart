import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseEventTotalAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllEventTotals() {
    return db.collection("event-totals").snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getEventTotalById(String id) {
    return FirebaseFirestore.instance.collection('event-totals').doc(id).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getEventTotalByEventId(String id) {
    return db.collection('event-totals').where('eventID', isEqualTo: id).get();
  }

  Future<String> addEventTotal(Map<String, dynamic> eventTotal) async {
    try {
      await db.collection("event-totals").add(eventTotal);
      return "Successfully added activity log!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteEventTotal(String? id) async {
    try {
      await db.collection("event-totals").doc(id).delete();
      return "Successfully deleted event!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> editEventTotal(String? id, Map<String, dynamic> edit) async {
    try {
      await db.collection("event-totals").doc(id).update(edit);
      return "Successfully edited event!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> addReport(
    String reportId,
    String upSystem,
    String id,
    Map<String, int> data,
  ) async {
    try {
      await db.collection("event-totals").doc(id).update({
        'reportsId': FieldValue.arrayUnion([reportId]),
        'receivedData': FieldValue.increment(1),
        'totalFaculty': FieldValue.increment(data['headCountFaculty'] ?? 0),
        'totalAdminMembers': FieldValue.increment(
          data['headCountadminMember'] ?? 0,
        ),
        'totalRepsMembers': FieldValue.increment(
          data['headCountRepsMember'] ?? 0,
        ),
        'totalCustodians': FieldValue.increment(
          data['headCountCustodian'] ?? 0,
        ),
        'totalJoCosMembers': FieldValue.increment(
          data['headCountJoCosMember'] ?? 0,
        ),
        'totalStudents': FieldValue.increment(data['headCountStudent'] ?? 0),
        'totalSecurity': FieldValue.increment(data['headCountSecurity'] ?? 0),
        'totalConstructionWorkers': FieldValue.increment(
          data['headCountConstructionWorker'] ?? 0,
        ),
        'totalHealthWorkers': FieldValue.increment(
          data['headCountHealthWorker'] ?? 0,
        ),
        'totalGuests': FieldValue.increment(data['headCountGuest'] ?? 0),
        'totalPatients': FieldValue.increment(data['headCountPatient'] ?? 0),
        'totalCasualties': FieldValue.increment(data['numCasualty'] ?? 0),
        'totalMissingPersons': FieldValue.increment(
          data['numMissingPerson'] ?? 0,
        ),
        'totalDistribution.$upSystem': FieldValue.increment(data.values.reduce((a, b) => a + b)),
      });

      await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(db.collection('event-totals').doc(id));

        if (!snapshot.exists) throw Exception("Event does not exist!");

        if (snapshot['receivedData'] >= snapshot['expectedData']) {
          transaction.update(db.collection('event-totals').doc(id), {
            'status': 'Completed',
          });
        }
      });

      return "Report added";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }
}
