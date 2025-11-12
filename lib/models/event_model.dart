import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upm_drrm_irs_mobile/models/user_model.dart';

class Event {
  final String eventId;
  final DateTime timeStampStart;
  final DateTime timeStampEnd;
  final String category;
  final String name;
  final String description;
  final String eventIntro;
  final List<String> observations;
  final String scenario;
  final String factSheet;
  final String incidentCommander;
  final String liasonOfficer;
  final String status;
  final String action;
  final String location;
  final String publicInformationOfficer;
  final String safetySecurityOfficer;

  Event({
    required this.eventId,
    required this.timeStampStart,
    required this.timeStampEnd,
    required this.category,
    required this.name,
    required this.description,
    required this.eventIntro,
    required this.observations,
    required this.scenario,
    required this.factSheet,
    required this.incidentCommander,
    required this.liasonOfficer,
    required this.status,
    required this.action,
    required this.publicInformationOfficer,
    required this.safetySecurityOfficer,
    required this.location,
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
        return DateTime.parse(date.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Event(
      eventId: doc.id,
      name: data['eventName'] ?? '',
      description: data['eventDescription'] ?? '',
      eventIntro: data['eventIntroduction'] ?? '',
      status: data['status'] ?? '',
      timeStampStart: parseDate(data['eventDate']),
      timeStampEnd: parseDate(data['endDate'] ?? data['eventDate']),
      factSheet: data['factSheet'] ?? '',
      category: data['categoryID'] ?? '',
      observations: observations,
      scenario: data['scenarioID'] ?? '',
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
      'eventId': eventId,
      'timeStampStart': timeStampStart,
      'timeStampEnd': timeStampEnd,
      'category': category,
      'name': name,
      'description': description,
      'eventIntro': eventIntro,
      'observations': observations,
      'scenario': scenario,
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
