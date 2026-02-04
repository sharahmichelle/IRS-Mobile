// lib/providers/reports_provider.dart
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/supabase_report_api.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';

class Reports with ChangeNotifier {
  late final SupabaseReportAPI supabaseService;
  late Stream<List<Report>> _reportsStream;

  Reports() {
    supabaseService = SupabaseReportAPI();
    fetchReports();
  }

  Stream<List<Report>> get reports => _reportsStream;

  void fetchReports() {
    _reportsStream = supabaseService.getAllReports();
    notifyListeners();
  }

  Future<String> addReport(Report report) async {
    try {
      final id = await supabaseService.addReport(report.toJson());
      debugPrint('Added report id: $id');
      notifyListeners();
      return id;
    } catch (e) {
      debugPrint('Failed to add report: $e');
      rethrow;
    }
  }

  Future<void> editReport(String id, Map<String, dynamic> edit) async {
    try {
      await supabaseService.editReport(id, edit);
      debugPrint('Successfully edited report: $id');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to edit report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await supabaseService.deleteReport(id);
      debugPrint('Successfully deleted report: $id');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete report: $e');
      rethrow;
    }
  }

  Future<Report> getReportById(String id) async {
    final report = await supabaseService.fetchReportById(id);
    return report;
  }
}
