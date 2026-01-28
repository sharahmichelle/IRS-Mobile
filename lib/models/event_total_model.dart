/* import 'package:cloud_firestore/cloud_firestore.dart'; */
import 'package:supabase_flutter/supabase_flutter.dart';
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

  factory EventTotal.fromSupabase(Map<String, dynamic> data) {
    return EventTotal(
      eventId: data['eventId']?.toString() ?? '',
      timeStampStart: data['timeStampStart'] != null ? DateTime.parse(data['timeStampStart']) : const ConstDateTime(2000),
      timeStampEnd: data['timeStampEnd'] != null ? DateTime.parse(data['timeStampEnd']) : const ConstDateTime(2000),
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


  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime get getStartDate => DateTime(timeStampStart.year, timeStampStart.month, timeStampStart.day);
  DateTime get getEndDate => DateTime(timeStampEnd.year, timeStampEnd.month, timeStampEnd.day);

  Map<String, dynamic> toJson() {

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
