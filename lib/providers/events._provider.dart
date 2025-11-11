import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/firebase_event_api.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';

class Events with ChangeNotifier {
  late final FirebaseEventAPI firebaseService;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _eventsStream;

  Events() {
    firebaseService = FirebaseEventAPI();
    fetchEvents();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get events => _eventsStream;

  void fetchEvents() {
    _eventsStream = firebaseService.getAllEvents().cast<QuerySnapshot<Map<String, dynamic>>>();
    notifyListeners();
  }

  Future<void> addEvent(Event event) async {
    final message = await firebaseService.addEvent(event.toJson());
    debugPrint(message);
    notifyListeners();
  }

  Future<void> editEvent(String id, Map<String, dynamic> edit) async {
    final message = await firebaseService.editEvent(id, edit);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    final message = await firebaseService.deleteEvent(id);
    debugPrint(message);
    notifyListeners();
  }

  Future<Event> getEventById(String id) async {
    // Make sure this returns a DocumentSnapshot, not a Stream
    final doc = await firebaseService.getEventById(id);
    return Event.fromFirestore(doc);
  }

  Future<void> addReportToEvent(String eventId, String upSystem, String reportId, Map<String, int> data) async {
    final message = await firebaseService.addReport(reportId, upSystem, eventId, data);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> updateEventStatusByDate(String id) async {
    await firebaseService.updateStatusByDate(id);
    notifyListeners();
  }

  Future<void> toggleStatus(String id, bool status) async {
    // Example: update the event’s status field
    await firebaseService.editEvent(id, {'status': status ? 'Completed' : 'Ongoing'});
    notifyListeners();
  }

  Future<void> updateAllEventStatuses() async {
    final snapshot = await firebaseService.getAllEvents().first;
    for (var doc in snapshot.docs) {
      await updateEventStatusByDate(doc.id);
    }
  }

}
