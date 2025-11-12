import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upm_drrm_irs_mobile/models/event_calendar_datasource.dart';
import 'package:upm_drrm_irs_mobile/models/event_model.dart';
import 'package:upm_drrm_irs_mobile/providers/events_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final Color primaryColor = const Color.fromARGB(255, 161, 29, 28);

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<Events>(context, listen: false);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: eventsProvider.events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error loading events: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No events available."));
        }

        final events = snapshot.data!.docs.map((doc) => Event.fromFirestore(doc)).toList();

        final eventDataSource = EventDataSource(events);

        return Column(
          children: [
            Expanded(
              child: SfCalendar(
                view: CalendarView.month,
                dataSource: eventDataSource,
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                  numberOfWeeksInView: 5,
                ),
                todayHighlightColor: primaryColor,
                cellBorderColor: primaryColor,
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
                selectionDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  border: Border.all(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:upm_drrm_irs_mobile/models/user_model.dart';
// import '../models/event_calendar_datasource.dart';
// import '../models/event_model.dart';

// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({super.key});

//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   late EventDataSource _eventDataSource;
//   final Color primaryColor = const Color.fromARGB(255, 161, 29, 28);

//   @override
//   void initState() {
//     super.initState();

//     // Sample data
//     final List<Event> events = [
//       Event(
//         eventId: '1',
//         category: 'Flood',
//         eventIntro: 'Flood Response Briefing',
//         observations: ['Emergency meeting for flood coordination.'],
//         scenario: 'Heavy rainfall causing flooding',
//         factSheet: 'Flood Response Protocol',
//         incidentCommander: User(),
//         liasonOfficer: User(),
//         timeStampStart: DateTime(2025, 10, 20, 9, 0),
//         timeStampEnd: DateTime(2025, 10, 21, 10, 0),
//         name: 'Flood Response Briefing',
//         description: 'Emergency meeting for flood coordination.',
//         status: 'Ongoing',
//         action: 'Review Plan', 
//         publicInformationOfficer: '', 
//         safetySecurityOfficer: '', 
//         location: '',
//       ),
//       Event(
//         eventId: '2',
//         category: 'Earthquake',
//         eventIntro: 'Earthquake Drill',
//         observations: ['Community earthquake preparedness drill.'],
//         scenario: 'Magnitude 6.5 earthquake',
//         factSheet: 'Earthquake Safety Guide',
//         incidentCommander: User(),
//         liasonOfficer: User(),
//         timeStampStart: DateTime(2025, 10, 20, 14, 0),
//         timeStampEnd: DateTime(2025, 10, 22, 16, 0),
//         name: 'Earthquake Drill',
//         description: 'Community earthquake preparedness drill.',
//         status: 'Completed',
//         action: 'Filed Report', 
//         publicInformationOfficer: '', 
//         safetySecurityOfficer: '', 
//         location: '',
//       ),
//       Event(
//         eventId: '3',
//         category: 'Typhoon',
//         eventIntro: 'Typhoon Response',
//         observations: ['Monitoring typhoon developments.'],
//         scenario: 'Typhoon approaching coastal area',
//         factSheet: 'Typhoon Response Protocol',
//         incidentCommander: User(),
//         liasonOfficer: User(),
//         timeStampStart: DateTime(2025, 10, 25, 8, 30),
//         timeStampEnd: DateTime(2025, 10, 25, 11, 0),
//         name: 'Typhoon Response',
//         description: 'Monitoring typhoon developments.',
//         status: 'Pending',
//         action: 'Await Updates', 
//         publicInformationOfficer: '', 
//         safetySecurityOfficer: '', 
//         location: '',

//       ),
//     ];

//     _eventDataSource = EventDataSource(events);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: SfCalendar(
//             view: CalendarView.month,
//             dataSource: _eventDataSource,
//             monthViewSettings: const MonthViewSettings(
//               appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
//               numberOfWeeksInView: 5,
//             ),
//             todayHighlightColor: primaryColor,
//             cellBorderColor: primaryColor,
//             showNavigationArrow: true,
//             showDatePickerButton: true,
//             headerHeight: 60,
//             headerStyle: CalendarHeaderStyle(
//               textAlign: TextAlign.center,
//               textStyle: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//               ),
//               backgroundColor: primaryColor,
//             ),
//             selectionDecoration: BoxDecoration(
//               color: primaryColor.withOpacity(0.3),
//               border: Border.all(color: primaryColor, width: 2),
//               borderRadius: BorderRadius.circular(4),
//             ),

//           ),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }
