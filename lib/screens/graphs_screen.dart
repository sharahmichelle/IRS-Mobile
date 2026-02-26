import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/models/news_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/providers/news_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/submitted_reports_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_general_screen.dart';
import 'package:upm_drrm_irs_mobile/screens/news_detail_screen.dart';

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
    transform: GradientRotation(0.5),
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

  // News filter state
  String _selectedCategory = 'All';

  final _uuid = const Uuid();

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

    // Fetch news data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchNews();
    });

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

  void _navigateToAddReportGeneral() {
    final dummyEvent = Event(
      eventId: '',
      eventName: 'General Incident Report',
      location: '',
      status: 'ongoing',
      timeStampStart: DateTime.now(),
      timeStampEnd: DateTime.now().add(const Duration(hours: 1)),
      category: 'General',
      eventDescription: 'Unscheduled emergency or general incident report',
      incidentCommander: 'General',
      liasonOfficer: 'General',
      publicInformationOfficer: 'General',
      safetySecurityOfficer: 'General',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReportGeneralScreen(
          currentEvent: dummyEvent,
          isGeneralReport: true,
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    final eventsProvider = Provider.of<Events>(context, listen: false);
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    await Future.wait([
      eventsProvider.refreshEvents(),
      newsProvider.refreshNews(),
    ]);

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isRefreshing = false);
  }

  PreferredSizeWidget get _appBar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
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
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Home",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "UP MANILA DRRM-H IRS",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/favicon.png',
                        width: 18,
                        height: 18,
                        color: Colors.white,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
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
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainActionCards(),
                      const SizedBox(height: 32),
                      _buildCurrentNewsSection(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainActionCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Color(0xFFB20000),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: _navigateToAddReportGeneral,
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
                            InkWell(
                              onTap: _navigateToAddReportGeneral,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
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

  Widget _buildSubmittedReportsCard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.watch<Events>().events,
      builder: (context, snapshot) {
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

  Widget _buildCurrentNewsSection() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        final filteredNews = newsProvider.getNewsByCategory(_selectedCategory);

        // Category metadata for the custom dropdown
        final Map<String, Map<String, dynamic>> categoryMeta = {
          'All': {'icon': Icons.grid_view_rounded, 'color': _textPrimary},
          'Event': {'icon': Icons.event_rounded, 'color': _infoCyan},
          'Announcement': {'icon': Icons.campaign_rounded, 'color': _warningOrange},
          'Alert': {'icon': Icons.warning_rounded, 'color': _primaryRed},
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header with custom dropdown filter ──
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Current News',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),

                  // ── Category Filter Dropdown (add_report hazard style) ──
                  Builder(
                    builder: (context) {
                      final selected = categoryMeta[_selectedCategory]!;
                      final Color selectedColor = selected['color'] as Color;
                      final IconData selectedIcon = selected['icon'] as IconData;

                      return GestureDetector(
                        onTap: () async {
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final Offset offset = box.localToGlobal(Offset.zero);
                          final Size size = box.size;

                          final result = await showMenu<String>(
                            context: context,
                            color: _surfaceWhite,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: _lightBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy + size.height + 4,
                              offset.dx + size.width,
                              offset.dy + size.height + 4 + 300,
                            ),
                            items: categoryMeta.entries.map((entry) {
                              final Color color = entry.value['color'] as Color;
                              final IconData icon = entry.value['icon'] as IconData;
                              return PopupMenuItem<String>(
                                value: entry.key,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: color.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          icon,
                                          size: 18,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );

                          if (result != null) {
                            setState(() {
                              _selectedCategory = result;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _surfaceWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _lightBlue.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: selectedColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    selectedIcon,
                                    size: 18,
                                    color: selectedColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedCategory,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: _textSecondary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Loading, error, or news list ──
            if (newsProvider.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: _primaryRed),
                ),
              )
            else if (newsProvider.error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: _primaryRed, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load news',
                        style: TextStyle(
                          fontSize: 16,
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        newsProvider.error!,
                        style: TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredNews.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.newspaper_outlined,
                          color: _textSecondary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No news in this category',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredNews.length,
                itemBuilder: (context, index) {
                  final news = filteredNews[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: index < filteredNews.length - 1 ? 16 : 0,
                            ),
                            child: _buildVerticalNewsCard(news: news),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalNewsCard({required News news}) {
    final category = news.category;
    final headline = news.title;
    final description = news.content;

    Color categoryColor;
    IconData categoryIcon;

    switch (category.toLowerCase()) {
      case 'update':
        categoryColor = _successGreen;
        categoryIcon = Icons.system_update_rounded;
        break;
      case 'event':
        categoryColor = _infoCyan;
        categoryIcon = Icons.event_rounded;
        break;
      case 'tech':
        categoryColor = _accentBlue;
        categoryIcon = Icons.computer_rounded;
        break;
      case 'alert':
        categoryColor = _primaryRed;
        categoryIcon = Icons.warning_rounded;
        break;
      case 'announcement':
        categoryColor = _warningOrange;
        categoryIcon = Icons.campaign_rounded;
        break;
      default:
        categoryColor = _textSecondary;
        categoryIcon = Icons.info_rounded;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accentBlue.withOpacity(0.18),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    NewsDetailScreen(news: news),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCubic;
                  final tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: _accentBlue.withOpacity(0.08),
          highlightColor: _accentBlue.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Category badge ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: categoryColor,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: categoryColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Headline ──
                Text(
                  headline,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // ── Description ──
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // ── Read more ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Read more',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: categoryColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: categoryColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}