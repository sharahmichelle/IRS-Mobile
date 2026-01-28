// lib/providers/reports_provider.dart
import 'package:supabase_flutter/supabase_flutter.dart';
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
    final message = await supabaseService.addReport(report.toJson());
    debugPrint(message);
    notifyListeners();
    return message;
  }

  Future<void> editReport(String id, Map<String, dynamic> edit) async {
    final message = await supabaseService.editReport(id, edit);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> deleteReport(String id) async {
    final message = await supabaseService.deleteReport(id);
    debugPrint(message);
    notifyListeners();
  }

  Future<Report> getReportById(String id) async {
    final report = await supabaseService.fetchReportById(id);
    return report;
  }
}
