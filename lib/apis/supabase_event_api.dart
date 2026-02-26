// lib/apis/supabase_event_api.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseEventAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get ALL events as a stream (for admins)
  Stream<List<Map<String, dynamic>>> getAllEvents() {
    return _supabase
        .from('events')
        .stream(primaryKey: ['event_id'])
        .map((data) => data);
  }

  /// Get events visible to a specific user based on their cluster/office/bldgname.
  ///
  /// Uses the `get_visible_event_ids` RPC function which returns:
  ///   - Global events (no rows in event_assignments)
  ///   - Events assigned to the user's cluster, office, or bldgname
  ///
  /// Because Supabase's `.stream()` doesn't support RPC-based filtering,
  /// we use a Future + periodic polling pattern via [getVisibleEventsForUser].
  /// For real-time updates, call [watchVisibleEventsForUser] which re-fetches
  /// every time the events table changes.
  Stream<List<Map<String, dynamic>>> watchVisibleEventsForUser({
    required String cluster,
    required String office,
    required String bldgName,
  }) {
    // Stream the full events table, then client-side filter by visible IDs.
    // This gives real-time updates while respecting assignment rules.
    return _supabase
        .from('events')
        .stream(primaryKey: ['event_id'])
        .asyncMap((allEvents) async {
          // Fetch visible IDs from the RPC function
          final visibleIds = await _getVisibleEventIds(
            cluster: cluster,
            office: office,
            bldgName: bldgName,
          );
          if (visibleIds.isEmpty) return <Map<String, dynamic>>[];
          // Filter the stream data to only include visible events
          return allEvents
              .where((e) => visibleIds.contains(e['event_id']?.toString()))
              .toList();
        });
  }

  /// One-shot fetch of events visible to a user. Use this for
  /// non-streaming contexts or initial loads.
  Future<List<Map<String, dynamic>>> getVisibleEventsForUser({
    required String cluster,
    required String office,
    required String bldgName,
  }) async {
    try {
      final visibleIds = await _getVisibleEventIds(
        cluster: cluster,
        office: office,
        bldgName: bldgName,
      );
      if (visibleIds.isEmpty) return [];

      // Fetch the actual event rows for the visible IDs
      final response = await _supabase
          .from('events')
          .select()
          .inFilter('event_id', visibleIds)
          .order('timestampstart');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SupabaseEventAPI] getVisibleEventsForUser failed: $e');
      throw Exception('Failed to fetch visible events: $e');
    }
  }

  /// Calls the Supabase RPC function `get_visible_event_ids` and returns
  /// a flat list of event_id strings.
  Future<List<String>> _getVisibleEventIds({
    required String cluster,
    required String office,
    required String bldgName,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_visible_event_ids',
        params: {
          'p_cluster':  cluster.isEmpty  ? null : cluster,
          'p_office':   office.isEmpty   ? null : office,
          'p_bldgname': bldgName.isEmpty ? null : bldgName,
        },
      );

      if (response == null) return [];
      final list = response as List;
      return list
          .map((row) => row['event_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('[SupabaseEventAPI] _getVisibleEventIds RPC failed: $e');
      // Fallback: return empty so the caller can handle gracefully
      return [];
    }
  }


  /// Get a specific event by ID
  Future<Map<String, dynamic>> getEventById(String id) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('event_id', id)
          .single();

      debugPrint('[SupabaseEventAPI] Successfully fetched event: $id');
      return response;
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to fetch event: $e');
      throw Exception('Failed to fetch event with id: $id. Error: $e');
    }
  }

  /// Add a new event
  Future<String> addEvent(Map<String, dynamic> event) async {
    try {
      debugPrint('[SupabaseEventAPI] Adding event: ${event['eventName']}');

      final response = await _supabase
          .from('events')
          .insert(event)
          .select('event_id')
          .single();

      final eventId = response['event_id'] as String;
      debugPrint('[SupabaseEventAPI] Successfully added event with ID: $eventId');
      return eventId;
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to add event: $e');
      throw Exception('Failed to add event: $e');
    }
  }

  /// Assign an event to specific cluster/office/bldgname targets.
  /// Pass empty lists to make the event global (visible to all).
  Future<void> assignEvent({
    required String eventId,
    List<String> clusters  = const [],
    List<String> offices   = const [],
    List<String> bldgNames = const [],
  }) async {
    try {
      // Delete existing assignments first
      await _supabase
          .from('event_assignments')
          .delete()
          .eq('event_id', eventId);

      // Build rows to insert
      final rows = <Map<String, dynamic>>[];
      for (final c in clusters) {
        rows.add({'event_id': eventId, 'cluster': c});
      }
      for (final o in offices) {
        rows.add({'event_id': eventId, 'office': o});
      }
      for (final b in bldgNames) {
        rows.add({'event_id': eventId, 'bldgname': b});
      }

      if (rows.isNotEmpty) {
        await _supabase.from('event_assignments').insert(rows);
      }

      debugPrint('[SupabaseEventAPI] Assigned event $eventId to '
          '${clusters.length} clusters, ${offices.length} offices, '
          '${bldgNames.length} buildings');
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to assign event: $e');
      throw Exception('Failed to assign event: $e');
    }
  }

  /// Update event status based on date using RPC function
  Future<void> updateStatusByDate(String id) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _supabase.rpc(
        'update_event_status_by_date',
        params: {'event_id': id, 'current_time': now},
      );
      debugPrint('[SupabaseEventAPI] Successfully updated event status');
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to update event status: $e');
      throw Exception('Failed to update event status: $e');
    }
  }

  /// Delete an event
  Future<String> deleteEvent(String id) async {
    try {
      await _supabase.from('events').delete().eq('event_id', id);
      debugPrint('[SupabaseEventAPI] Successfully deleted event');
      return "Successfully deleted event!";
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to delete event: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Edit an existing event
  Future<String> editEvent(String id, Map<String, dynamic> edit) async {
    try {
      await _supabase.from('events').update(edit).eq('event_id', id);
      debugPrint('[SupabaseEventAPI] Successfully edited event');
      return "Successfully edited event!";
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to edit event: $e');
      throw Exception('Failed to edit event: $e');
    }
  }

  /// Add a report to an event using RPC function
  Future<String> addReport(
    String reportId,
    String cluster,
    String eventId,
    Map<String, int> data,
  ) async {
    try {
      await _supabase.rpc(
        'add_report_to_event',
        params: {
          'reportid': reportId,
          'cluster':  cluster,
          'eventid':  eventId,
          'data':     data,
        },
      );
      debugPrint('[SupabaseEventAPI] Successfully added report to event');
      return "Report added to event successfully";
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to add report to event: $e');
      throw Exception('Failed to add report to event: $e');
    }
  }

  /// Get events by status
  Future<List<Map<String, dynamic>>> getEventsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('status', status);
      return response;
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to fetch events by status: $e');
      throw Exception('Failed to fetch events by status: $e');
    }
  }

  /// Get events within a date range
  Future<List<Map<String, dynamic>>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .gte('timestampstart', startDate.toIso8601String())
          .lte('timestampend', endDate.toIso8601String())
          .order('timestampstart');
      return response;
    } catch (e) {
      debugPrint('[SupabaseEventAPI] Failed to fetch events by date range: $e');
      throw Exception('Failed to fetch events by date range: $e');
    }
  }
}