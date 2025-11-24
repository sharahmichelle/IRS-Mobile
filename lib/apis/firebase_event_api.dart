// about roles 

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseEventAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllEvents() {
    return db.collection("events").snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getEventById(String id) {
    return FirebaseFirestore.instance.collection('events').doc(id).get();
  }

  Future<String> addEvent(Map<String, dynamic> event) async {
    try {
      DocumentReference docRef = db.collection("events").doc();
      
      event['eventId'] = docRef.id;
      
      await docRef.set(event);
      
      return "Successfully added event with ID: ${docRef.id}!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    }
  }

  Future<void> updateStatusByDate(String id)  async {
    await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(db.collection('events').doc(id));

        if (!snapshot.exists) throw Exception("Event does not exist!");

        if (snapshot['status'] == "Ongoing" && DateTime.now().isAfter((snapshot['endDate'] as Timestamp).toDate())) {
          transaction.update(db.collection('events').doc(id), {
            'status': 'Completed',
          });
        } else if(snapshot['status'] == "Not Started" && DateTime.now().isAfter((snapshot['startDate'] as Timestamp).toDate()) && DateTime.now().isBefore((snapshot['endDate'] as Timestamp).toDate())) {
          transaction.update(db.collection('events').doc(id), {
            'status': 'Ongoing',
          });
        }
      });
  }

  Future<String> deleteEvent(String? id) async {
    try {
      await db.collection("events").doc(id).delete();
      return "Successfully deleted event!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> editEvent(String? id, Map<String, dynamic> edit) async {
    try {
      await db.collection("events").doc(id).update(edit);
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
      await db.collection("events").doc(id).update({
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
        final snapshot = await transaction.get(db.collection('events').doc(id));

        if (!snapshot.exists) throw Exception("Event does not exist!");

        if (snapshot['receivedData'] >= snapshot['expectedData']) {
          transaction.update(db.collection('events').doc(id), {
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
