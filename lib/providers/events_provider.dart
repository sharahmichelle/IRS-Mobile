// lib/providers/events_provider.dart
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/supabase_event_api.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';

class Events with ChangeNotifier {
  late final SupabaseEventAPI supabaseService;
  late Stream<List<Map<String, dynamic>>> _eventsStream;

  // Current user's association fields — set via [setCurrentUser]
  String _userCluster  = '';
  String _userOffice   = '';
  String _userBldgName = '';
  bool   _userIsSet    = false;

  Events() {
    supabaseService = SupabaseEventAPI();
    // Start with an empty stream; real data comes after setCurrentUser()
    _eventsStream = const Stream.empty();
  }

  Stream<List<Map<String, dynamic>>> get events => _eventsStream;

  // ─── User context ─────────────────────────────────────────────────────────

  /// Call this immediately after the logged-in user's profile is loaded.
  /// It switches the internal stream to only show events visible to this user.
  ///
  /// If all three values are empty the user has no cluster/office/bldg
  /// assignment and will only see global events (events with no assignment rows).
  void setCurrentUser({
    required String cluster,
    required String office,
    required String bldgName,
  }) {
    _userCluster  = cluster;
    _userOffice   = office;
    _userBldgName = bldgName;
    _userIsSet    = true;

    debugPrint('[Events Provider] setCurrentUser → '
        'cluster=$cluster, office=$office, bldgName=$bldgName');

    fetchEvents();
  }

  // ─── Stream management ────────────────────────────────────────────────────

  void fetchEvents() {
    if (_userIsSet) {
      // Stream only events that are visible to this user
      _eventsStream = supabaseService.watchVisibleEventsForUser(
        cluster:  _userCluster,
        office:   _userOffice,
        bldgName: _userBldgName,
      );
    } else {
      // No user set yet — return empty stream (avoids showing all events)
      _eventsStream = const Stream.empty();
    }
    notifyListeners();
  }

  /// Refresh events stream manually
  Future<void> refreshEvents() async {
    debugPrint('[Events Provider] Refreshing events stream');
    fetchEvents();
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  /// Add a new event to Supabase.
  /// Returns the new event_id string.
  Future<String> addEvent(Event event) async {
    try {
      debugPrint('[Events Provider] Adding event: ${event.eventName}');
      final eventId = await supabaseService.addEvent(event.toJson());
      debugPrint('[Events Provider] Added event with id: $eventId');
      fetchEvents();
      notifyListeners();
      return eventId;
    } catch (e) {
      debugPrint('[Events Provider] Failed to add event: $e');
      rethrow;
    }
  }

  /// Assign an event to specific clusters/offices/buildings so that
  /// only matching users can see it.  Pass empty lists to make it global.
  Future<void> assignEvent({
    required String eventId,
    List<String> clusters  = const [],
    List<String> offices   = const [],
    List<String> bldgNames = const [],
  }) async {
    try {
      await supabaseService.assignEvent(
        eventId:   eventId,
        clusters:  clusters,
        offices:   offices,
        bldgNames: bldgNames,
      );
      fetchEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('[Events Provider] Failed to assign event: $e');
      rethrow;
    }
  }

  /// Edit an existing event
  Future<void> editEvent(String id, Map<String, dynamic> edit) async {
    try {
      final message = await supabaseService.editEvent(id, edit);
      debugPrint('[Events Provider] $message');
      fetchEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('[Events Provider] Failed to edit event: $e');
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String id) async {
    try {
      final message = await supabaseService.deleteEvent(id);
      debugPrint('[Events Provider] $message');
      fetchEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('[Events Provider] Failed to delete event: $e');
      rethrow;
    }
  }

  /// Get a specific event by ID
  Future<Event> getEventById(String id) async {
    try {
      final data  = await supabaseService.getEventById(id);
      final event = Event.fromMap(data, id);
      return event;
    } catch (e) {
      debugPrint('[Events Provider] Failed to fetch event: $e');
      rethrow;
    }
  }

  /// Add a report to an event (using RPC if available)
  Future<void> addReportToEvent(
    String eventId,
    String cluster,
    String reportId,
    Map<String, int> data,
  ) async {
    try {
      final message = await supabaseService.addReport(
        reportId,
        cluster,
        eventId,
        data,
      );
      debugPrint('[Events Provider] $message');
      fetchEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('[Events Provider] Failed to add report to event: $e');
      rethrow;
    }
  }

  /// Update event status based on current date/time
  Future<void> updateEventStatusByDate(String id) async {
    try {
      await supabaseService.updateStatusByDate(id);
      fetchEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('[Events Provider] Failed to update event status: $e');
      rethrow;
    }
  }

  /// Toggle event status manually
  Future<void> toggleStatus(String id, bool status) async {
    try {
      await supabaseService.editEvent(
        id,
        {'status': status ? 'Completed' : 'Ongoing'},
      );
      fetchEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('[Events Provider] Failed to toggle status: $e');
      rethrow;
    }
  }

  /// Update all event statuses based on current date/time
  Future<void> updateAllEventStatuses() async {
    try {
      final eventsList = await _eventsStream.first;
      for (var eventData in eventsList) {
        final eventId = eventData['event_id'];
        if (eventId != null) {
          await updateEventStatusByDate(eventId);
        }
      }
      fetchEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('[Events Provider] Failed to update all event statuses: $e');
      rethrow;
    }
  }

  /// Manually refresh the events stream
  void refresh() {
    debugPrint('[Events Provider] Manually refreshing events stream');
    fetchEvents();
  }
}