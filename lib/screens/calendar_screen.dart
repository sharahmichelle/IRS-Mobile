import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color.fromARGB(255, 161, 29, 28);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SfCalendar(
            view: CalendarView.month,
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              numberOfWeeksInView: 5,
            ),
            todayHighlightColor: primaryColor,
            cellBorderColor: primaryColor,
            selectionDecoration: BoxDecoration(
              color: primaryColor.withOpacity(0.3),
              border: Border.all(
                color: primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            // Header customization
            showNavigationArrow: true,
            showDatePickerButton: true,
            headerHeight: 60,
            headerStyle: CalendarHeaderStyle(
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: primaryColor,
            ),
          ),
        ),
    SizedBox(height: 20,),
    ]);
    
  }
}