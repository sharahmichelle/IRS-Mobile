import 'dart:ui';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'event_model.dart';

class EventDataSource extends CalendarDataSource<Object?> {
  EventDataSource(List<Event> events) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as Event).timeStampStart;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as Event).timeStampEnd;
  }

  @override
  String getSubject(int index) {
    return (appointments![index] as Event).eventName;
  }

  @override
  String getNotes(int index) {
    return (appointments![index] as Event).eventDescription;
  }

  @override
  Color getColor(int index) {
    final status = (appointments![index] as Event).status.toLowerCase();
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'upcoming':
        return const Color(0xFF2196F3);
      case 'ongoing':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  bool isAllDay(int index) => false;
}
