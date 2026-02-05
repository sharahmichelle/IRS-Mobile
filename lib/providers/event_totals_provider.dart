/* import 'package:cloud_firestore/cloud_firestore.dart'; */
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/supabase_event_total_api.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';

class EventTotals with ChangeNotifier {
  late final SupabaseEventTotalAPI firebaseService;
  late Stream<List<Map<String, dynamic>>> _eventTotalsStream;

  EventTotals() {
    firebaseService = SupabaseEventTotalAPI();
    fetchEventTotals();
  }

  Stream<List<Map<String, dynamic>>> get eventTotals => _eventTotalsStream;

  void fetchEventTotals() {
    _eventTotalsStream = firebaseService.getAllEventTotals();
    notifyListeners();
  }

  Future<void> addEventTotal(EventTotal eventTotal) async {
    final message = await firebaseService.addEventTotal(eventTotal.toJson());
    debugPrint(message);
    notifyListeners();
  }

  Future<void> editEventTotal(String id, Map<String, dynamic> edit) async {
    final message = await firebaseService.editEventTotal(id, edit);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> deleteEventTotal(String id) async {
    final message = await firebaseService.deleteEventTotal(id);
    debugPrint(message);
    notifyListeners();
  }

  Future<EventTotal> getEventTotalById(String id) async {
    final data = await firebaseService.getEventTotalById(id);
    return EventTotal.fromSupabase(data);
  }

  Future<EventTotal?> getEventTotalByEventId(String eventId) async {
    final dataList = await firebaseService.getEventTotalByEventId(eventId);
    if (dataList.isNotEmpty) {
      return EventTotal.fromSupabase(dataList.first);
    }
    return null;
  }

  Future<void> addReportToEventTotal(String eventId, String cluster, String reportId, Map<String, int> data) async {
    final message = await firebaseService.addReport(reportId, cluster, eventId, data);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> toggleStatus(String id, bool status) async {
    // Example: update the event’s status field
    await firebaseService.editEventTotal(id, {'status': status ? 'Completed' : 'Ongoing'});
    notifyListeners();
  }

}