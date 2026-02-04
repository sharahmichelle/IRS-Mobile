import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore_for_file: unused_field
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/report_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/reports_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_screen.dart';

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
  final Color _successGreen = const Color(0xFF2A9D8F);
  final Color _warningOrange = const Color(0xFFE9C46A);
  final Color _infoCyan = const Color(0xFF4CC9F0);
  final Color _accentBlue = const Color(0xFF457B9D);

  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
  );

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Map<String, List<Report>> _eventReports = {};
  bool _isLoading = true;

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
    _loadEventReports();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEventReports() async {
    setState(() => _isLoading = true);

    try {
      final eventsProvider = Provider.of<Events>(context, listen: false);
      final reportsProvider = Provider.of<Reports>(context, listen: false);

      // Get all events
      final eventsStream = eventsProvider.events;
      final eventsSnapshot = await eventsStream.first;

      Map<String, List<Report>> reports = {};

      for (var eventData in eventsSnapshot) {
        final eventId = eventData['eventid'];
        // Get all reports and filter by eventId if needed
        final allReports = await reportsProvider.reports.first;
        final eventReports = allReports.where((report) => report.reportId == eventId).toList();
        reports[eventId] = eventReports;
      }

      if (mounted) {
        setState(() {
          _eventReports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading event reports: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _successGreen;
      case 'ongoing':
        return _warningOrange;
      case 'upcoming':
        return _infoCyan;
      default:
        return _textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'ongoing':
        return Icons.event_busy_rounded;
      case 'upcoming':
        return Icons.upcoming_rounded;
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
              bottom: 20,
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
            child: Row(
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
                        'View all incident reports',
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
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(_primaryRed),
                    ),
                  )
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: context.watch<Events>().events,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(_primaryRed),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final events = snapshot.data!.map((data) {
                        return Event.fromMap(data, data['eventid']);
                      }).toList();

                      // Get all reports for display
                      final allReports = _eventReports.values.expand((reports) => reports).toList();

                      if (allReports.isEmpty) {
                        return _buildNoReportsState();
                      }

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: allReports.length,
                          itemBuilder: (context, index) {
                            final report = allReports[index];
                            final event = events.firstWhere(
                              (e) => e.eventId == report.reportId,
                              orElse: () => Event(
                                eventId: report.reportId,
                                timeStampStart: DateTime.now(),
                                timeStampEnd: DateTime.now(),
                                category: 'unknown',
                                eventName: 'Unknown Event',
                                eventDescription: 'Unknown event description',
                                eventIntroduction: 'Unknown event introduction',
                                eventObservations: [],
                                eventScenario: 'Unknown scenario',
                                factSheet: 'Unknown fact sheet',
                                incidentCommander: 'Unknown',
                                liasonOfficer: 'Unknown',
                                status: 'unknown',
                                action: 'Unknown action',
                                location: 'Unknown Location',
                                publicInformationOfficer: 'Unknown',
                                safetySecurityOfficer: 'Unknown',
                              ),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildReportCard(event, report, index),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Event event, Report report, int index) {
    final totalPeople = report.facultymembers + report.adminmembers + report.repsmembers +
                       report.ramembers + report.students + report.philcarestaff +
                       report.securitypersonnel + report.constructionworkers +
                       report.tenants + report.healthworkers + report.nonacademicstaff + report.guests;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: event.status.toLowerCase() == 'ongoing' ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReportScreen(
                currentEvent: event,
                existingReport: report,
              ),
            ),
          );
        } : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _accentBlue.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getStatusIcon(event.status),
                      color: _getStatusColor(event.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.eventName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: _textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                report.exactlocation.isNotEmpty ? report.exactlocation : event.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      event.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _getStatusColor(event.status),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Container(height: 1, color: _textSecondary.withOpacity(0.1)),
              const SizedBox(height: 16),
              // Report Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.medical_services_rounded,
                      label: 'Casualties',
                      value: report.numcasualties.toString(),
                      color: _primaryRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.person_search_rounded,
                      label: 'Missing',
                      value: report.nummissingpersons.toString(),
                      color: _warningOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.people_rounded,
                      label: 'Total People',
                      value: totalPeople.toString(),
                      color: _successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: _textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    "${event.timeStampStart.day.toString().padLeft(2, '0')}/${event.timeStampStart.month.toString().padLeft(2, '0')}/${event.timeStampStart.year}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary),
                  ),
                ],
              ),
              if (event.status.toLowerCase() == 'ongoing')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 14, color: _accentBlue),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to edit report',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _accentBlue,
                        ),
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }



  Widget _buildNoReportsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _accentBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 48,
              color: _accentBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reports Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Reports will appear here once they are submitted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: _textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Events Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: _primaryRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}