// lib/providers/event_totals_provider.dart
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/supabase_event_total_api.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';

class EventTotals with ChangeNotifier {
  late final SupabaseEventTotalAPI supabaseService;
  late Stream<List<Map<String, dynamic>>> _eventTotalsStream;

  EventTotals() {
    supabaseService = SupabaseEventTotalAPI();
    fetchEventTotals();
  }

  Stream<List<Map<String, dynamic>>> get eventTotals => _eventTotalsStream;

  void fetchEventTotals() {
    _eventTotalsStream = Stream.empty();
    notifyListeners();
  }

  /// Add a report to an event total using RPC
  /// This updates the aggregated totals for an event
  // In event_totals_provider.dart, update addReportToEventTotal method:

  Future<void> addReportToEventTotal(
    String eventId,
    String cluster,
    String reportId,
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('[EventTotals Provider] Adding report to event total');
      debugPrint('[EventTotals Provider] Event ID: $eventId');
      debugPrint('[EventTotals Provider] Cluster: $cluster');
      debugPrint('[EventTotals Provider] Report ID: $reportId');
      debugPrint('[EventTotals Provider] Data: $data');

      // Pass the data as-is - it should already be in snake_case
      final result = await supabaseService.addReportToEventTotal(
        cluster: cluster,
        data: data.cast<String, dynamic>(),
        eventId: eventId,
        reportId: reportId,
      );

      debugPrint('[EventTotals Provider] Result: $result');

      // Refresh the stream
      fetchEventTotals();
      notifyListeners();
    } catch (e) {
      debugPrint('[EventTotals Provider] Failed to add report to event total: $e');
      rethrow;
    }
  }

  /// Refresh the event totals stream manually
  void refresh() {
    debugPrint('[EventTotals Provider] Manually refreshing event totals stream');
    fetchEventTotals();
  }
}