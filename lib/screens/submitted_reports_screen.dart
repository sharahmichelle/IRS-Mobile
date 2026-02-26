import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/reports_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_general_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_ics_screen.dart';

class SubmittedReportsScreen extends StatefulWidget {
  const SubmittedReportsScreen({super.key});

  @override
  State<SubmittedReportsScreen> createState() => _SubmittedReportsScreenState();
}

class _SubmittedReportsScreenState extends State<SubmittedReportsScreen>
    with SingleTickerProviderStateMixin {
  // Colors
  final Color _primaryRed = const Color(0xFFE63946);
  final Color _darkRed = const Color(0xFF9D0208);
  final Color _white = const Color(0xFFF8F9FA);
  final Color _surfaceWhite = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);
  final Color _borderColor = const Color(0xFFE9ECEF);
  final Color _actualBadge = const Color(0xFFDC3545);
  final Color _drill_trainingBadge = const Color(0xFF0D6EFD);

  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
  );

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Report> _allReports = [];
  Map<String, Event> _eventCache = {};
  bool _isLoading = true;

  // Filter and sort state
  String _selectedFilter = 'all';
  bool _sortByDateAscending = false;

  // Stream subscription — kept so we can cancel and re-subscribe when the
  // provider replaces its internal stream (e.g. after addReport / editReport).
  StreamSubscription<List<Report>>? _reportsSub;
  Stream<List<Report>>? _currentStream;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _fadeController.forward();
  }

  /// Called on first build AND whenever an inherited widget (i.e. the
  /// Reports provider) notifies listeners.  We compare the current stream
  /// object reference; if it has changed (because fetchReports() created a
  /// new stream) we cancel the old subscription and create a new one.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reportsProvider = Provider.of<Reports>(context);
    final newStream = reportsProvider.reports;

    if (newStream != _currentStream) {
      _currentStream = newStream;
      _reportsSub?.cancel();
      _reportsSub = newStream.listen((reports) {
        if (!mounted) return;
        _loadEventsForReports(reports).then((_) {
          if (mounted) {
            setState(() {
              _allReports = reports;
              _isLoading = false;
            });
          }
        });
      });
      // Show loading spinner while waiting for first emission on new stream
      if (mounted) setState(() => _isLoading = true);
    }
  }

  @override
  void dispose() {
    _reportsSub?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEventsForReports(List<Report> reports) async {
    try {
      final eventsProvider = Provider.of<Events>(context, listen: false);
      final eventsStream = eventsProvider.events;
      final eventsSnapshot = await eventsStream.first;

      _eventCache.clear(); // Clear cache before loading

      for (var eventData in eventsSnapshot) {
        final eventId = eventData['eventid'] ?? eventData['event_id'] ?? eventData['id'];
        if (eventId != null) {
          _eventCache[eventId.toString()] = Event.fromMap(eventData, eventId.toString());
        }
      }

      debugPrint('Loaded ${_eventCache.length} events into cache');
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Event? _getEventById(String eventId) {
    return _eventCache[eventId];
  }

  List<Report> _getFilteredReports() {
    List<Report> filtered = List.from(_allReports);

    if (_selectedFilter == 'actual') {
      filtered = filtered.where((report) => 
        report.eventType != 'drill_training'
      ).toList();
    } else if (_selectedFilter == 'drill_training') {
      filtered = filtered.where((report) => 
        report.eventType == 'drill_training'
      ).toList();
    }

    // Sort by lastModified — both values are naive PST datetimes, compare directly.
    filtered.sort((a, b) {
      final comparison = a.lastModified.compareTo(b.lastModified);
      return _sortByDateAscending ? comparison : -comparison;
    });

    return filtered;
  }

  String _formatDateTime(DateTime date) {
    // The date is already in PST from the model, just format it
    final hour24 = date.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final amPm = hour24 < 12 ? 'AM' : 'PM';
    return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year} ${hour12.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')} $amPm";
  }

  String _formatLocation(String location) {
    if (location.isEmpty) return 'Location not specified';

    // Remove coordinates if present (format: "Address (lat, lng)")
    final coordPattern = RegExp(r'\s*\([^)]*\)$');
    return location.replaceAll(coordPattern, '').trim();
  }

  String _getDrillTrainingType(Report report) {
    // You may need to add an activityType field to your Report model
    // For now, returning a placeholder based on event
    final event = _getEventById(report.eventId ?? '');
    if (event?.category != null) {
      return event!.category;
    }
    return 'General Drill/Training';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Color _getIncidentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'earthquake':
        return const Color(0xFFFF9800);
      case 'fire':
        return const Color(0xFFF44336);
      case 'flood':
        return const Color(0xFF2196F3);
      case 'general':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF6C757D);
    }
  }

  IconData _getIncidentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'earthquake':
        return Icons.landscape_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'flood':
        return Icons.water_damage_rounded;
      case 'general':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              gradient: _headerGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Submitted Reports',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'View all incident and emergency reports',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter Tabs
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildFilterTab('All', 'all')),
                      Expanded(child: _buildFilterTab('Actual', 'actual')),
                      Expanded(child: _buildFilterTab('Drill/Training', 'drill_training')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(_primaryRed),
                    ),
                  )
                : _buildReportsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    final filteredReports = _getFilteredReports();

    if (filteredReports.isEmpty) {
      return _buildNoReportsState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Sort button with label and count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredReports.length} ${filteredReports.length == 1 ? 'report' : 'reports'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sortByDateAscending = !_sortByDateAscending;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _sortByDateAscending ? 'Oldest First' : 'Newest First',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _sortByDateAscending 
                          ? Icons.arrow_upward_rounded 
                          : Icons.arrow_downward_rounded,
                        size: 16,
                        color: _primaryRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: filteredReports.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return _buildReportCard(report, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? _primaryRed : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report, int index) {
    final isDrillTraining = report.eventType == 'drill_training';
    
    // Determine badge color and label
    Color badgeColor;
    String badgeLabel;
    IconData badgeIcon;
    
    if (isDrillTraining) {
      badgeColor = _drill_trainingBadge;
      badgeLabel = 'DRILL/TRAINING';
      badgeIcon = Icons.school_rounded;
    } else {
      badgeColor = _actualBadge;
      badgeLabel = 'ACTUAL';
      badgeIcon = Icons.warning_rounded;
    }

    // Get title based on type
    String title;
    String? subtitle;
    
    if (isDrillTraining) {
      final event = _getEventById(report.eventId ?? '');
      title = event?.eventName ?? 'Drill/Training Report';
      subtitle = _getDrillTrainingType(report);
    } else {
      // For incidents (including general reports), show incident type as title
      title = report.hazardType.isNotEmpty
        ? _capitalize(report.hazardType)
        : 'Actual Report';
      subtitle = null;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () => _navigateToEdit(report),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with colored accent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      badgeColor.withOpacity(0.08),
                      badgeColor.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge and Edit Row
                    Row(
                      children: [
                        // Type Badge with enhanced design
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                badgeColor,
                                badgeColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: badgeColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                badgeIcon,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                badgeLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Edit Button with enhanced design
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _borderColor,
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _navigateToEdit(report),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title with improved typography
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Subtitle for activities
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Location with improved design
                    _buildInfoRow(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFEF4444).withOpacity(0.1),
                      text: _formatLocation(report.exactlocation),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Divider
                    Container(
                      height: 1,
                      color: _borderColor.withOpacity(0.5),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Timestamps in a grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimestampChip(
                            icon: Icons.edit_calendar_rounded,
                            label: 'Last Modified',
                            time: _formatDateTime(report.lastModified),
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTimestampChip(
                            icon: Icons.calendar_today_rounded,
                            label: 'Created',
                            time: _formatDateTime(report.created),
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String text,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampChip({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: _textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit(Report report) async {
    // A "general report" has no eventId (standalone emergency/actual report).
    final isGeneralReport = report.isGeneralReport;

    if (isGeneralReport) {
      // General / standalone actual report — build a dummy event for the screen
      final dummyEvent = Event(
        eventId: '',
        eventName: 'Actual Report',
        location: report.exactlocation,
        status: 'ongoing',
        timeStampStart: DateTime.now(),
        timeStampEnd: DateTime.now().add(const Duration(hours: 1)),
        category: 'General',
        eventDescription: 'Actual report',
        incidentCommander: '',
        liasonOfficer: '',
        publicInformationOfficer: '',
        safetySecurityOfficer: '',
      );

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddReportGeneralScreen(
              currentEvent: dummyEvent,
              existingReport: report,
              isGeneralReport: true,
            ),
          ),
        );
      }
    } else {
      // Report is linked to an event (drill_training or actual tied to an event).
      // Look up the event in cache; if not found yet (e.g. newly auto-created event),
      // fall back to a reconstructed event so the edit screen can still open.
      Event? event = _getEventById(report.eventId!);

      if (event == null) {
        // Event not in cache — build a minimal fallback so editing isn't blocked.
        // This happens when a new actual report auto-creates its event in Supabase
        // and that event hasn't propagated to the local events cache yet.
        event = Event(
          eventId: report.eventId!,
          eventName: report.hazardType.isNotEmpty
              ? '${report.hazardType[0].toUpperCase()}${report.hazardType.substring(1)} Incident'
              : 'Actual Report',
          location: report.exactlocation,
          status: 'ongoing',
          timeStampStart: report.created,
          timeStampEnd: report.created.add(const Duration(hours: 1)),
          category: report.hazardType.isNotEmpty ? report.hazardType : 'general',
          eventDescription: 'Actual report',
          incidentCommander: '',
          liasonOfficer: '',
          publicInformationOfficer: '',
          safetySecurityOfficer: '',
        );
      }

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => report.eventType == 'drill_training'
                ? AddReportIcsScreen(
                    currentEvent: event!,
                    existingReport: report,
                  )
                : AddReportGeneralScreen(
                    currentEvent: event!,
                    existingReport: report,
                    isGeneralReport: false,
                  ),
          ),
        );
      }
    }
  }

  Widget _buildNoReportsState() {
    String message = 'No reports found';
    
    if (_selectedFilter == 'actual') {
      message = 'No actual reports yet';
    } else if (_selectedFilter == 'drill_training') {
      message = 'No drill/training reports yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _textSecondary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 36,
              color: _textSecondary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}