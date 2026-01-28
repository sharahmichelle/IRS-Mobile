import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEventAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getAllEvents() {
    return _supabase
        .from('events')
        .stream(primaryKey: ['id'])
        .map((data) => data);
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await _supabase
        .from('events')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<String> addEvent(Map<String, dynamic> event) async {
    try {
      final response = await _supabase
          .from('events')
          .insert(event)
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<void> updateStatusByDate(String id) async {
    final now = DateTime.now().toIso8601String();
    await _supabase.rpc('update_event_status_by_date', params: {'event_id': id, 'current_time': now});
  }

  Future<String> deleteEvent(String id) async {
    try {
      await _supabase
          .from('events')
          .delete()
          .eq('id', id);
      return "Successfully deleted event!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> editEvent(String id, Map<String, dynamic> edit) async {
    try {
      await _supabase
          .from('events')
          .update(edit)
          .eq('id', id);
      return "Successfully edited event!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> addReport(
    String reportId,
    String upSystem,
    String id,
    Map<String, int> data,
  ) async {
    try {
      await _supabase.rpc('add_report_to_event', params: {
        'report_id': reportId,
        'up_system': upSystem,
        'event_id': id,
        'data': data,
      });

      return "Report added";
    } catch (e) {
      return "Failed with error: $e";
    }
  }
}
