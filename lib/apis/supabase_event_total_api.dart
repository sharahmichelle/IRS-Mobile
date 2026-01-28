import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEventTotalAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getAllEventTotals() {
    return _supabase
        .from('event-totals')
        .stream(primaryKey: ['id'])
        .map((data) => data);
  }

  Future<Map<String, dynamic>> getEventTotalById(String id) async {
    final response = await _supabase
        .from('event-totals')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getEventTotalByEventId(
    String id,
  ) async {
    final response = await _supabase
        .from('event-totals')
        .select()
        .eq('eventId', id);
    return response;
  }

  Future<String> addEventTotal(Map<String, dynamic> eventTotal) async {
    try {
      await _supabase
          .from('event-totals')
          .insert(eventTotal);
      return "Successfully added event totals!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> deleteEventTotal(String id) async {
    try {
      await _supabase
          .from('event-totals')
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
          .from('event-totals')
          .update(edit)
          .eq('id', id);
      return "Successfully edited event total!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> addReport(
    String reportId,
    String upSystem,
    String eventId,
    Map<String, int> data,
  ) async {
    try {
      await _supabase.rpc('add_report_to_event_total', params: {
        'report_id': reportId,
        'up_system': upSystem,
        'event_id': eventId,
        'data': data,
      });

      return "Report added successfully to event: $eventId";
    } catch (e) {
      return "Failed with error: $e";
    }
  }
}
