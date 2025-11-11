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
  final User incidentCommander;
  final User liasonOfficer;
  final String status;
  final String action;


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
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseDate(Map<String, dynamic>? dateMap) {
      if (dateMap == null) {
        return DateTime.now();
      }
      final year = _parseInt(dateMap['year']);
      final month = _monthToInt(dateMap['month']);
      final day = _parseInt(dateMap['day']);
      return DateTime(year, month, day);
    }

    return Event(
      eventId: doc.id.toString(),
      name: data['eventName'] ?? '',
      description: data['eventDescription'] ?? '',
      eventIntro: data['eventIntroduction'] ?? '',
      status: data['status'] ?? '',
      timeStampStart: parseDate(data['eventDate']),
      timeStampEnd: parseDate(data['endDate'] ?? data['eventDate']),
      factSheet: data['factSheet'] ?? '',
      reportsId: (data['reportsId'] != null)
          ? List<String>.from(data['reportsId'].map((e) => e.toString()))
          : [],
      isActual: data['isActual'] ?? false,
      totalFaculty: _parseInt(data['totalFaculty']),
      totalAdminMembers: _parseInt(data['totalAdminMembers']),
      totalRepsMembers: _parseInt(data['totalRepsMembers']),
      totalCustodians: _parseInt(data['totalCustodians']),
      totalJoCosMembers: _parseInt(data['totalJoCosMembers']),
      totalStudents: _parseInt(data['totalStudents']),
      totalSecurity: _parseInt(data['totalSecurity']),
      totalConstructionWorkers: _parseInt(data['totalConstructionWorkers']),
      totalHealthWorkers: _parseInt(data['totalHealthWorkers']),
      totalGuests: _parseInt(data['totalGuests']),
      totalPatients: _parseInt(data['totalPatients']),
      totalMissingPersons: _parseInt(data['totalMissingPersons']),
      totalCasualties: _parseInt(data['totalCasualties']),
      totalDistribution: (data['totalDistribution'] != null)
          ? Map<String, int>.from(data['totalDistribution'].map((key, value) => MapEntry(key.toString(), _parseInt(value))))
          : {},
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

  DateTime get getStartDate => DateTime(startDate.year, startDate.month, startDate.day);
  DateTime get getEndDate => DateTime(endDate.year, endDate.month, endDate.day);


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
      'factSheet' : factSheet,
      'incidentCommander' : incidentCommander.toJson(),
      'liasonOfficer' : liasonOfficer.toJson(),
      'status': status,
      'action': action
    };
  }
}
