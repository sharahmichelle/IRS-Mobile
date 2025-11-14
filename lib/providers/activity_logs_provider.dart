import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/firebase_activity_log_api.dart';
import 'package:upm_drrm_irs_mobile/models/activity_log_model.dart';

class ActivityLogs with ChangeNotifier {
  late final FirebaseActivityLogAPI firebaseService;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _activityLogsStream;

  ActivityLogs() {
    firebaseService = FirebaseActivityLogAPI();
    fetchActivityLogs();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get activityLogs => _activityLogsStream;

  void fetchActivityLogs() {
    _activityLogsStream = firebaseService.getAllActivityLogs().cast<QuerySnapshot<Map<String, dynamic>>>();
    notifyListeners();
  }

  Future<void> addActivityLog(ActivityLog activityLog) async {
    final message = await firebaseService.addActivityLog(activityLog.toJson());
    debugPrint(message);
    notifyListeners();
  }

  Future<void> editActivityLog(String id, Map<String, dynamic> edit) async {
    final message = await firebaseService.editActivityLog(id, edit);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> deleteActivityLog(String id) async {
    final message = await firebaseService.deleteActivityLog(id);
    debugPrint(message);
    notifyListeners();
  }

  Future<ActivityLog> getActivityLogById(String id) async {
    // Make sure this returns a DocumentSnapshot, not a Stream
    final doc = await firebaseService.getActivityLogById(id);
    return ActivityLog.fromFirestore(doc.data()!);
  }

  Future<void> updateActivityLogStatusByDate(String id) async {
    await firebaseService.updateStatusByDate(id);
    notifyListeners();
  }

  Future<void> toggleStatus(String id, bool status) async {
    // Example: update the activityLog’s status field
    await firebaseService.editActivityLog(id, {'status': status ? 'Completed' : 'Ongoing'});
    notifyListeners();
  }

  Future<void> updateAllActivityLogStatuses() async {
    final snapshot = await firebaseService.getAllActivityLogs().first;
    for (var doc in snapshot.docs) {
      await updateActivityLogStatusByDate(doc.id);
    }
  }

}
