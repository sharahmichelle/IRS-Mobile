import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
/* import 'package:cloud_firestore/cloud_firestore.dart'; */
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/event_total_model.dart';
import 'package:upm_drrm_irs_mobile/providers/event_totals_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_screen.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen>
    with TickerProviderStateMixin {
  // 2025 Modern Color Scheme - Emergency Red with Blue accents
  final Color _primaryRed = const Color(0xFFE63946); // Vibrant emergency red
  final Color _darkRed = const Color(0xFF9D0208); // Deep emergency red
  final Color _emergencyBlue = const Color(0xFF1D3557); // Dark blue for contrast
  final Color _accentBlue = const Color(0xFF457B9D); // Medium blue
  final Color _lightBlue = const Color(0xFFA8DADC); // Light blue accent
  final Color _white = const Color(0xFFF8F9FA); // Pure white background
  final Color _surfaceWhite = const Color(0xFFFFFFFF); // Card surface
  final Color _textPrimary = const Color(0xFF212529); // Near black
  final Color _textSecondary = const Color(0xFF6C757D); // Medium gray
  final Color _successGreen = const Color(0xFF2A9D8F); // Teal green
  final Color _warningOrange = const Color(0xFFE9C46A); // Amber
  final Color _infoCyan = const Color(0xFF4CC9F0); // Bright cyan

  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
    stops: [0.0, 0.8],
    transform: GradientRotation(0.5),
  );

  final LinearGradient _cardGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );

  final LinearGradient _emergencyGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE63946), Color(0xFFD00000)],
  );

  final LinearGradient _blueGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF457B9D), Color(0xFF1D3557)],
  );

  // Animation controllers
  late AnimationController _refreshController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Data variables
  List<Event> _events = [];
  Map<String, EventTotal?> _eventTotals = {};
  Map<String, bool> _isLoadingEventTotals = {};
  Map<String, String?> _eventTotalErrors = {};
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _events = [];
    
    // Initialize animations
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start fade animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToAddReport(Event event) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddReportScreen(currentEvent: event),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.arrow_forward_rounded, color: _white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Opening report for ${event.eventName}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _successGreen;
      case 'ongoing':
        return _warningOrange;
      case 'upcoming':
        return _infoCyan;
      case 'critical':
        return _primaryRed;
      default:
        return _textSecondary;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _successGreen.withOpacity(0.12);
      case 'ongoing':
        return _warningOrange.withOpacity(0.12);
      case 'upcoming':
        return _infoCyan.withOpacity(0.12);
      case 'critical':
        return _primaryRed.withOpacity(0.12);
      default:
        return _textSecondary.withOpacity(0.12);
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
      case 'critical':
        return Icons.priority_high_rounded;
      default:
        return Icons.info_rounded;
    }
  }

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

  Future<void> _fetchEventTotalForEvent(String eventId) async {
    if (_isLoadingEventTotals[eventId] == true) return;

    setState(() {
      _isLoadingEventTotals[eventId] = true;
      _eventTotalErrors[eventId] = null;
    });

    try {
      if (_eventTotals.containsKey(eventId) && _eventTotals[eventId] != null) {
        return;
      }

      final eventTotalsProvider =
          Provider.of<EventTotals>(context, listen: false);
      final eventTotal =
          await eventTotalsProvider.getEventTotalByEventId(eventId);

      if (mounted) {
        setState(() {
          _eventTotals[eventId] = eventTotal ?? _createEmptyEventTotal(eventId);
          _isLoadingEventTotals[eventId] = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching event total for $eventId: $e');
      if (mounted) {
        setState(() {
          _eventTotals[eventId] = _createEmptyEventTotal(eventId);
          _isLoadingEventTotals[eventId] = false;
          _eventTotalErrors[eventId] = e.toString();
        });
      }
    }
  }

  void _handleEventsData(List<Event> events) {
    if (_events.length != events.length) {
      setState(() {
        _events = events;
      });

      for (var event in events) {
        _fetchEventTotalForEvent(event.eventID);
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    _refreshController.forward(from: 0.0);

    // Refresh the events data
    final eventsProvider = Provider.of<Events>(context, listen: false);
    eventsProvider.refreshEvents();

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isRefreshing = false);
    _refreshController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _white,
        child: RefreshIndicator.adaptive(
          onRefresh: _refreshData,
          color: _primaryRed,
          backgroundColor: Colors.transparent,
          strokeWidth: 3,
          displacement: 40,
          edgeOffset: 20,
          notificationPredicate: (notification) => true,
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                  child: Column(
                    children: [
                      // Modern Header - EXTENDS TO TOP LIKE FIRST PICTURE
                      Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 16, // Account for status bar
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
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.emergency_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Incident Reports",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    "Real-time monitoring & reporting",
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
                      const SizedBox(height: 24),

                      // Main Content - SafeArea applied here instead
                      Expanded(
                        child: SafeArea(
                          top: false,
                          bottom: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: CustomScrollView(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Live Update Button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: _refreshData,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 14, vertical: 8),
                                                decoration: BoxDecoration(
                                                  gradient: _emergencyGradient,
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _primaryRed.withOpacity(0.4),
                                                      blurRadius: 16,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    AnimatedBuilder(
                                                      animation: _refreshController,
                                                      builder: (context, child) {
                                                        return Transform.rotate(
                                                          angle: _refreshController.value *
                                                              2 *
                                                              3.14159,
                                                          child: Icon(Icons.refresh_rounded,
                                                              size: 16, color: _white),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "LIVE UPDATE",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w800,
                                                        color: _white,
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // Stats Overview Cards
                                        _buildStatsOverview(),
                                      ],
                                    ),
                                  ),
                                ),

                                // Events List
                                StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: context.watch<Events>().events,
                                  builder: (context, eventsSnapshot) {
                                    if (eventsSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SliverToBoxAdapter(
                                          child: _buildLoadingIndicator());
                                    }

                                    if (eventsSnapshot.hasError) {
                                      return SliverToBoxAdapter(
                                          child: _buildErrorWidget(
                                              eventsSnapshot.error.toString()));
                                    }

                                    if (!eventsSnapshot.hasData ||
                                        eventsSnapshot.data!.isEmpty) {
                                      return SliverToBoxAdapter(
                                          child: _buildEmptyEventsState());
                                    }

                                    final events = eventsSnapshot.data!.map((data) {
                                      return Event.fromMap(data, data['id']);
                                    }).toList();

                                    if (_events.isEmpty ||
                                        _events.length != events.length) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _handleEventsData(events);
                                      });
                                    }

                                    return SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final event = events[index];
                                          final eventTotal = _eventTotals[event.eventID];
                                          final isLoading =
                                              _isLoadingEventTotals[event.eventID] ??
                                                  false;
                                          final error = _eventTotalErrors[event.eventID];

                                          return Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                20, index == 0 ? 0 : 8, 20, 16),
                                            child: _buildEventCard(
                                                event, eventTotal, isLoading, error,
                                                index: index),
                                          );
                                        },
                                        childCount: events.length,
                                      ),
                                    );
                                  },
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 32),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(String text,
      {required TextStyle style, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
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
      child: Text(text, style: style),
    );
  }

  Widget _buildStatsWidget(bool isLoading, String? error, EventTotal? eventTotal) {
    if (isLoading) {
      return _buildLoadingStats();
    } else if (error != null) {
      return _buildErrorStats();
    } else if (eventTotal != null) {
      return _buildEventStats(eventTotal);
    } else {
      return Container();
    }
  }

  Widget _buildStatsOverview() {
    final totalEvents = _events.length;
    final ongoingEvents = _events
        .where((e) => e.status.toLowerCase() == 'ongoing')
        .length;
    final upcomingEvents = _events
        .where((e) => e.status.toLowerCase() == 'upcoming')
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _blueGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _emergencyBlue.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                value: totalEvents.toString(),
                label: "Total\nIncidents",
                icon: Icons.emergency_rounded,
                color: _lightBlue,
              ),
              _buildStatCard(
                value: ongoingEvents.toString(),
                label: "Ongoing\nIncidents",
                icon: Icons.event_busy_rounded,
                color: _warningOrange,
              ),
              _buildStatCard(
                value: upcomingEvents.toString(),
                label: "Upcoming\nIncidents",
                icon: Icons.upcoming_rounded,
                color: _infoCyan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: _white.withOpacity(0.8), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tap any incident to submit real-time reports",
                    style: TextStyle(
                      color: _white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 22),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _white,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _white.withOpacity(0.8),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
      Event event, EventTotal? eventTotal, bool isLoading, String? error,
      {required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _navigateToAddReport(event),
          child: Container(
            decoration: BoxDecoration(
              gradient: _cardGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: _primaryRed.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToAddReport(event),
                  splashColor: _primaryRed.withOpacity(0.1),
                  highlightColor: _primaryRed.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with status and date
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getStatusBackgroundColor(event.status),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getStatusColor(event.status)
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(event.status),
                                    size: 16,
                                    color: _getStatusColor(event.status),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    event.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _getStatusColor(event.status),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _textSecondary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${event.timeStampStart.day.toString().padLeft(2, '0')}/${event.timeStampStart.month.toString().padLeft(2, '0')}/${event.timeStampStart.year}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Event title and location
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: _emergencyGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryRed.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.emergency_share_rounded,
                                  color: _white,
                                  size: 28,
                                ),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: _textPrimary,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: _textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          event.location,
                                          style: TextStyle(
                                            fontSize: 13,
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
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Category and Type
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _accentBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.category_rounded,
                                      size: 14, color: _accentBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.category,
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
                        const SizedBox(height: 24),

                        // Statistics Section - Simplified
                        _buildStatsWidget(isLoading, error, eventTotal),
                        const SizedBox(height: 24),

                        // Action Button
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: _emergencyGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryRed.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _navigateToAddReport(event),
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_alert_rounded,
                                        color: _white, size: 22),
                                    const SizedBox(width: 12),
                                    Text(
                                      'ADD INCIDENT REPORT',
                                      style: TextStyle(
                                        color: _white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventStats(EventTotal eventTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Single report count card
          _buildStatItem(
            icon: Icons.assignment_rounded,
            iconColor: _accentBlue,
            value: eventTotal.reportsId.length.toString(),
            label: "REPORTS SUBMITTED",
            subLabel: "Incident documentation",
          ),
          const SizedBox(height: 12),
          
          // Casualties count (optional - you can remove this too if you only want reports)
          _buildStatItem(
            icon: Icons.medical_services_rounded,
            iconColor: _primaryRed,
            value: eventTotal.totalCasualties.toString(),
            label: "CASUALTIES",
            subLabel: "Affected individuals",
            isEmergency: eventTotal.totalCasualties > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String subLabel,
    bool isEmergency = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmergency
            ? _primaryRed.withOpacity(0.08)
            : _textPrimary.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmergency
              ? _primaryRed.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          width: isEmergency ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isEmergency ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, size: 22, color: iconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isEmergency ? _primaryRed : _textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: _textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(_primaryRed),
                strokeWidth: 3,
                backgroundColor: _primaryRed.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading statistics...',
              style: TextStyle(
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: _primaryRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load statistics',
                  style: TextStyle(
                    color: _primaryRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check your connection and try again',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(_primaryRed),
                        strokeWidth: 4,
                        backgroundColor: _primaryRed.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.insights_rounded,
                      color: _primaryRed,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    'Loading Emergency Data',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fetching real-time incident statistics...',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryRed.withOpacity(0.1), _white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: _primaryRed,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Connection Error',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Unable to connect to emergency server. Please check your internet connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 52,
              width: 200,
              decoration: BoxDecoration(
                gradient: _emergencyGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryRed.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _refreshData,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: _white, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'RETRY CONNECTION',
                          style: TextStyle(
                            color: _white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_lightBlue, _white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.dashboard_outlined,
                  size: 56,
                  color: _accentBlue.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Active Incidents',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Incidents will appear here in real-time when they are reported. Stay prepared!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _accentBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accentBlue.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_active_rounded,
                      color: _accentBlue, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Reports will appear in real-time',
                    style: TextStyle(
                      color: _textSecondary,
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
    );
  }
}