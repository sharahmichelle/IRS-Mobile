import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/event_selection_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/submitted_reports_screen.dart';

// ignore_for_file: unused_field, unused_local_variable

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen>
    with TickerProviderStateMixin {
  // Color Scheme (keeping original)
  final Color _primaryRed = const Color(0xFFE63946);
  final Color _darkRed = const Color(0xFF9D0208);
  final Color _emergencyBlue = const Color(0xFF1D3557);
  final Color _accentBlue = const Color(0xFF457B9D);
  final Color _lightBlue = const Color(0xFFA8DADC);
  final Color _white = const Color(0xFFF8F9FA);
  final Color _surfaceWhite = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);
  final Color _successGreen = const Color(0xFF2A9D8F);
  final Color _warningOrange = const Color(0xFFE9C46A);
  final Color _infoCyan = const Color(0xFF4CC9F0);

  // Gradients
  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
    stops: [0.0, 0.8],
  );

  final LinearGradient _emergencyGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFFD00000)],
  );

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Staggered entrance animations
  late AnimationController _staggerController;
  late Animation<double> _slideUp1;
  late Animation<double> _slideUp2;
  late Animation<double> _scaleIn;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Staggered entrance for cards
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _slideUp1 = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );

    _slideUp2 = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    );

    _scaleIn = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        _staggerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _navigateToEventSelection() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EventSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToSubmittedReports() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SubmittedReportsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    final eventsProvider = Provider.of<Events>(context, listen: false);
    eventsProvider.refreshEvents();
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: RefreshIndicator.adaptive(
        onRefresh: _refreshData,
        color: _primaryRed,
        strokeWidth: 3,
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Header - UNCHANGED
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 20,
                        left: 24,
                        right: 24,
                        bottom: 24,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.emergency_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Incident Reports",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      "Real-time monitoring system",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainActionCards(),
                          const SizedBox(height: 32),
                          _buildEventStatusSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN ACTION CARDS – unchanged
  // ---------------------------------------------------------------------------
  Widget _buildMainActionCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),

        AnimatedBuilder(
          animation: _slideUp1,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 28 * (1 - _slideUp1.value)),
              child: Opacity(
                opacity: _slideUp1.value,
                child: _buildQuickResponseCard(),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        AnimatedBuilder(
          animation: _slideUp2,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 28 * (1 - _slideUp2.value)),
              child: Opacity(
                opacity: _slideUp2.value,
                child: _buildSubmittedReportsCard(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // QUICK RESPONSE – unchanged
  // ---------------------------------------------------------------------------
  Widget _buildQuickResponseCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final glowOpacity = 0.28 + (_pulseAnimation.value * 0.18);

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryRed.withOpacity(glowOpacity),
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Color(0xFFE63946),
                    Color(0xFFD00000),
                    Color(0xFFB20000)
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: _navigateToEventSelection,
                  borderRadius: BorderRadius.circular(24),
                  splashColor: Colors.white.withOpacity(0.18),
                  highlightColor: Colors.white.withOpacity(0.08),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_alert_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quick Response',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Submit an incident report instantly',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.88),
                                      fontWeight: FontWeight.w500,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.15),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 13),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: _primaryRed,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Add Report',
                                      style: TextStyle(
                                        color: _primaryRed,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Text(
                              'Tap anywhere →',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // VIEW REPORTS – unchanged
  // ---------------------------------------------------------------------------
  Widget _buildSubmittedReportsCard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.watch<Events>().events,
      builder: (context, snapshot) {
        int totalReports = 0;
        if (snapshot.hasData) {
          totalReports = snapshot.data!.length;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _surfaceWhite,
            border: Border.all(
              color: _accentBlue.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _navigateToSubmittedReports,
              borderRadius: BorderRadius.circular(20),
              splashColor: _accentBlue.withOpacity(0.08),
              highlightColor: _accentBlue.withOpacity(0.04),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _accentBlue.withOpacity(0.1),
                        border: Border.all(
                          color: _accentBlue.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.assignment_rounded,
                        color: _accentBlue,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Reports',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Browse all submitted incidents',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (totalReports > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$totalReports report${totalReports != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _accentBlue,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 24),
                        const SizedBox(height: 8),

                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accentBlue.withOpacity(0.08),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: _accentBlue,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // EVENT STATUS SECTION – three uniform status cards in a row.
  // ---------------------------------------------------------------------------
  Widget _buildEventStatusSection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.watch<Events>().events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingSkeleton();
        }

        final events = snapshot.data!.map((data) {
          return Event.fromMap(data, data['eventid']);
        }).toList();

        final completedCount =
            events.where((e) => e.status.toLowerCase() == 'completed').length;
        final ongoingCount =
            events.where((e) => e.status.toLowerCase() == 'ongoing').length;
        final upcomingCount =
            events.where((e) => e.status.toLowerCase() == 'upcoming').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Status Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                // Total events badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _textPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${events.length} event${events.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Three equal-width status cards ──
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    title: 'Ongoing',
                    count: ongoingCount,
                    color: _primaryRed,
                    icon: Icons.radio_button_checked,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    title: 'Upcoming',
                    count: upcomingCount,
                    color: _infoCyan,
                    icon: Icons.upcoming_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    title: 'Completed',
                    count: completedCount,
                    color: _successGreen,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS CARD – unified card widget used by all three statuses
  // ---------------------------------------------------------------------------
  Widget _buildStatusCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon row + live badge (ongoing only) ──
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color.withOpacity(0.12),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 22),
              ),
            ),

            const SizedBox(height: 16),

            // ── Title ──
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 10),

            // ── Event count (large number) ──
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'event${count != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOADING SKELETON – updated to match new 3-column layout
  // ---------------------------------------------------------------------------
  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header placeholder
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 180,
              height: 24,
              decoration: BoxDecoration(
                color: _lightBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              width: 70,
              height: 28,
              decoration: BoxDecoration(
                color: _lightBlue.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Three skeleton cards
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                child: Container(
                  height: 210,
                  decoration: BoxDecoration(
                    color: _lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // icon placeholder
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _lightBlue.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // title
                        Container(
                          width: 55,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _lightBlue.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // big number
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _lightBlue.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}