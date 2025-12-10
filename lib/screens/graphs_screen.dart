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

  // Variables to store events and event totals
  List<Event> _events = [];
  EventTotal? _currentEventTotal;
  bool _isLoadingEventTotal = false;
  String? _eventTotalError;

  @override
  void initState() {
    super.initState();
    // Initialize with empty state
    _events = [];
    _currentEventTotal = null;
  }

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
    if (_events.isEmpty) return;
    
    setState(() {
      _currentEventIndex = (_currentEventIndex + 1) % _events.length;
    });
    
    // Fetch event total for the new event AFTER setState completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventTotalForEvent(_events[_currentEventIndex].eventID);
    });
  }

  void _previousEvent() {
    if (_events.isEmpty) return;
    
    setState(() {
      _currentEventIndex = (_currentEventIndex - 1) % _events.length;
      if (_currentEventIndex < 0) _currentEventIndex = _events.length - 1;
    });
    
    // Fetch event total for the new event AFTER setState completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventTotalForEvent(_events[_currentEventIndex].eventID);
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

    // Update state immediately to show loading
    if (mounted) {
      setState(() {
        _isLoadingEventTotal = true;
        _eventTotalError = null;
      });
    }

    try {
      // Check cache first
      if (_eventTotalsCache.containsKey(eventId)) {
        if (mounted) {
          setState(() {
            _currentEventTotal = _eventTotalsCache[eventId];
            _isLoadingEventTotal = false;
            _eventTotalError = null;
          });
        }
        return;
      }

      // Fetch from provider
      final eventTotalsProvider = Provider.of<EventTotals>(context, listen: false);
      final eventTotal = await eventTotalsProvider.getEventTotalByEventId(eventId);
      
      if (eventTotal != null) {
        _eventTotalsCache[eventId] = eventTotal;
        if (mounted) {
          setState(() {
            _currentEventTotal = eventTotal;
            _isLoadingEventTotal = false;
            _eventTotalError = null;
          });
        }
      } else {
        // If no event total found, create an empty one with the eventId
        final emptyTotal = _createEmptyEventTotal(eventId);
        _eventTotalsCache[eventId] = emptyTotal;
        if (mounted) {
          setState(() {
            _currentEventTotal = emptyTotal;
            _isLoadingEventTotal = false;
            _eventTotalError = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching event total: $e');
      final emptyTotal = _createEmptyEventTotal(eventId);
      if (mounted) {
        setState(() {
          _currentEventTotal = emptyTotal;
          _isLoadingEventTotal = false;
          _eventTotalError = e.toString();
        });
      }
    } finally {
      _isFetchingEventTotal = false;
    }
  }

  // Method to handle events data received from stream
  void _handleEventsData(List<Event> events) {
    if (_events.isEmpty && events.isNotEmpty) {
      // First time loading events
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _events = events;
            // Fetch event total for the first event
            _fetchEventTotalForEvent(events[_currentEventIndex].eventID);
          });
        }
      });
    } else if (_events.length != events.length) {
      // Events list changed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _events = events;
            // Make sure current index is valid
            if (_currentEventIndex >= events.length) {
              _currentEventIndex = 0;
            }
            // Fetch event total for current event
            if (events.isNotEmpty) {
              _fetchEventTotalForEvent(events[_currentEventIndex].eventID);
            }
          });
        }
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

                // Handle events data update - DO NOT call setState here
                if (_events.isEmpty || _events.length != events.length) {
                  // Schedule the state update for after the current build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleEventsData(events);
                  });
                }

                final currentEvent = _currentEventIndex < _events.length && _events.isNotEmpty
                    ? _events[_currentEventIndex]
                    : (events.isNotEmpty ? events[0] : null);

                // If no current event, return empty container
                if (currentEvent == null) {
                  return Container(height: 80);
                }

                // Build EventSelector
                return EventSelector(
                  currentEvent: currentEvent,
                  onPrevious: _previousEvent,
                  onNext: _nextEvent,
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

            // Main Content Area - Fixed height to prevent overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMainContent(),
              ),
            ),

            // Statistics Cards
            const SizedBox(height: 12),
            _buildStatisticsSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
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
  }

  Widget _buildStatisticsSection() {
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