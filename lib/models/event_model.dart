import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:upm_drrm_irs_mobile/models/user_model.dart';

class Event {
  final String eventID;
  final DateTime timeStampStart;
  final DateTime timeStampEnd;
  final String category;
  final String eventName;
  final String eventDescription;
  final String eventIntroduction;
  final List<String> eventObservations;
  final String eventScenario;
  final bool eventStarted;
  final String factSheet;
  final String incidentCommander;
  final String liasonOfficer;
  final String status;
  final String action;
  final String location;
  final String publicInformationOfficer;
  final String safetySecurityOfficer;

  Event({
    required this.eventID,
    required this.timeStampStart,
    required this.timeStampEnd,
    required this.category,
    required this.eventName,
    required this.eventDescription,
    required this.eventIntroduction,
    required this.eventObservations,
    required this.eventScenario,
    required this.factSheet,
    required this.incidentCommander,
    required this.liasonOfficer,
    required this.status,
    required this.action,
    required this.publicInformationOfficer,
    required this.safetySecurityOfficer,
    required this.location,
    this.eventStarted = false,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse observations safely
    final observations = data['eventObservations'] is List
        ? List<String>.from(data['eventObservations'])
        : [
            if (data['eventObservations'] != null)
              data['eventObservations'].toString(),
          ];

    // Parse actions safely
    final actions = data['eventActions'] is List
        ? List<String>.from(data['eventActions'])
        : [if (data['eventActions'] != null) data['eventActions'].toString()];

    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is Timestamp) return date.toDate();
      try {
        final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');

        return format.parseUtc(date.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Event(
      eventID: doc.id,
      eventName: data['eventName'] ?? '',
      eventDescription: data['eventDescription'] ?? '',
      eventIntroduction: data['eventIntroduction'] ?? '',
      status: data['status'] ?? '',
      timeStampStart: parseDate(data['eventDate']),
      timeStampEnd: parseDate(data['endDate'] ?? data['eventDate']),
      factSheet: data['factSheet'] ?? '',
      category: data['categoryID'] ?? data['category'] ?? '',
      eventObservations: observations,
      eventScenario: data['scenarioID'] ?? '',
      incidentCommander: data['incidentCommander'] ?? '',
      liasonOfficer: data['liasonOfficer'] ?? '',
      action: actions.isNotEmpty ? actions.first : '',
      publicInformationOfficer: data['publicInformationOfficer'] ?? '',
      safetySecurityOfficer: data['safetySecurityOfficer'] ?? '',
      location: data['locationID'] ?? '',
    );
  }

  static int _monthToInt(String? month) {
    const months = {
      "JAN": 1,
      "FEB": 2,
      "MAR": 3,
      "APR": 4,
      "MAY": 5,
      "JUN": 6,
      "JUL": 7,
      "AUG": 8,
      "SEPT": 9,
      "OCT": 10,
      "NOV": 11,
      "DEC": 12,
    };
    return months[month] ?? DateTime.now().month;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime get getStartDate =>
      DateTime(timeStampStart.year, timeStampStart.month, timeStampStart.day);
  DateTime get getEndDate =>
      DateTime(timeStampEnd.year, timeStampEnd.month, timeStampEnd.day);

  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'timeStampStart': timeStampStart,
      'timeStampEnd': timeStampEnd,
      'category': category,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventIntroduction': eventIntroduction,
      'eventObservations': eventObservations,
      'eventScenario': eventScenario,
      'factSheet': factSheet,
      'incidentCommander': incidentCommander,
      'liasonOfficer': liasonOfficer,
      'publicInformationOfficer': publicInformationOfficer,
      'safetySecurityOfficer': safetySecurityOfficer,
      'status': status,
      'action': action,
    };
  }
}
