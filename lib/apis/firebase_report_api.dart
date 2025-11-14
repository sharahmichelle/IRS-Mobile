import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';

class FirebaseReportAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllReports() {
    return db.collection("reports").snapshots();
  }

  Future<Report> fetchReportById(String id) async {
    final doc = await db.collection("reports").doc(id).get();
    if (doc.exists) {
      return Report.fromFirestore(doc);
    } else {
      throw Exception("Report not found for id: $id");
    }
  }

  Future<String> addReport(Map<String, dynamic> reportData) async {
    try {
      final DocumentReference report = await db.collection("reports").add(reportData);
      return report.id;
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteReport(String? id) async {
    try {
      await db.collection("reports").doc(id).delete();
      return "Successfully deleted Report!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> editReport(String? id, Map<String, dynamic> edit) async {
    try {
      await db.collection("reports").doc(id).update(edit);
      return "Successfully edited Report!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }
}