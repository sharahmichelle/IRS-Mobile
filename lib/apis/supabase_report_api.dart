import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';

class SupabaseReportAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Report>> getAllReports() {
    return _supabase
        .from('reports')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => Report.fromJson(json)).toList());
  }

  Future<Report> fetchReportById(String id) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('id', id)
          .single();

      return Report.fromJson(response);
    } catch (e) {
      throw Exception("Report not found for id: $id");
    }
  }

  Future<String> addReport(Map<String, dynamic> reportData) async {
    try {
      final response = await _supabase
          .from('reports')
          .insert(reportData)
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> deleteReport(String id) async {
    try {
      await _supabase
          .from('reports')
          .delete()
          .eq('id', id);
      return "Successfully deleted Report!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> editReport(String id, Map<String, dynamic> edit) async {
    try {
      await _supabase
          .from('reports')
          .update(edit)
          .eq('id', id);
      return "Successfully edited Report!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }
}
