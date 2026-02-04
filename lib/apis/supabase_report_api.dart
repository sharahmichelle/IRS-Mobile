import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';

class SupabaseReportAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Report>> getAllReports() {
    return _supabase
        .from('reports')
        .stream(primaryKey: ['id'])
        .map<List<Report>>((data) => (data as List)
            .map((json) => Report.fromJson(Map<String, dynamic>.from(json)))
            .toList());
  }

  Future<Report> fetchReportById(String id) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('id', id)
          .single();

      if (response == null) {
        throw Exception("Report not found for id: $id");
      }

      return Report.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception("Report not found for id: $id. Error: $e");
    }
  }

  Future<String> addReport(Map<String, dynamic> reportData) async {
    try {
      debugPrint('[SupabaseReportAPI] Inserting report: $reportData');
      final response = await _supabase
          .from('reports')
          .insert(reportData)
          .select('id')
          .single();
      debugPrint('[SupabaseReportAPI] Insert response: $response');

      final id = response is Map ? response['id'] as String? : null;
      if (id == null) {
        throw Exception('Failed to add report: no id returned. Response: $response');
      }
      return id;
    } catch (e) {
      debugPrint('[SupabaseReportAPI] Insert failed: $e');
      // Propagate the exception so callers can handle failures explicitly
      throw Exception('Failed to add report: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      final response = await _supabase
          .from('reports')
          .delete()
          .eq('id', id);
      if (response == null) {
        throw Exception('Failed to delete report with id: $id');
      }
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  Future<void> editReport(String id, Map<String, dynamic> edit) async {
    try {
      final response = await _supabase
          .from('reports')
          .update(edit)
          .eq('id', id);
      if (response == null) {
        throw Exception('Failed to edit report with id: $id');
      }
    } catch (e) {
      throw Exception('Failed to edit report: $e');
    }
  }
}
