// lib/providers/reports_provider.dart
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/supabase_report_api.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/models/user_model.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';

class Reports with ChangeNotifier {
  late final SupabaseReportAPI supabaseService;
  late final EventTotals eventTotals;
  late Stream<List<Report>> _reportsStream;

  // The encoder_id UUID of the currently logged-in user.
  String? _currentEncoderId;

  // Stored so we can auto-stamp new reports with the user's context
  String _currentUserCluster  = '';
  String _currentUserOffice   = '';
  String _currentUserBldgName = '';

  Reports(this.eventTotals) {
    supabaseService = SupabaseReportAPI();
    _reportsStream = const Stream.empty();
  }

  Stream<List<Report>> get reports => _reportsStream;

  // ─── User context ─────────────────────────────────────────────────────────

  /// Call this after the logged-in user's profile is loaded.
  ///
  /// [encoderId] = users.encoder_id UUID (NOT authid, NOT username).
  /// [user]      = full UserModel so cluster/office/bldgName can be
  ///               auto-stamped onto new reports.
  ///
  /// Pass an empty encoderId + empty UserModel to reset on logout.
  void setCurrentUser(String encoderId, UserModel user) {
    if (encoderId.isEmpty) {
      _currentEncoderId    = null;
      _currentUserCluster  = '';
      _currentUserOffice   = '';
      _currentUserBldgName = '';
      _reportsStream = const Stream.empty();
      notifyListeners();
      return;
    }

    _currentEncoderId    = encoderId;
    _currentUserCluster  = user.cluster;
    _currentUserOffice   = user.office;
    _currentUserBldgName = user.bldgName;

    debugPrint('[Reports Provider] setCurrentUser → '
        'encoder_id=$encoderId, cluster=$_currentUserCluster, '
        'office=$_currentUserOffice');

    fetchReports();
  }

  // ─── Stream management ────────────────────────────────────────────────────

  void fetchReports() {
    if (_currentEncoderId != null && _currentEncoderId!.isNotEmpty) {
      _reportsStream =
          supabaseService.getReportsByEncoderId(_currentEncoderId!);
    } else {
      _reportsStream = const Stream.empty();
    }
    notifyListeners();
  }

  // ─── Auto-stamp user context ──────────────────────────────────────────────

  /// Fills cluster/office/bldgName from the logged-in user's profile
  /// if the report data is missing them. Safety net for any code path
  /// that forgets to set these on the Report object.
  Map<String, dynamic> _stampUserContext(Map<String, dynamic> reportData) {
    return {
      ...reportData,
      if ((reportData['cluster']  ?? '').toString().isEmpty)
        'cluster':  _currentUserCluster,
      if ((reportData['office']   ?? '').toString().isEmpty)
        'office':   _currentUserOffice,
      if ((reportData['bldgName'] ?? '').toString().isEmpty)
        'bldgName': _currentUserBldgName,
    };
  }

  // ─── Duplicate check ──────────────────────────────────────────────────────

  Future<Report?> getUserReportForEvent(String userId, String eventId) async {
    try {
      final allReports = await _reportsStream.first;
      final match = allReports.firstWhere(
        (r) =>
            r.encoderId == userId &&
            (r.reportId == eventId || r.eventId == eventId),
        orElse: () =>
            Report(encoderId: '', cluster: '', office: '', bldgName: ''),
      );
      return match.encoderId.isNotEmpty ? match : null;
    } catch (e) {
      debugPrint('[Reports Provider] Error checking user report: $e');
      return null;
    }
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<String> addReport(
    Report report, {
    bool skipDuplicateCheck = false,
  }) async {
    try {
      if (!skipDuplicateCheck &&
          report.eventId != null &&
          report.eventId!.isNotEmpty) {
        final existing = await getUserReportForEvent(
          report.encoderId,
          report.eventId!,
        );
        if (existing != null) {
          throw Exception(
            'You have already submitted a report for this event. '
            'Please edit your existing report instead.',
          );
        }
      }

      debugPrint(
          '[Reports Provider] Adding report for event: ${report.reportId}');

      final reportData = _stampUserContext(report.toJson());
      final id = await supabaseService.addReport(reportData);

      debugPrint('[Reports Provider] Successfully added report with id: $id');

      if (report.eventId != null && report.eventId!.isNotEmpty) {
        try {
          final totalsData = {
            'faculty_members':                   report.facultymembers,
            'admin_members':                     report.adminmembers,
            'reps_members':                      report.repsmembers,
            'ra_members':                        report.ramembers,
            'students':                          report.students,
            'philcare_staff':                    report.philcarestaff,
            'security_personnel':                report.securitypersonnel,
            'construction_workers':              report.constructionworkers,
            'tenants':                           report.tenants,
            'health_workers':                    report.healthworkers,
            'non_academic_staff':                report.nonacademicstaff,
            'guests':                            report.guests,
            'num_missing_persons':               report.nummissingpersons,
            'num_casualties':                    report.numcasualties,
            'namesofmissingpersons':             report.namesofmissingpersons,
            'identityandconditionofcasualties':  report.identityandconditionofcasualties,
            'event_type':                        report.eventType,
            'hazard_type':                       report.hazardType,
          };

          await eventTotals.addReportToEventTotal(
            report.eventId!,
            report.cluster,
            id,
            totalsData,
          );
        } catch (e) {
          debugPrint('[Reports Provider] Failed to add to event totals: $e');
        }
      }

      fetchReports();
      notifyListeners();
      return id;
    } catch (e) {
      debugPrint('[Reports Provider] Failed to add report: $e');
      rethrow;
    }
  }

  Future<void> editReport(String id, Map<String, dynamic> edit) async {
    try {
      await supabaseService.editReport(id, edit);
      fetchReports();
      notifyListeners();
    } catch (e) {
      debugPrint('[Reports Provider] Failed to edit report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await supabaseService.deleteReport(id);
      fetchReports();
      notifyListeners();
    } catch (e) {
      debugPrint('[Reports Provider] Failed to delete report: $e');
      rethrow;
    }
  }

  Future<Report> getReportById(String id) async {
    try {
      return await supabaseService.fetchReportById(id);
    } catch (e) {
      debugPrint('[Reports Provider] Failed to fetch report: $e');
      rethrow;
    }
  }

  Future<List<Report>> getReportsByEventId(String eventId) async {
    try {
      final allReports = await _reportsStream.first;
      return allReports
          .where((r) => r.reportId == eventId || r.eventId == eventId)
          .toList();
    } catch (e) {
      debugPrint('[Reports Provider] Failed to fetch reports for event: $e');
      rethrow;
    }
  }

  Future<List<Report>> getReportsByUser(String userId) async {
    try {
      final allReports = await _reportsStream.first;
      return allReports.where((r) => r.encoderId == userId).toList();
    } catch (e) {
      debugPrint('[Reports Provider] Failed to fetch reports for user: $e');
      rethrow;
    }
  }

  void refresh() {
    debugPrint('[Reports Provider] Manually refreshing reports stream');
    fetchReports();
  }
}