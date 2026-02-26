import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:upm_drrm_irs_mobile/models/event_calendar_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_ics_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  // Simplified Color Scheme - Easy on the eyes
  static const Color _primaryRed = Color(0xFFE63946);
  final Color _accentBlue = const Color(0xFF457B9D);
  final Color _lightBlue = const Color(0xFFA8DADC);
  final Color _white = const Color(0xFFF8F9FA);
  final Color _surfaceWhite = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF212529);
  final Color _textSecondary = const Color(0xFF6C757D);
  final Color _successGreen = const Color(0xFF2A9D8F);
  final Color _warningOrange = const Color(0xFFE9C46A);
  final Color _infoCyan = const Color(0xFF4CC9F0);
  final Color _surfaceGray = const Color(0xFFF1F5F9);
  final Color _borderColor = const Color(0xFFE2E8F0);

  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
    stops: [0.0, 0.8],
    transform: GradientRotation(0.5),
  );

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  CalendarView _currentView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();
  DateTime? _selectedDate;
  String? _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Updated filter options - Training, Drill, All
  final List<Map<String, dynamic>> _filterOptions = [
    {
      'value': 'all',
      'label': 'All Events',
      'icon': Icons.event_available_rounded,
      'color': const Color(0xFF457B9D),
    },
    {
      'value': 'training',
      'label': 'Training',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF2A9D8F),
    },
    {
      'value': 'drill',
      'label': 'Drill',
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFFE9C46A),
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
    _selectedFilter = 'all';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
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
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Schedules",
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
    final eventsProvider = Provider.of<Events>(context, listen: false);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Scaffold(
            appBar: _appBar,
            backgroundColor: _white,
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Simplified Filter Dropdown
                  _buildSimpleFilterDropdown(),
                  const SizedBox(height: 16),
                  
                  // Simplified View Toggle
                  _buildSimpleViewToggle(),
                  const SizedBox(height: 16),
                  
                  // Main Calendar/List Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: eventsProvider.events,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingState();
                          }

                          if (snapshot.hasError) {
                            return _buildErrorState();
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildEmptyState();
                          }

                          // Filter events
                          List<Event> events = snapshot.data!
                              .map((data) => Event.fromMap(data, data['event_id']))
                              .toList();

                          // Exclude general incident reports (events with category 'fire', 'earthquake', 'flood', 'general')
                          events = events.where((event) =>
                            !['fire', 'earthquake', 'flood', 'general'].contains(event.category.toLowerCase())
                          ).toList();

                          if (_selectedFilter != 'all') {
                            events = events.where((event) =>
                              event.category.toLowerCase() == _selectedFilter
                            ).toList();
                          }

                          if (events.isEmpty) {
                            return _buildNoEventsForFilterState();
                          }

                          // Show either calendar or list view
                          if (_currentView == CalendarView.schedule) {
                            return _buildUpcomingEventsList(events);
                          } else {
                            return _buildCalendarView(events);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleFilterDropdown() {
    final selectedOption = _filterOptions.firstWhere(
      (o) => o['value'] == _selectedFilter,
      orElse: () => _filterOptions.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () async {
              final RenderBox box = context.findRenderObject() as RenderBox;
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
                items: _filterOptions.map((option) {
                  final Color color = option['color'] as Color;
                  return PopupMenuItem<String>(
                    value: option['value'] as String,
                    child: Row(
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
                              option['icon'] as IconData,
                              size: 18,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option['label'] as String,
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
                  _selectedFilter = result;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (selectedOption['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (selectedOption['color'] as Color).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        selectedOption['icon'] as IconData,
                        size: 18,
                        color: selectedOption['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedOption['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                  ),
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
    );
  }

  // Simplified View Toggle - Just two big buttons
  Widget _buildSimpleViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildViewButton(
              label: 'Calendar',
              isActive: _currentView == CalendarView.month,
              onTap: () {
                setState(() {
                  _currentView = CalendarView.month;
                });
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildViewButton(
              label: 'List',
              isActive: _currentView == CalendarView.schedule,
              onTap: () {
                setState(() {
                  _currentView = CalendarView.schedule;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? _primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calendar View - Clean and simple with color-coded dots
  Widget _buildCalendarView(List<Event> events) {
    // Create a custom data source with color-coded events
    final eventDataSource = ColorCodedEventDataSource(events);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SfCalendar(
          controller: _calendarController,
          view: CalendarView.month,
          dataSource: eventDataSource,
          firstDayOfWeek: 7, // Sunday
          showNavigationArrow: true,
          showDatePickerButton: false,
          showTodayButton: false,
          headerHeight: 60,
          headerStyle: CalendarHeaderStyle(
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: _surfaceWhite,
          ),
          viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textSecondary,
            ),
            backgroundColor: _surfaceGray,
          ),
          monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
            showAgenda: false,
            monthCellStyle: MonthCellStyle(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              trailingDatesTextStyle: TextStyle(
                fontSize: 16,
                color: _textSecondary.withOpacity(0.3),
              ),
              leadingDatesTextStyle: TextStyle(
                fontSize: 16,
                color: _textSecondary.withOpacity(0.3),
              ),
              todayBackgroundColor: _primaryRed,
              todayTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          cellBorderColor: _borderColor,
          todayHighlightColor: _primaryRed,
          selectionDecoration: BoxDecoration(
            border: Border.all(color: _primaryRed, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: (calendarTapDetails) {
            // Get the clicked date from the calendar tap details
            final clickedDate = calendarTapDetails.date!;
            
            if (calendarTapDetails.appointments != null &&
                calendarTapDetails.appointments!.isNotEmpty) {
              // Handle multiple events on the same day
              if (calendarTapDetails.appointments!.length > 1) {
                _showMultipleEventsDialog(
                  calendarTapDetails.appointments!.cast<Event>(), 
                  clickedDate
                );
              } else {
                final event = calendarTapDetails.appointments!.first as Event;
                _showEventDetails(event);
              }
            }
          },
        ),
      ),
    );
  }

  // Show dialog for multiple events on the same day
  void _showMultipleEventsDialog(List<Event> events, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.event_note, color: _primaryRed, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Events on ${_formatDate(selectedDate)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${events.length} drills/training scheduled',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Events List
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                shrinkWrap: true,
                itemCount: events.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildCompactEventCard(event);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact event card for multi-event dialog
  Widget _buildCompactEventCard(Event event) {
    final eventColor = _getEventColor(event);
    
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showEventDetails(event);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: eventColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getEventIcon(event),
                color: eventColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: _textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(event.timeStampStart),
                        style: TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: eventColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: eventColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _textSecondary, size: 24),
          ],
        ),
      ),
    );
  }

  // Upcoming & Ongoing Events List - Simple scrollable list
  Widget _buildUpcomingEventsList(List<Event> events) {
    // Sort events by date - ongoing and upcoming
    final now = DateTime.now();
    final relevantEvents = events.where((e) => 
      // Include ongoing events (started but not ended)
      (e.timeStampStart.isBefore(now) && e.timeStampEnd.isAfter(now)) ||
      // Include upcoming events (haven't started yet)
      e.timeStampStart.isAfter(now)
    ).toList()..sort((a, b) {
      // Sort ongoing events first, then by start time
      final aIsOngoing = a.timeStampStart.isBefore(now) && a.timeStampEnd.isAfter(now);
      final bIsOngoing = b.timeStampStart.isBefore(now) && b.timeStampEnd.isAfter(now);
      
      if (aIsOngoing && !bIsOngoing) return -1;
      if (!aIsOngoing && bIsOngoing) return 1;
      return a.timeStampStart.compareTo(b.timeStampStart);
    });

    // Filter by search query
    final filteredEvents = _searchQuery.isEmpty
        ? relevantEvents
        : relevantEvents.where((event) =>
            event.eventName.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    if (filteredEvents.isEmpty) {
      return _searchQuery.isEmpty 
          ? _buildNoUpcomingEvents() 
          : _buildNoSearchResults();
    }

    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 2),
      ),
      child: Column(
        children: [
          // Header with Search
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surfaceGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'List of Drills/Training',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showSearchDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.search,
                          color: _primaryRed,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search Query Display (if searching)
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: _borderColor),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: _textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Searching for: "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: Icon(Icons.close, size: 18, color: _primaryRed),
                  ),
                ],
              ),
            ),
          // Events List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                final isOngoing = event.timeStampStart.isBefore(now) && 
                                  event.timeStampEnd.isAfter(now);
                return _buildSimpleEventCard(event, isOngoing: isOngoing);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Simple Event Card - Easy to read
  Widget _buildSimpleEventCard(Event event, {bool isOngoing = false}) {
    final eventColor = _getEventColor(event);
    final isToday = _isToday(event.timeStampStart);
    
    return GestureDetector(
      onTap: () => _showEventDetails(event),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Row(
        children: [
          // Date Badge
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: eventColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _getMonthAbbr(event.timeStampStart),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: eventColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.timeStampStart.day.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: eventColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: _textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(event.timeStampStart),
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: _textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
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
          const SizedBox(width: 12),
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: eventColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: eventColor,
              ),
            ),
          ),
        ],
      ),
          ),
        );
  }

  // Event Details Modal - Simple and clear
  void _showEventDetails(dynamic appointment) {
    if (appointment is! Event) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getEventColor(appointment).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getEventIcon(appointment),
                            color: _getEventColor(appointment),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            appointment.eventName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Details
                    _buildDetailItem(
                      icon: Icons.category,
                      label: 'Category',
                      value: appointment.category,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: 'Start Date',
                      value: _formatDate(appointment.timeStampStart),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: '${_formatTime(appointment.timeStampStart)} - ${_formatTime(appointment.timeStampEnd)}',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: appointment.location,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      icon: Icons.info,
                      label: 'Status',
                      value: appointment.status,
                    ),
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appointment.eventDescription,
                      style: TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Add Report Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: appointment.status.toLowerCase() == 'upcoming' ||
                                appointment.status.toLowerCase() == 'completed'
                            ? null
                            : () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddReportIcsScreen(
                                      currentEvent: appointment,
                                    ),
                                  ),
                                );
                              },
                        icon: Icon(Icons.add_circle, size: 22),
                        label: Text(
                          'Add Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Empty / Error States ────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryRed, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading drills or training...',
            style: TextStyle(fontSize: 16, color: _textSecondary),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _textSecondary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: _textSecondary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load drills or training',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please check your connection',
            style: TextStyle(fontSize: 14, color: _textSecondary),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _textSecondary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_outlined,
              size: 36,
              color: _textSecondary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Drills/Training Scheduled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Drills and training will appear here when scheduled',
            style: TextStyle(fontSize: 14, color: _textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsForFilterState() {
    final selectedOption = _filterOptions.firstWhere(
      (option) => option['value'] == _selectedFilter,
    );

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
              selectedOption['icon'] as IconData,
              size: 36,
              color: _textSecondary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${selectedOption['label']} Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try selecting a different filter',
            style: TextStyle(fontSize: 14, color: _textSecondary),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Show All Drills/Training'),
            style: TextButton.styleFrom(
              foregroundColor: _accentBlue,
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoUpcomingEvents() {
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
              Icons.event_busy_outlined,
              size: 36,
              color: _textSecondary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Drills/Training',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check back later for new drills or training sessions',
            style: TextStyle(fontSize: 14, color: _textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
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
              Icons.search_off_rounded,
              size: 36,
              color: _textSecondary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No events match "$_searchQuery"',
              style: TextStyle(fontSize: 14, color: _textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
            style: TextButton.styleFrom(
              foregroundColor: _primaryRed,
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with Icon
              Row(
                children: [
                  Text(
                    'Search Drills/Training',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Search Input Field
              TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  fontSize: 16,
                  color: _textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter drill/training name...',
                  hintStyle: TextStyle(
                    color: _textSecondary.withOpacity(0.6),
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: _surfaceGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _primaryRed, width: 2),
                  ),
                  prefixIcon: Icon(Icons.search, color: _textSecondary),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = _searchController.text.trim();
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  Color _getEventColor(Event event) {
    switch (event.category.toLowerCase()) {
      case 'training':
        return const Color(0xFF2A9D8F);
      case 'drill':
        return const Color(0xFFE9C46A);
      case 'general':
        return const Color(0xFFE63946);
      default:
        return _accentBlue;
    }
  }

  IconData _getEventIcon(Event event) {
    switch (event.category.toLowerCase()) {
      case 'training':
        return Icons.school_rounded;
      case 'drill':
        return Icons.fitness_center_rounded;
      case 'general':
        return Icons.info_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getMonthAbbr(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

// Custom Event Data Source with Color-Coded Events
class ColorCodedEventDataSource extends CalendarDataSource {
  ColorCodedEventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].timeStampStart;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].timeStampEnd;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    final event = appointments![index] as Event;
    switch (event.category.toLowerCase()) {
      case 'training':
        return const Color(0xFF2A9D8F);
      case 'drill':
        return const Color(0xFFE9C46A);
      case 'general':
        return const Color(0xFFE63946);
      default:
        return const Color(0xFF457B9D);
    }
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}