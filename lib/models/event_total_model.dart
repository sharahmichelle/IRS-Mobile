import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:const_date_time/const_date_time.dart';

class EventTotal {
  final String eventId;
  final DateTime timeStampStart;
  final DateTime timeStampEnd;
  final int expectedData;
  final int receivedData;
  final int totalFaculty;
  final int totalAdminMembers;
  final int totalRepsMembers;
  final int totalCustodians;
  final int totalJoCosMembers;
  final int totalStudents;
  final int totalSecurity;
  final int totalConstructionWorkers;
  final int totalHealthWorkers;
  final int totalGuests;
  final int totalPatients;
  final int totalMissingPersons;
  final int totalCasualties;
  final bool isActual;
  final List<String> reportsId;
  final Map<String, int> totalDistribution;

  EventTotal({
    this.eventId = "",
    this.timeStampStart = const ConstDateTime(2000),
    this.timeStampEnd = const ConstDateTime(2000),
    this.expectedData = 0,
    this.receivedData = 0,
    this.isActual = false,
    this.reportsId = const [],
    this.totalAdminMembers = 0,
    this.totalCasualties = 0,
    this.totalConstructionWorkers = 0,
    this.totalCustodians = 0,
    this.totalFaculty = 0,
    this.totalGuests = 0,
    this.totalHealthWorkers = 0,
    this.totalJoCosMembers = 0,
    this.totalMissingPersons = 0,
    this.totalPatients = 0,
    this.totalRepsMembers = 0,
    this.totalSecurity = 0,
    this.totalStudents = 0,
    this.totalDistribution = const {},
  });

  static EventTotal empty() => EventTotal(
    eventId: "",
    timeStampStart: DateTime.now(),
    timeStampEnd: DateTime.now(),
    expectedData: 0,
    receivedData: 0,
    isActual: false,
    reportsId: [],
    totalFaculty: 0,
    totalAdminMembers: 0,
    totalRepsMembers: 0,
    totalCustodians: 0,
    totalJoCosMembers: 0,
    totalStudents: 0,
    totalSecurity: 0,
    totalConstructionWorkers: 0,
    totalHealthWorkers: 0,
    totalGuests: 0,
    totalPatients: 0,
    totalMissingPersons: 0,
    totalCasualties: 0,
    totalDistribution: {},
  );

  factory EventTotal.fromFirestore(DocumentSnapshot doc) {
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

    return EventTotal(
      eventId: doc.id.toString(),
      expectedData: _parseInt(data['expectedData']),
      receivedData: _parseInt(data['receivedData']),
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

  DateTime get getStartDate => DateTime(timeStampStart.year, timeStampStart.month, timeStampStart.day);
  DateTime get getEndDate => DateTime(timeStampEnd.year, timeStampEnd.month, timeStampEnd.day);

  Map<String, dynamic> toJson() {
    final intToMonth = {
      1: "JAN",
      2: "FEB",
      3: "MAR",
      4: "APR",
      5: "MAY",
      6: "JUN",
      7: "JUL",
      8: "AUG",
      9: "SEPT",
      10: "OCT",
      11: "NOV",
      12: "DEC",
    };

    return {
      'eventId': eventId,
      "timeStampStart": timeStampStart,
      "timeStampEnd": timeStampEnd,
      "expectedData": expectedData,
      "receivedData": receivedData,
      "isActual": isActual,
      "reportsId": reportsId,
      "totalFaculty": totalFaculty,
      "totalAdminMembers": totalAdminMembers,
      "totalRepsMembers": totalRepsMembers,
      "totalCustodians": totalCustodians,
      "totalJoCosMembers": totalJoCosMembers,
      "totalStudents": totalStudents,
      "totalSecurity": totalSecurity,
      "totalConstructionWorkers": totalConstructionWorkers,
      "totalHealthWorkers": totalHealthWorkers,
      "totalGuests": totalGuests,
      "totalPatients": totalPatients,
      "totalMissingPersons": totalMissingPersons,
      "totalCasualties": totalCasualties,
      "totalDistribution": totalDistribution,
    };
    
  }
}
