import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
/* import 'package:cloud_firestore/cloud_firestore.dart'; */
import 'package:upm_drrm_irs_mobile/models/event_calendar_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/screens/add_report_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  // 2025 Modern Color Scheme
  static const Color _primaryRed = Color(0xFFE63946); // Vibrant emergency red
  final Color _accentBlue = const Color(0xFF457B9D); // Medium blue
  final Color _lightBlue = const Color(0xFFA8DADC); // Light blue accent
  final Color _white = const Color(0xFFF8F9FA); // Pure white background
  final Color _surfaceWhite = const Color(0xFFFFFFFF); // Card surface
  final Color _textPrimary = const Color(0xFF212529); // Near black
  final Color _textSecondary = const Color(0xFF6C757D); // Medium gray
  final Color _successGreen = const Color(0xFF2A9D8F); // Teal green
  final Color _warningOrange = const Color(0xFFE9C46A); // Amber
  final Color _infoCyan = const Color(0xFF4CC9F0); // Bright cyan
  final Color _surfaceGray = const Color(0xFFF1F5F9); // Light gray surface
  final Color _borderColor = const Color(0xFFE2E8F0);

  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
    stops: [0.0, 0.8],
    transform: GradientRotation(0.5),
  );

  final LinearGradient _emergencyGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE63946), Color(0xFFD00000)],
  );

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  CalendarView _currentView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();
  DateTime? _selectedDate;
  String? _selectedFilter; // New: For dropdown filter

  // Filter options with icons and colors
  final List<Map<String, dynamic>> _filterOptions = [
    {
      'value': 'all',
      'label': 'All Events',
      'icon': Icons.all_inclusive_rounded,
      'color': _primaryRed,
    },
    {
      'value': 'fire',
      'label': 'Fire',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFF9D0208),
    },
    {
      'value': 'typhoon',
      'label': 'Typhoon',
      'icon': Icons.storm_rounded,
      'color': const Color(0xFFE63946),
    },
    {
      'value': 'earthquake',
      'label': 'Earthquake',
      'icon': Icons.landscape_rounded,
      'color': const Color(0xFFE9C46A),
    },
    {
      'value': 'flood',
      'label': 'Flood',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF457B9D),
    },
    {
      'value': 'general',
      'label': 'General',
      'icon': Icons.emergency_rounded,
      'color': _primaryRed,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
    _selectedFilter = 'all'; // Default to "All Events"
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            backgroundColor: _white,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: _white,
              child: Column(
                children: [
                  // Modern Header - EXTENDS TO TOP
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
                              Icons.calendar_month_rounded,
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
                                "Events Schedule",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "Monitor events and emergency schedules",
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
                  
                  // Main Content with SafeArea
                  Expanded(
                    child: SafeArea(
                      top: false,
                      bottom: true,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          
                          // Filter Dropdown with Modern Design
                          _buildEventFilterDropdown(),
                          const SizedBox(height: 16),
                          
                          // View Selector with Modern Design
                          _buildModernViewSelector(),
                          const SizedBox(height: 16),
                          
                          // Selected Date Info (if any)
                          if (_selectedDate != null) _buildSelectedDateInfo(),

                          // Calendar Container
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _surfaceWhite,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: _primaryRed.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: StreamBuilder<List<Map<String, dynamic>>>(
                                    stream: eventsProvider.events,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return _buildModernLoadingState();
                                      }

                                      if (snapshot.hasError) {
                                        return _buildModernErrorState(snapshot.error.toString());
                                      }

                                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return _buildModernEmptyState();
                                      }

                                      // Filter events based on selected filter
                                      List<Event> events = snapshot.data!
                                          .map((data) => Event.fromMap(data, data['eventid']))
                                          .toList();

                                      if (_selectedFilter != 'all') {
                                        events = events.where((event) => 
                                          event.category.toLowerCase() == _selectedFilter
                                        ).toList();
                                      }

                                      if (events.isEmpty) {
                                        return _buildNoEventsForFilterState();
                                      }

                                      final eventDataSource = EventDataSource(events);

                                      return Stack(
                                        children: [
                                          SfCalendar(
                                            controller: _calendarController,
                                            view: _currentView,
                                            dataSource: eventDataSource,
                                            allowedViews: [
                                              CalendarView.month,
                                              CalendarView.schedule,
                                            ],
                                            // ... rest of your SfCalendar configuration
                                            // (all the existing SfCalendar properties remain the same)
                                            todayTextStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: _white,
                                            ),
                                            monthViewSettings: MonthViewSettings(
                                              appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                                              numberOfWeeksInView: 6,
                                              showTrailingAndLeadingDates: true,
                                              monthCellStyle: MonthCellStyle(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: _textPrimary,
                                                  letterSpacing: -0.3,
                                                ),
                                                trailingDatesTextStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: _textSecondary.withOpacity(0.3),
                                                ),
                                                leadingDatesTextStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: _textSecondary.withOpacity(0.3),
                                                ),
                                                todayBackgroundColor: _primaryRed,
                                                backgroundColor: _surfaceGray,
                                                trailingDatesBackgroundColor: _surfaceGray.withOpacity(0.5),
                                                leadingDatesBackgroundColor: _surfaceGray.withOpacity(0.5),
                                              ),
                                              showAgenda: true,
                                              agendaViewHeight: 150,
                                              agendaStyle: AgendaStyle(
                                                dateTextStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: _textPrimary,
                                                ),
                                                dayTextStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: _textSecondary,
                                                ),
                                                appointmentTextStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                backgroundColor: _white,
                                              ),
                                            ),
                                            scheduleViewSettings: ScheduleViewSettings(
                                              monthHeaderSettings: MonthHeaderSettings(
                                                backgroundColor: _primaryRed,
                                              ),
                                              appointmentItemHeight: 70,
                                              hideEmptyScheduleWeek: true,
                                              appointmentTextStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            timeSlotViewSettings: TimeSlotViewSettings(
                                              timeTextStyle: TextStyle(
                                                color: _textSecondary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              dateFormat: 'd',
                                              dayFormat: 'EEE',
                                              timeFormat: 'HH:mm',
                                              timeIntervalHeight: 70,
                                              timeIntervalWidth: 60,
                                              timeInterval: const Duration(minutes: 30),
                                              timeRulerSize: 60,
                                            ),
                                            showTodayButton: true,
                                            todayHighlightColor: _primaryRed,
                                            selectionDecoration: BoxDecoration(
                                              color: _primaryRed.withOpacity(0.15),
                                              border: Border.all(
                                                color: _primaryRed,
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            showNavigationArrow: false,
                                            showDatePickerButton: true,
                                            headerHeight: 70,
                                            headerStyle: CalendarHeaderStyle(
                                              textAlign: TextAlign.center,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.5,
                                              ),
                                              backgroundColor: _primaryRed,
                                            ),
                                            cellBorderColor: _borderColor.withOpacity(0.5),
                                            appointmentTextStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                            appointmentBuilder: (context, details) {
                                              if (details.appointments.isEmpty) return Container();
                                              final event = details.appointments.first as Event;
                                              return MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showModernEventDetails(event);
                                                  },
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          _getEventColor(event),
                                                          _getEventColor(event).withOpacity(0.8),
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: _getEventColor(event).withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                      child: Center(
                                                        child: Text(
                                                          event.eventName,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            onTap: (calendarTapDetails) {
                                              if (calendarTapDetails.appointments != null &&
                                                  calendarTapDetails.appointments!.isNotEmpty) {
                                                final event = calendarTapDetails.appointments!.first;
                                                _showModernEventDetails(event);
                                              } else if (calendarTapDetails.date != null) {
                                                setState(() {
                                                  _selectedDate = calendarTapDetails.date;
                                                });
                                              }
                                            },
                                            onLongPress: (calendarLongPressDetails) {
                                              if (calendarLongPressDetails.date != null) {
                                                _showDateEventsQuickView(calendarLongPressDetails.date!);
                                              }
                                            },
                                          ),
                                          
                                          // Quick jump to today button
                                          Positioned(
                                            bottom: 16,
                                            right: 16,
                                            child: FloatingActionButton(
                                              onPressed: () {
                                                _calendarController.selectedDate = DateTime.now();
                                              },
                                              backgroundColor: _primaryRed,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Icon(Icons.today, color: Colors.white),
                                              elevation: 8,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventFilterDropdown() {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: _surfaceWhite,
          elevation: 8,
          menuMaxHeight: 350,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.filter_alt_rounded,
              color: _primaryRed,
              size: 20,
            ),
          ),
          selectedItemBuilder: (context) {
            return _filterOptions.map((option) {
              final Color color = option['color'] as Color;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          items: _filterOptions.map((option) {
            final Color color = option['color'] as Color;
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedFilter == option['value'] 
                      ? color.withOpacity(0.1) 
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          option['icon'] as IconData,
                          size: 20,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          if (_selectedFilter == option['value']) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Showing ${option['label']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_selectedFilter == option['value'])
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFilter = newValue;
            });
          },
        ),
      ),
    );
  }

  // New method: Build state when no events for selected filter
  Widget _buildNoEventsForFilterState() {
    final selectedOption = _filterOptions.firstWhere(
      (option) => option['value'] == _selectedFilter,
      orElse: () => _filterOptions.first,
    );
    final Color color = selectedOption['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  selectedOption['icon'] as IconData,
                  size: 56,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${selectedOption['label']} Found',
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
                'There are no ${selectedOption['label'].toString().toLowerCase()} scheduled at the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'all';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accentBlue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_off_rounded, color: _accentBlue, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Show All Events',
                      style: TextStyle(
                        color: _accentBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

  // The rest of your existing methods remain exactly the same...
  Widget _buildSelectedDateInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryRed.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: _primaryRed, size: 20),
              const SizedBox(width: 8),
              Text(
                'Selected:',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedDate != null 
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'None',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedDate = null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Clear',
                style: TextStyle(
                  color: _primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernViewSelector() {
    final views = [
      {
        'view': CalendarView.month,
        'label': 'Month View',
        'icon': Icons.calendar_view_month_rounded,
        'description': 'See monthly overview',
      },
      {
        'view': CalendarView.schedule,
        'label': 'Schedule View',
        'icon': Icons.list_alt_rounded,
        'description': 'Detailed timeline',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: views.map((viewData) {
          final isActive = _currentView == viewData['view'];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentView = viewData['view'] as CalendarView;
                  _calendarController.view = _currentView;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: isActive ? _emergencyGradient : null,
                  color: isActive ? null : _surfaceGray,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _primaryRed.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      viewData['icon'] as IconData,
                      size: 20,
                      color: isActive ? _white : _textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewData['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive ? _white : _textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }



  void _showDateEventsQuickView(DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Events on ${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Here you would fetch and display events for this date
            // For now, show a placeholder
            Text(
              'Long press on any date to see events quickly',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Rest of your existing methods remain exactly the same...
  Widget _buildModernLoadingState() {
    return Center(
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
                    Icons.calendar_month_rounded,
                    color: _primaryRed,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Emergency Events',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching incident schedules...',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernErrorState(String error) {
    return Container(
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
                  colors: [_primaryRed.withOpacity(0.1), _white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: _primaryRed,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Connection Error',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 24,
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
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 56,
              width: 220,
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
                  onTap: () => setState(() {}),
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: _white, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'RETRY CONNECTION',
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
    );
  }

  Widget _buildModernEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
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
                  Icons.event_available_rounded,
                  size: 64,
                  color: _accentBlue.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Scheduled Incidents',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Incidents will appear here when they are scheduled. Stay prepared!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 15,
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
                      color: _accentBlue, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Events will appear in real-time',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 14,
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

  void _showModernEventDetails(dynamic appointment) {
    if (appointment is! Event) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                // Event Header with Status
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: _getEventGradient(appointment),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getEventColor(appointment).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _getEventIcon(appointment),
                          color: _white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.eventName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusBackgroundColor(appointment.status),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getStatusColor(appointment.status).withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(appointment.status),
                                  size: 16,
                                  color: _getStatusColor(appointment.status),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  appointment.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _getStatusColor(appointment.status),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Event Details Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildModernDetailRow(
                        icon: Icons.category_rounded,
                        iconColor: _accentBlue,
                        title: 'Category',
                        value: appointment.category,
                      ),
                      const SizedBox(height: 20),
                      _buildModernDetailRow(
                        icon: Icons.access_time_rounded,
                        iconColor: _warningOrange,
                        title: 'Time',
                        value: '${_formatDateTime(appointment.timeStampStart)} - ${_formatDateTime(appointment.timeStampEnd)}',
                      ),
                      const SizedBox(height: 20),
                      _buildModernDetailRow(
                        icon: Icons.location_on_rounded,
                        iconColor: _primaryRed,
                        title: 'Location',
                        value: appointment.location,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Description Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _infoCyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.description_rounded,
                                color: _infoCyan,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        appointment.eventDescription,
                        style: TextStyle(
                          fontSize: 15,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Add Report Button
                Builder(
                  builder: (context) {
                    final bool isReportingDisabled = appointment.status.toLowerCase() == 'upcoming' || appointment.status.toLowerCase() == 'completed';
                    final LinearGradient buttonGradient = isReportingDisabled
                        ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600])
                        : _emergencyGradient;
                    final Color shadowColor = isReportingDisabled ? Colors.grey.shade400.withOpacity(0.3) : _primaryRed.withOpacity(0.5);

                    return Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isReportingDisabled ? null : () {
                            Navigator.pop(context); // Close the modal first
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReportScreen(currentEvent: appointment),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isReportingDisabled ? Icons.block_rounded : Icons.add_circle_rounded,
                                  color: _white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isReportingDisabled ? 'REPORTING UNAVAILABLE' : 'ADD REPORT',
                                  style: TextStyle(
                                    color: _white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Icon(icon, size: 24, color: iconColor),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getEventColor(Event appointment) {
    switch (appointment.category.toLowerCase()) {
      case 'flood':
        return const Color(0xFF457B9D); // Blue
      case 'earthquake':
        return const Color(0xFFE9C46A); // Amber
      case 'typhoon':
        return const Color(0xFFE63946); // Red
      case 'fire':
        return const Color(0xFF9D0208); // Dark Red
      default:
        return _primaryRed;
    }
  }

  LinearGradient _getEventGradient(Event appointment) {
    final color = _getEventColor(appointment);
    return LinearGradient(
      colors: [color, color.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getEventIcon(Event appointment) {
    switch (appointment.category.toLowerCase()) {
      case 'flood':
        return Icons.water_drop_rounded;
      case 'earthquake':
        return Icons.landscape_rounded;
      case 'typhoon':
        return Icons.storm_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.emergency_rounded;
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
      case 'critical':
        return _primaryRed;
      default:
        return _textSecondary;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _successGreen.withOpacity(0.15);
      case 'ongoing':
        return _warningOrange.withOpacity(0.15);
      case 'upcoming':
        return _infoCyan.withOpacity(0.15);
      case 'critical':
        return _primaryRed.withOpacity(0.15);
      default:
        return _textSecondary.withOpacity(0.15);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'ongoing':
        return Icons.pending_actions_rounded;
      case 'upcoming':
        return Icons.schedule_rounded;
      case 'critical':
        return Icons.priority_high_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}