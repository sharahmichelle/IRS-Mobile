import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseActivityLogAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getAllActivityLogs() {
    return _supabase
        .from('activity_logs')
        .stream(primaryKey: ['id'])
        .map((data) => data);
  }

  Future<Map<String, dynamic>> getActivityLogById(String id) async {
    final response = await _supabase
        .from('activity_logs')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<String> addActivityLog(Map<String, dynamic> activityLog) async {
    try {
      await _supabase
          .from('activity_logs')
          .insert(activityLog);
      return "Successfully added activity log!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<void> updateStatusByDate(String id) async {
    final now = DateTime.now().toIso8601String();
    await _supabase.rpc('update_activity_log_status_by_date', params: {'activity_log_id': id, 'current_time': now});
  }

  Future<String> deleteActivityLog(String id) async {
    try {
      await _supabase
          .from('activity_logs')
          .delete()
          .eq('id', id);
      return "Successfully deleted activity log!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> editActivityLog(String id, Map<String, dynamic> edit) async {
    try {
      await _supabase
          .from('activity_logs')
          .update(edit)
          .eq('id', id);
      return "Successfully edited activity log!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }
}
