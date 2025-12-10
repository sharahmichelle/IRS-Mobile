import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseEventTotalAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllEventTotals() {
    return db.collection("event-totals").snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getEventTotalById(String id) {
    return FirebaseFirestore.instance.collection('event-totals').doc(id).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getEventTotalByEventId(
    String id,
  ) {
    return db.collection('event-totals').where('eventId', isEqualTo: id).get();
  }

  Future<String> addEventTotal(Map<String, dynamic> eventTotal) async {
    try {
      await db.collection("event-totals").add(eventTotal);
      return "Successfully added event totals!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteEventTotal(String? id) async {
    try {
      await db.collection("event-totals").doc(id).delete();
      return "Successfully deleted event total!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> editEventTotal(String? id, Map<String, dynamic> edit) async {
    try {
      await db.collection("event-totals").doc(id).update(edit);
      return "Successfully edited event total!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> addReport(
    String reportId,
    String upSystem,
    String eventId, // Change parameter name to clarify it's eventId, not docId
    Map<String, int> data,
  ) async {
    try {
      // First, find the event total document by eventId
      final querySnapshot = await db
          .collection("event-totals")
          .where(
            'eventId',
            isEqualTo: eventId,
          ) // Assuming you have eventId field
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return "No event total found for event ID: $eventId";
      }

      final docId = querySnapshot.docs.first.id;

      await db.collection("event-totals").doc(docId).update({
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
        'totalDistribution.$upSystem': FieldValue.increment(
          data.values.fold<int>(0, (prev, value) => prev + (value ?? 0)),
        ),
      });

      await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(
          db.collection('event-totals').doc(docId),
        );

        if (!snapshot.exists) throw Exception("Event does not exist!");

        if (snapshot['receivedData'] >= snapshot['expectedData']) {
          transaction.update(db.collection('event-totals').doc(docId), {
            'status': 'Completed',
          });
        }
      });

      return "Report added successfully to event: $eventId";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }
}
