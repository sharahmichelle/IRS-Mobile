// lib/providers/reports_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/firebase_report_api.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';

class Reports with ChangeNotifier {
  late final FirebaseReportAPI firebaseService;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream;

  Reports() {
    firebaseService = FirebaseReportAPI();
    fetchReports();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get reports => _reportsStream;

  void fetchReports() {
    _reportsStream = firebaseService.getAllReports().cast<QuerySnapshot<Map<String, dynamic>>>();
    notifyListeners();
  }

  Future<String> addReport(Report report) async {
    final message = await firebaseService.addReport(report.toJson());
    debugPrint(message);
    notifyListeners();
    return message;
  }

  Future<void> editReport(String id, Map<String, dynamic> edit) async {
    final message = await firebaseService.editReport(id, edit);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> deleteReport(String id) async {
    final message = await firebaseService.deleteReport(id);
    debugPrint(message);
    notifyListeners();
  }

  Future<Report> getReportById(String id) async {
    // firebaseService.fetchReportById already returns a Report, so return it directly.
    final report = await firebaseService.fetchReportById(id);
    return report;
  }
}