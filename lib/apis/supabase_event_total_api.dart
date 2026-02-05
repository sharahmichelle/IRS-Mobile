import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEventTotalAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getAllEventTotals() {
    return _supabase
        .from('event_totals')
        .stream(primaryKey: ['id'])
        .map((data) => data);
  }

  Future<Map<String, dynamic>> getEventTotalById(String id) async {
    final response = await _supabase
        .from('event_totals')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getEventTotalByEventId(
    String id,
  ) async {
    final response = await _supabase
        .from('event_totals')
        .select()
        .eq('eventid', id);
    return response;
  }

  Future<String> addEventTotal(Map<String, dynamic> eventTotal) async {
    try {
      await _supabase
          .from('event_totals')
          .insert(eventTotal);
      return "Successfully added event totals!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> deleteEventTotal(String id) async {
    try {
      await _supabase
          .from('event_totals')
          .delete()
          .eq('id', id);
      return "Successfully deleted event total!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> editEventTotal(String id, Map<String, dynamic> edit) async {
    try {
      await _supabase
          .from('event_totals')
          .update(edit)
          .eq('id', id);
      return "Successfully edited event total!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> addReport(
    String reportId,
    String cluster,
    String eventId,
    Map<String, int> data,
  ) async {
    try {
      debugPrint(
        '[SupabaseEventTotalAPI] RPC add_report_to_event_total params: '
        'reportid=$reportId eventid=$eventId data=$data',
      );

      final result = await _supabase.rpc(
        'add_report_to_event_total',
        params: {
          'cluster': cluster,
          'data': data,
          'eventid': eventId,    
          'reportid': reportId,   
        },
      );

      debugPrint('[SupabaseEventTotalAPI] RPC result: $result');
      return "Report added successfully to event: $eventId";
    } catch (e) {
      debugPrint('[SupabaseEventTotalAPI] RPC failed: $e');
      throw Exception('Failed to add report to event total: $e');
    }
  }
}