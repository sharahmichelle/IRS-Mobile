import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEventTotalAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Add or update report data to event totals
  /// This aggregates report counts by event and cluster
  Future<Map<String, dynamic>> addReportToEventTotal({
    required String cluster,
    required Map<String, dynamic> data,
    required String eventId,
    required String reportId,
  }) async {
    try {
      print('[SupabaseEventTotalAPI] Adding report to event total');
      print('[SupabaseEventTotalAPI] Event ID: $eventId');
      print('[SupabaseEventTotalAPI] Report ID: $reportId');
      print('[SupabaseEventTotalAPI] Cluster: $cluster');
      print('[SupabaseEventTotalAPI] Data: $data');

      // Convert camelCase data to snake_case for the function
      final snakeCaseData = _convertToSnakeCase(data);
      print('[SupabaseEventTotalAPI] Converted data: $snakeCaseData');

      // Call the RPC function with snake_case parameter names
      final response = await _supabase.rpc(
        'add_report_to_event_total',
        params: {
          'p_cluster': cluster,
          'p_data': snakeCaseData,
          'p_event_id': eventId.toString(),      
          'p_report_id': reportId.toString(),    
        },
      );

      print('[SupabaseEventTotalAPI] RPC response: $response');

      if (response == null) {
        throw Exception('RPC function returned null');
      }

      // Check if the response indicates success
      if (response is Map && response['success'] == false) {
        throw Exception(
          'Function execution failed: ${response['error'] ?? 'Unknown error'}'
        );
      }

      return Map<String, dynamic>.from(response as Map);
    } on PostgrestException catch (e) {
      print('[SupabaseEventTotalAPI] PostgrestException:');
      print('  Message: ${e.message}');
      print('  Code: ${e.code}');
      print('  Details: ${e.details}');
      print('  Hint: ${e.hint}');
      
      // Provide helpful error messages
      if (e.code == 'PGRST202') {
        throw Exception(
          'The function add_report_to_event_total does not exist in Supabase. '
          'Please run the create_rpc_function.sql file in your Supabase SQL Editor.'
        );
      }
      
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('[SupabaseEventTotalAPI] RPC failed: $e');
      throw Exception('Failed to add report to event total: $e');
    }
  }

  /// Convert camelCase keys to snake_case for PostgreSQL
  Map<String, dynamic> _convertToSnakeCase(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    data.forEach((key, value) {
      // Convert camelCase to snake_case
      // Example: facultyMembers -> faculty_members
      String snakeKey = key.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      );

      // Special case mappings to match exact column names
      if (snakeKey == 'num_missing_person') {
        snakeKey = 'num_missing_persons';
      }
      if (snakeKey == 'num_casualty') {
        snakeKey = 'num_casualties';
      }
      if (snakeKey == 'head_count_faculty') {
        snakeKey = 'faculty_members';
      }
      if (snakeKey == 'head_countadmin_member') {
        snakeKey = 'admin_members';
      }
      if (snakeKey == 'head_count_reps_member') {
        snakeKey = 'reps_members';
      }
      if (snakeKey == 'head_count_r_a_member') {
        snakeKey = 'ra_members';
      }
      if (snakeKey == 'head_count_student') {
        snakeKey = 'students';
      }
      if (snakeKey == 'head_count_philcare') {
        snakeKey = 'philcare_staff';
      }
      if (snakeKey == 'head_count_security') {
        snakeKey = 'security_personnel';
      }
      if (snakeKey == 'head_count_construction_worker') {
        snakeKey = 'construction_workers';
      }
      if (snakeKey == 'head_count_tenant') {
        snakeKey = 'tenants';
      }
      if (snakeKey == 'head_count_health_worker') {
        snakeKey = 'health_workers';
      }
      if (snakeKey == 'head_count_non_academic_staff') {
        snakeKey = 'non_academic_staff';
      }
      if (snakeKey == 'head_count_guest') {
        snakeKey = 'guests';
      }

      result[snakeKey] = value;
    });
    
    return result;
  }

  /// Get event totals for a specific event
  Future<List<Map<String, dynamic>>> getEventTotals(String eventId) async {
    try {
      final response = await _supabase
          .from('event_totals')
          .select()
          .eq('event_id', eventId);  // snake_case column name

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('[SupabaseEventTotalAPI] Failed to get event totals: $e');
      throw Exception('Failed to get event totals: $e');
    }
  }

  /// Get event totals for a specific event and cluster
  Future<Map<String, dynamic>?> getEventTotalByCluster({
    required String eventId,
    required String cluster,
  }) async {
    try {
      final response = await _supabase
          .from('event_totals')
          .select()
          .eq('event_id', eventId)
          .eq('cluster', cluster)
          .maybeSingle();

      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      print('[SupabaseEventTotalAPI] Failed to get event total by cluster: $e');
      throw Exception('Failed to get event total by cluster: $e');
    }
  }

  /// Delete event totals for a specific event
  Future<void> deleteEventTotals(String eventId) async {
    try {
      await _supabase
          .from('event_totals')
          .delete()
          .eq('event_id', eventId);
      
      print('[SupabaseEventTotalAPI] Deleted event totals for event: $eventId');
    } catch (e) {
      print('[SupabaseEventTotalAPI] Failed to delete event totals: $e');
      throw Exception('Failed to delete event totals: $e');
    }
  }

  /// Recalculate totals for an event by summing all reports
  /// Useful if you need to rebuild the totals from scratch
  Future<void> recalculateEventTotals(String eventId) async {
    try {
      // First, delete existing totals
      await deleteEventTotals(eventId);

      // Fetch all reports for this event
      final reports = await _supabase
          .from('reports')
          .select()
          .eq('event_id', eventId);

      // Group reports by cluster and sum them
      final Map<String, Map<String, int>> clusterTotals = {};

      for (var report in reports) {
        final cluster = report['cluster'] ?? 'Unknown';
        
        if (!clusterTotals.containsKey(cluster)) {
          clusterTotals[cluster] = {
            'faculty_members': 0,
            'admin_members': 0,
            'reps_members': 0,
            'ra_members': 0,
            'students': 0,
            'philcare_staff': 0,
            'security_personnel': 0,
            'construction_workers': 0,
            'tenants': 0,
            'health_workers': 0,
            'non_academic_staff': 0,
            'guests': 0,
            'num_missing_persons': 0,
            'num_casualties': 0,
          };
        }

        // Add report values to cluster totals
        final totals = clusterTotals[cluster]!;
        totals['faculty_members'] = (totals['faculty_members'] ?? 0) + (report['faculty_members'] as int? ?? 0);
        totals['admin_members'] = (totals['admin_members'] ?? 0) + (report['admin_members'] as int? ?? 0);
        totals['reps_members'] = (totals['reps_members'] ?? 0) + (report['reps_members'] as int? ?? 0);
        totals['ra_members'] = (totals['ra_members'] ?? 0) + (report['ra_members'] as int? ?? 0);
        totals['students'] = (totals['students'] ?? 0) + (report['students'] as int? ?? 0);
        totals['philcare_staff'] = (totals['philcare_staff'] ?? 0) + (report['philcare_staff'] as int? ?? 0);
        totals['security_personnel'] = (totals['security_personnel'] ?? 0) + (report['security_personnel'] as int? ?? 0);
        totals['construction_workers'] = (totals['construction_workers'] ?? 0) + (report['construction_workers'] as int? ?? 0);
        totals['tenants'] = (totals['tenants'] ?? 0) + (report['tenants'] as int? ?? 0);
        totals['health_workers'] = (totals['health_workers'] ?? 0) + (report['health_workers'] as int? ?? 0);
        totals['non_academic_staff'] = (totals['non_academic_staff'] ?? 0) + (report['non_academic_staff'] as int? ?? 0);
        totals['guests'] = (totals['guests'] ?? 0) + (report['guests'] as int? ?? 0);
        totals['num_missing_persons'] = (totals['num_missing_persons'] ?? 0) + (report['num_missing_persons'] as int? ?? 0);
        totals['num_casualties'] = (totals['num_casualties'] ?? 0) + (report['num_casualties'] as int? ?? 0);
      }

      // Insert new totals for each cluster
      for (var entry in clusterTotals.entries) {
        await _supabase.from('event_totals').insert({
          'event_id': eventId,
          'cluster': entry.key,
          ...entry.value,
        });
      }

      print('[SupabaseEventTotalAPI] Recalculated totals for event: $eventId');
    } catch (e) {
      print('[SupabaseEventTotalAPI] Failed to recalculate event totals: $e');
      throw Exception('Failed to recalculate event totals: $e');
    }
  }
}
