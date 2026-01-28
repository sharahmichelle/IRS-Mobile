/* import 'package:cloud_firestore/cloud_firestore.dart'; */
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/supabase_event_api.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';

class Events with ChangeNotifier {
  late final SupabaseEventAPI supabaseService;
  late Stream<List<Map<String, dynamic>>> _eventsStream;

  Events() {
    supabaseService = SupabaseEventAPI();
    fetchEvents();
  }

  Stream<List<Map<String, dynamic>>> get events => _eventsStream;

  void fetchEvents() {
    _eventsStream = supabaseService.getAllEvents();
    notifyListeners();
  }

  void refreshEvents() {
    _eventsStream = supabaseService.getAllEvents();
    notifyListeners();
  }

  Future<String> addEvent(Event event) async {
    final message = await supabaseService.addEvent(event.toJson());
    debugPrint(message);
    notifyListeners();
    return message;

  }

  Future<void> editEvent(String id, Map<String, dynamic> edit) async {
    final message = await supabaseService.editEvent(id, edit);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    final message = await supabaseService.deleteEvent(id);
    debugPrint(message);
    notifyListeners();
  }

  Future<Event> getEventById(String id) async {
    final data = await supabaseService.getEventById(id);
    return Event.fromMap(data, id);
  }

  Future<void> addReportToEvent(String eventId, String upSystem, String reportId, Map<String, int> data) async {
    final message = await supabaseService.addReport(reportId, upSystem, eventId, data);
    debugPrint(message);
    notifyListeners();
  }

  Future<void> updateEventStatusByDate(String id) async {
    await supabaseService.updateStatusByDate(id);
    notifyListeners();
  }

  Future<void> toggleStatus(String id, bool status) async {
    // Example: update the event’s status field
    await supabaseService.editEvent(id, {'status': status ? 'Completed' : 'Ongoing'});
    notifyListeners();
  }

  Future<void> updateAllEventStatuses() async {
    final eventsList = await supabaseService.getAllEvents().first;
    for (var eventData in eventsList) {
      await updateEventStatusByDate(eventData['id']);
    }
  }

}
