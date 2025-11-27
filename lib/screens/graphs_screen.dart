import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
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

  final List<EventTotal> dummyEventTotals = [
    EventTotal(
      eventId: "EVT001",
      timeStampStart: DateTime(2025, 1, 15),
      timeStampEnd: DateTime(2025, 1, 16),
      expectedData: 300,
      receivedData: 250,
      isActual: true,
      reportsId: ["RPT001"],
      totalFaculty: 40,
      totalAdminMembers: 30,
      totalRepsMembers: 20,
      totalCustodians: 15,
      totalJoCosMembers: 10,
      totalStudents: 120,
      totalSecurity: 12,
      totalConstructionWorkers: 8,
      totalHealthWorkers: 20,
      totalGuests: 25,
      totalPatients: 18,
      totalMissingPersons: 2,
      totalCasualties: 1,
      totalDistribution: {
        "Faculty": 40,
        "Admin Members": 30,
        "Students": 120,
      },
    ),
  ];

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
      _currentEventIndex = (_currentEventIndex + 1) % dummyEvents.length;
    });
  }

  void _previousEvent() {
    setState(() {
      _currentEventIndex = (_currentEventIndex - 1) % dummyEvents.length;
      if (_currentEventIndex < 0) _currentEventIndex = dummyEvents.length - 1;
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

            // StreamBuilder for Events
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.watch<Events>().events,
              builder: (context, eventsSnapshot) {
                if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }

                if (eventsSnapshot.hasError) {
                  return _buildErrorWidget(eventsSnapshot.error.toString());
                }

                if (!eventsSnapshot.hasData || eventsSnapshot.data!.docs.isEmpty) {
                  return _buildEmptyEventsState();
                }

                final events = eventsSnapshot.data!.docs.map((doc) {
                  return Event.fromFirestore(doc);
                }).toList();

                // Now build the EventSelector with real events
                return EventSelector(
                  currentEvent: _currentEventIndex < events.length 
                      ? events[_currentEventIndex] 
                      : events.first,
                  onPrevious: () {
                    setState(() {
                      _currentEventIndex = (_currentEventIndex - 1) % events.length;
                      if (_currentEventIndex < 0) _currentEventIndex = events.length - 1;
                    });
                  },
                  onNext: () {
                    setState(() {
                      _currentEventIndex = (_currentEventIndex + 1) % events.length;
                    });
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
              totalEvents: dummyEvents.length, // This will be updated with real count
              onPrevious: _previousChart,
              onNext: _nextChart,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 12),

            // Main Content with both streams
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: context.watch<Events>().events,
                  builder: (context, eventsSnapshot) {
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: context.watch<EventTotals>().eventTotals,
                      builder: (context, eventTotalsSnapshot) {
                        // Handle loading states
                        if (eventsSnapshot.connectionState == ConnectionState.waiting ||
                            eventTotalsSnapshot.connectionState == ConnectionState.waiting) {
                          return _buildChartLoading();
                        }

                        // Handle errors
                        if (eventsSnapshot.hasError || eventTotalsSnapshot.hasError) {
                          return _buildChartError(
                            eventsSnapshot.error?.toString() ?? eventTotalsSnapshot.error.toString()
                          );
                        }

                        // Handle empty states
                        if (!eventsSnapshot.hasData || eventsSnapshot.data!.docs.isEmpty) {
                          return _buildChartEmpty();
                        }

                        // Process events data
                        final events = eventsSnapshot.data!.docs.map((doc) {
                          return Event.fromFirestore(doc);
                        }).toList();

                        final currentEvent = _currentEventIndex < events.length 
                            ? events[_currentEventIndex] 
                            : events.first;

                        // Process event totals data
                        EventTotal? currentEventTotal;
                        if (eventTotalsSnapshot.hasData) {
                          final eventTotals = eventTotalsSnapshot.data!.docs.map((doc) {
                            return EventTotal.fromFirestore(doc);
                          }).toList();

                          currentEventTotal = eventTotals.firstWhere(
                            (total) => total.eventId == currentEvent.eventID,
                            orElse: () => EventTotal.empty(),
                          );
                        } else {
                          currentEventTotal = EventTotal.empty();
                        }

                        return ChartCard(
                          currentEvent: currentEvent,
                          currentEventTotal: currentEventTotal,
                          surfaceColor: surfaceColor,
                          primaryColor: primaryColor,
                          backgroundColor: backgroundColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          getStatusColor: _getStatusColor,
                          chartType: _chartTypes[_currentChartIndex],
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Statistics Cards with real data
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.watch<EventTotals>().eventTotals,
              builder: (context, eventTotalsSnapshot) {
                if (eventTotalsSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildStatisticsLoading();
                }

                if (eventTotalsSnapshot.hasError || !eventTotalsSnapshot.hasData) {
                  return _buildStatisticsError();
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: context.watch<Events>().events,
                  builder: (context, eventsSnapshot) {
                    if (!eventsSnapshot.hasData || eventsSnapshot.data!.docs.isEmpty) {
                      return SizedBox(); // Return empty if no events
                    }

                    final events = eventsSnapshot.data!.docs.map((doc) {
                      return Event.fromFirestore(doc);
                    }).toList();

                    final currentEvent = _currentEventIndex < events.length 
                        ? events[_currentEventIndex] 
                        : events.first;

                    final eventTotals = eventTotalsSnapshot.data!.docs.map((doc) {
                      return EventTotal.fromFirestore(doc);
                    }).toList();

                    final currentEventTotal = eventTotals.firstWhere(
                      (total) => total.eventId == currentEvent.eventID,
                      orElse: () => EventTotal.empty(),
                    );

                    // Use your StatisticsCards widget here
                    return StatisticsCards(
                      currentEventTotal: currentEventTotal,
                      surfaceColor: surfaceColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  },
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
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
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
          child: Text(
            'Error loading events',
            style: TextStyle(color: Colors.red),
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
              'Error loading chart',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary),
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
        height: 70, // Match the height of your StatisticsCards
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildStatisticsError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 70, // Match the height of your StatisticsCards
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