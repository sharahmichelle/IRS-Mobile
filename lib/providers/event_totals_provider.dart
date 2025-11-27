import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/firebase_event_total_api.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';

class EventTotals with ChangeNotifier {
  late final FirebaseEventTotalAPI firebaseService;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _eventTotalsStream;

  EventTotals() {
    firebaseService = FirebaseEventTotalAPI();
    fetchEventTotals();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get eventTotals => _eventTotalsStream;

  void fetchEventTotals() {
    _eventTotalsStream = firebaseService.getAllEventTotals().cast<QuerySnapshot<Map<String, dynamic>>>();
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
    // Make sure this returns a DocumentSnapshot, not a Stream
    final doc = await firebaseService.getEventTotalById(id);
    return EventTotal.fromFirestore(doc);
  }

  Future<EventTotal?> getEventTotalByEventId(String eventId) async {
    final querySnapshot = await firebaseService.getEventTotalByEventId(eventId);
    if (querySnapshot.docs.isNotEmpty) {
      return EventTotal.fromFirestore(querySnapshot.docs.first);
    }
    return null; // or handle the case where no document is found
  }

  Future<void> addReportToEventTotal(String eventId, String upSystem, String reportId, Map<String, int> data) async {
    final message = await firebaseService.addReport(reportId, upSystem, eventId, data);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> toggleStatus(String id, bool status) async {
    // Example: update the event’s status field
    await firebaseService.editEventTotal(id, {'status': status ? 'Completed' : 'Ongoing'});
    notifyListeners();
  }

}
