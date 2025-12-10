import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_screen.dart';
import 'package:upm_drrm_irs_mobile/widgets/chart_card.dart';
import 'package:upm_drrm_irs_mobile/widgets/chart_type_selector.dart';
import 'package:upm_drrm_irs_mobile/widgets/event_selector.dart';
import 'package:upm_drrm_irs_mobile/widgets/screen_header.dart';
import 'package:upm_drrm_irs_mobile/widgets/statistics_card.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  // Modern color scheme
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color accentColor = Color(0xFF0EA5E9);

  int _currentChartIndex = 0;
  int _currentEventIndex = 0;
  final List<String> _chartTypes = [
    'Demographics',
    'Distribution',
    'Trend Analysis',
  ];
  
  // Cache for fetched event totals
  final Map<String, EventTotal> _eventTotalsCache = {};
  bool _isFetchingEventTotal = false;

  // Dummy data as fallback (you can remove this once everything works)
  final List<Event> dummyEvents = [
    Event(
      eventID: "EVT001",
      timeStampStart: DateTime(2025, 1, 15, 9, 0),
      timeStampEnd: DateTime(2025, 1, 15, 17, 0),
      eventName: "Earthquake Drill",
      eventDescription: "University-wide earthquake preparedness drill.",
      status: "Completed",
      action: "Filed Report",
      category: "Drill",
      eventIntroduction: "This drill simulates an earthquake scenario.",
      eventObservations: ["Evacuation completed in 8 minutes"],
      eventScenario: "Magnitude 6.5 simulated quake",
      factSheet: "Prepared by Disaster Response Committee",
      incidentCommander: "Dr. Maria Santos",
      liasonOfficer: "Prof. James Rodriguez",
      publicInformationOfficer: "Ms. Anna Lopez",
      safetySecurityOfficer: "Mr. Carlos Reyes",
      location: "UP Manila Main Campus",
    ),
  ];

  void _navigateToAddReport(Event event) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => AddReportScreen(currentEvent: event),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to add report for ${event.eventName}'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _nextChart() {
    setState(() {
      _currentChartIndex = (_currentChartIndex + 1) % _chartTypes.length;
    });
  }

  void _previousChart() {
    setState(() {
      _currentChartIndex = (_currentChartIndex - 1) % _chartTypes.length;
      if (_currentChartIndex < 0) _currentChartIndex = _chartTypes.length - 1;
    });
  }

  void _nextEvent() {
    setState(() {
      _currentEventIndex = (_currentEventIndex + 1) % _events.length;
    });
  }

  void _previousEvent() {
    setState(() {
      _currentEventIndex = (_currentEventIndex - 1) % _events.length;
      if (_currentEventIndex < 0) _currentEventIndex = _events.length - 1;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Variables to store events
  List<Event> _events = [];
  EventTotal? _currentEventTotal;
  bool _isLoadingEventTotal = false;
  String? _eventTotalError;

  // Helper method to create an empty EventTotal with specific eventId
  EventTotal _createEmptyEventTotal(String eventId) {
    return EventTotal(
      eventId: eventId,
      timeStampStart: DateTime.now(),
      timeStampEnd: DateTime.now(),
      expectedData: 0,
      receivedData: 0,
      isActual: false,
      reportsId: [],
      totalFaculty: 0,
      totalAdminMembers: 0,
      totalRepsMembers: 0,
      totalCustodians: 0,
      totalJoCosMembers: 0,
      totalStudents: 0,
      totalSecurity: 0,
      totalConstructionWorkers: 0,
      totalHealthWorkers: 0,
      totalGuests: 0,
      totalPatients: 0,
      totalMissingPersons: 0,
      totalCasualties: 0,
      totalDistribution: {},
    );
  }

  // Fetch event total for the current event
  Future<void> _fetchEventTotalForEvent(String eventId) async {
    if (_isFetchingEventTotal) return;
    
    _isFetchingEventTotal = true;
    setState(() {
      _isLoadingEventTotal = true;
      _eventTotalError = null;
    });

    try {
      // Check cache first
      if (_eventTotalsCache.containsKey(eventId)) {
        _currentEventTotal = _eventTotalsCache[eventId];
      } else {
        // Fetch from provider
        final eventTotalsProvider = Provider.of<EventTotals>(context, listen: false);
        final eventTotal = await eventTotalsProvider.getEventTotalByEventId(eventId);
        
        if (eventTotal != null) {
          _currentEventTotal = eventTotal;
          _eventTotalsCache[eventId] = eventTotal;
        } else {
          // If no event total found, create an empty one with the eventId
          _currentEventTotal = _createEmptyEventTotal(eventId);
        }
      }
      
      _eventTotalError = null;
    } catch (e) {
      _eventTotalError = e.toString();
      debugPrint('Error fetching event total: $e');
      // Create an empty event total with the eventId
      _currentEventTotal = _createEmptyEventTotal(eventId);
    } finally {
      setState(() {
        _isLoadingEventTotal = false;
        _isFetchingEventTotal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ScreenHeader(
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              title: "Analytics",
              subtitle: "Compare statistics across different events",
              icon: Icons.analytics_rounded,
            ),
            const SizedBox(height: 12),

            // StreamBuilder for Events - Single Stream Approach
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.watch<Events>().events,
              builder: (context, eventsSnapshot) {
                // Handle loading states
                if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }

                // Handle errors
                if (eventsSnapshot.hasError) {
                  return _buildErrorWidget(eventsSnapshot.error.toString());
                }

                // Handle empty states
                if (!eventsSnapshot.hasData || eventsSnapshot.data!.docs.isEmpty) {
                  return _buildEmptyEventsState();
                }

                // Process events data
                final events = eventsSnapshot.data!.docs.map((doc) {
                  return Event.fromFirestore(doc);
                }).toList();

                // Update local events list
                if (_events.isEmpty || _events.length != events.length) {
                  setState(() {
                    _events = events;
                  });
                  // If we have events but no current event total, fetch for the first event
                  if (_currentEventTotal == null && events.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _fetchEventTotalForEvent(events[_currentEventIndex].eventID);
                    });
                  }
                }

                final currentEvent = _currentEventIndex < _events.length
                    ? _events[_currentEventIndex]
                    : _events.first;

                // Build EventSelector
                return EventSelector(
                  currentEvent: currentEvent,
                  onPrevious: () {
                    setState(() {
                      _currentEventIndex = (_currentEventIndex - 1) % _events.length;
                      if (_currentEventIndex < 0) _currentEventIndex = _events.length - 1;
                    });
                    // Fetch event total for the new current event
                    _fetchEventTotalForEvent(_events[_currentEventIndex].eventID);
                  },
                  onNext: () {
                    setState(() {
                      _currentEventIndex = (_currentEventIndex + 1) % _events.length;
                    });
                    // Fetch event total for the new current event
                    _fetchEventTotalForEvent(_events[_currentEventIndex].eventID);
                  },
                  surfaceColor: surfaceColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                );
              },
            ),
            const SizedBox(height: 8),

            // Chart Type Selector
            ChartTypeSelector(
              currentChartType: _chartTypes[_currentChartIndex],
              currentEventIndex: _currentEventIndex,
              totalEvents: _events.length,
              onPrevious: _previousChart,
              onNext: _nextChart,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Builder(
                  builder: (context) {
                    // If no events yet, show loading
                    if (_events.isEmpty) {
                      return _buildChartLoading();
                    }

                    final currentEvent = _currentEventIndex < _events.length
                        ? _events[_currentEventIndex]
                        : _events.first;

                    // Show loading while fetching event total
                    if (_isLoadingEventTotal) {
                      return _buildChartLoading();
                    }

                    // Show error if event total fetch failed
                    if (_eventTotalError != null) {
                      return _buildChartError(_eventTotalError!);
                    }

                    // Use cached or fetched event total
                    final displayEventTotal = _currentEventTotal ?? _createEmptyEventTotal(currentEvent.eventID);

                    return ChartCard(
                      currentEvent: currentEvent,
                      currentEventTotal: displayEventTotal,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
                      backgroundColor: backgroundColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      getStatusColor: _getStatusColor,
                      chartType: _chartTypes[_currentChartIndex],
                      onAddReport: () => _navigateToAddReport(currentEvent),
                    );
                  },
                ),
              ),
            ),

            // Statistics Cards
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                // If no events yet, show loading
                if (_events.isEmpty) {
                  return _buildStatisticsLoading();
                }

                final currentEvent = _currentEventIndex < _events.length
                    ? _events[_currentEventIndex]
                    : _events.first;

                // Show loading while fetching event total
                if (_isLoadingEventTotal) {
                  return _buildStatisticsLoading();
                }

                // Show error if event total fetch failed
                if (_eventTotalError != null) {
                  return _buildStatisticsError();
                }

                // Use cached or fetched event total
                final displayEventTotal = _currentEventTotal ?? _createEmptyEventTotal(currentEvent.eventID);

                return StatisticsCards(
                  currentEventTotal: displayEventTotal,
                  surfaceColor: surfaceColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Loading and error helper widgets
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading events',
                style: TextStyle(color: Colors.red),
              ),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No events found',
            style: TextStyle(color: textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildChartLoading() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text(
              'Loading chart data...',
              style: TextStyle(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartError(String error) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Error loading chart data',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                error.length > 100 ? '${error.substring(0, 100)}...' : error,
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartEmpty() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, color: textSecondary, size: 48),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Create events to see analytics',
              style: TextStyle(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      ),
    );
  }

  Widget _buildStatisticsError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Error loading statistics',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}