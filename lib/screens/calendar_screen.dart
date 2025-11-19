import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upm_drrm_irs_mobile/models/event_calendar_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';
import 'package:upm_drrm_irs_mobile/widgets/screen_header.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Modern color scheme
  final Color primaryColor = Color(0xFFA11D1C);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = Color(0xFF1E293B);
  final Color textSecondary = Color(0xFF64748B);
  final Color accentColor = Color(0xFF0EA5E9);

  CalendarView _currentView = CalendarView.month;
  CalendarController _calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<Events>(context, listen: false);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ScreenHeader(primaryColor: primaryColor, textPrimary: textPrimary, textSecondary: textSecondary, title: "Calendar", subtitle: "Monitor events and schedules", icon: Icons.calendar_month_rounded),
            const SizedBox(height: 16),
            
            // View Selector
            _buildViewSelector(),
            const SizedBox(height: 16),
            
            // Calendar Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: eventsProvider.events,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoadingState();
                        }

                        if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error.toString());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        final events = snapshot.data!.docs
                            .map((doc) => Event.fromFirestore(doc))
                            .toList();

                        final eventDataSource = EventDataSource(events);

                        return SfCalendar(
                          controller: _calendarController,
                          view: _currentView,
                          dataSource: eventDataSource,
                          allowedViews: [
                            CalendarView.month,
                            CalendarView.week,
                            CalendarView.day,
                            CalendarView.schedule,
                          ],
                          monthViewSettings: MonthViewSettings(
                            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                            numberOfWeeksInView: 6,
                            showTrailingAndLeadingDates: true,
                            monthCellStyle: MonthCellStyle(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: textPrimary,
                              ),
                              trailingDatesTextStyle: TextStyle(
                                fontSize: 12,
                                color: textSecondary.withOpacity(0.5),
                              ),
                              leadingDatesTextStyle: TextStyle(
                                fontSize: 12,
                                color: textSecondary.withOpacity(0.5),
                              ),
                            ),
                          ),
                          timeSlotViewSettings: TimeSlotViewSettings(
                            timeTextStyle: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                            dateFormat: 'd',
                            dayFormat: 'EEE',
                            timeFormat: 'HH:mm',
                          ),
                          todayHighlightColor: primaryColor,
                          selectionDecoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            border: Border.all(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          showNavigationArrow: true,
                          showDatePickerButton: true,
                          headerHeight: 70,
                          headerStyle: CalendarHeaderStyle(
                            textAlign: TextAlign.center,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            backgroundColor: primaryColor,
                          ),
                          cellBorderColor: Color(0xFFE2E8F0),
                          appointmentTextStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          onTap: (calendarTapDetails) {
                            if (calendarTapDetails.appointments != null &&
                                calendarTapDetails.appointments!.isNotEmpty) {
                              _showEventDetails(calendarTapDetails.appointments!.first);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        backgroundColor: primaryColor,
        child: Icon(Icons.add_rounded, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildViewSelector() {
    final views = [
      {'view': CalendarView.month, 'label': 'Month', 'icon': Icons.calendar_view_month_rounded},
      {'view': CalendarView.week, 'label': 'Week', 'icon': Icons.calendar_view_week_rounded},
      {'view': CalendarView.day, 'label': 'Day', 'icon': Icons.calendar_today_rounded},
      {'view': CalendarView.schedule, 'label': 'Schedule', 'icon': Icons.list_alt_rounded},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
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
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isActive
                      ? Border.all(color: primaryColor.withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      viewData['icon'] as IconData,
                      size: 20,
                      color: isActive ? primaryColor : textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewData['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? primaryColor : textSecondary,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading events...',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load events',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(color: Colors.white),
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_rounded,
              size: 48,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Events Scheduled',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add events to see them on your calendar',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addNewEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Add First Event',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(dynamic appointment) {
    if (appointment is! Event) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getEventColor(appointment),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEventDetailRow(Icons.category_rounded, 'Category', appointment.category ?? 'N/A'),
            _buildEventDetailRow(Icons.access_time_rounded, 'Time', 
                '${_formatDateTime(appointment.timeStampStart)} - ${_formatDateTime(appointment.timeStampEnd)}'),
            _buildEventDetailRow(Icons.description_rounded, 'Description', appointment.description ?? 'No description'),
            _buildEventDetailRow(Icons.star_rounded, 'Status', appointment.status ?? 'N/A'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(Event appointment) {
    // Customize event colors based on category or status
    switch (appointment.category?.toLowerCase()) {
      case 'flood':
        return Color(0xFF0EA5E9); // Blue
      case 'earthquake':
        return Color(0xFFF59E0B); // Amber
      case 'typhoon':
        return Color(0xFFEF4444); // Red
      case 'fire':
        return Color(0xFFDC2626); // Dark Red
      default:
        return primaryColor;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _addNewEvent() {
    // Implement add event functionality
    print('Add new event pressed');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AddEventScreen()));
  }
}