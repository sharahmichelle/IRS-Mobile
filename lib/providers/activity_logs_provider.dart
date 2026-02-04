import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/supabase_activity_log_api.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_model.dart';

class ActivityLogs with ChangeNotifier {
  late final SupabaseActivityLogAPI supabaseService;
  late Stream<List<Map<String, dynamic>>> _activityLogsStream;

  ActivityLogs() {
    supabaseService = SupabaseActivityLogAPI();
    fetchActivityLogs();
  }

  Stream<List<Map<String, dynamic>>> get activityLogs => _activityLogsStream;

  void fetchActivityLogs() {
    _activityLogsStream = supabaseService.getAllActivityLogs();
    notifyListeners();
  }

  Future<void> addActivityLog(ActivityLog activityLog) async {
    final message = await supabaseService.addActivityLog(activityLog.toJson());
    debugPrint(message);
    notifyListeners();
  }

  Future<void> editActivityLog(String id, Map<String, dynamic> edit) async {
    final message = await supabaseService.editActivityLog(id, edit);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> deleteActivityLog(String id) async {
    final message = await supabaseService.deleteActivityLog(id);
    debugPrint(message);
    notifyListeners();
  }

  Future<ActivityLog> getActivityLogById(String id) async {
    final data = await supabaseService.getActivityLogById(id);
    return ActivityLog.fromJson(data);
  }

  Future<void> updateActivityLogStatusByDate(String id) async {
    await supabaseService.updateStatusByDate(id);
    notifyListeners();
  }

  Future<void> toggleStatus(String id, bool status) async {
    // Example: update the activityLog’s status field
    await supabaseService.editActivityLog(id, {'status': status ? 'Completed' : 'Ongoing'});
    notifyListeners();
  }

  Future<void> updateAllActivityLogStatuses() async {
    // Note: This method needs adjustment as Supabase stream doesn't have .first or .docs
    // For now, leaving as is, but may need to fetch all logs differently
    // final snapshot = await supabaseService.getAllActivityLogs().first;
    // for (var doc in snapshot.docs) {
    //   await updateActivityLogStatusByDate(doc.id);
    // }
  }
}
