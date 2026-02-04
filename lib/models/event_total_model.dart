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

  const EventTotal({
    this.eventId = '',
    this.timeStampStart = const ConstDateTime(2000),
    this.timeStampEnd = const ConstDateTime(2000),
    this.expectedData = 0,
    this.receivedData = 0,
    this.totalFaculty = 0,
    this.totalAdminMembers = 0,
    this.totalRepsMembers = 0,
    this.totalCustodians = 0,
    this.totalJoCosMembers = 0,
    this.totalStudents = 0,
    this.totalSecurity = 0,
    this.totalConstructionWorkers = 0,
    this.totalHealthWorkers = 0,
    this.totalGuests = 0,
    this.totalPatients = 0,
    this.totalMissingPersons = 0,
    this.totalCasualties = 0,
    this.isActual = false,
    this.reportsId = const [],
    this.totalDistribution = const {},
  });

  static EventTotal empty() => const EventTotal();

  /* ===========================
     Supabase → Flutter mapping
     =========================== */
  factory EventTotal.fromSupabase(Map<String, dynamic> data) {
    return EventTotal(
      eventId: data['eventid']?.toString() ?? '',
      timeStampStart: data['timestampstart'] != null
          ? DateTime.parse(data['timestampstart'])
          : const ConstDateTime(2000),
      timeStampEnd: data['timestampend'] != null
          ? DateTime.parse(data['timestampend'])
          : const ConstDateTime(2000),
      expectedData: _parseInt(data['expecteddata']),
      receivedData: _parseInt(data['receiveddata']),
      isActual: data['isactual'] ?? false,
      reportsId: data['reportsid'] != null
          ? List<String>.from(data['reportsid'].map((e) => e.toString()))
          : [],
      totalFaculty: _parseInt(data['totalfaculty']),
      totalAdminMembers: _parseInt(data['totaladminmembers']),
      totalRepsMembers: _parseInt(data['totalrepsmembers']),
      totalCustodians: _parseInt(data['totalcustodians']),
      totalJoCosMembers: _parseInt(data['totaljocosmembers']),
      totalStudents: _parseInt(data['totalstudents']),
      totalSecurity: _parseInt(data['totalsecurity']),
      totalConstructionWorkers:
          _parseInt(data['totalconstructionworkers']),
      totalHealthWorkers: _parseInt(data['totalhealthworkers']),
      totalGuests: _parseInt(data['totalguests']),
      totalPatients: _parseInt(data['totalpatients']),
      totalMissingPersons: _parseInt(data['totalmissingpersons']),
      totalCasualties: _parseInt(data['totalcasualties']),
      totalDistribution: data['totaldistribution'] != null
          ? Map<String, int>.from(
              data['totaldistribution'].map(
                (key, value) =>
                    MapEntry(key.toString(), _parseInt(value)),
              ),
            )
          : {},
    );
  }

  /* ===========================
     Flutter → Supabase mapping
     =========================== */
  Map<String, dynamic> toSupabase() {
    return {
      'eventid': eventId,
      'timestampstart': timeStampStart.toIso8601String(),
      'timestampend': timeStampEnd.toIso8601String(),
      'expecteddata': expectedData,
      'receiveddata': receivedData,
      'isactual': isActual,
      'reportsid': reportsId,
      'totalfaculty': totalFaculty,
      'totaladminmembers': totalAdminMembers,
      'totalrepsmembers': totalRepsMembers,
      'totalcustodians': totalCustodians,
      'totaljocosmembers': totalJoCosMembers,
      'totalstudents': totalStudents,
      'totalsecurity': totalSecurity,
      'totalconstructionworkers': totalConstructionWorkers,
      'totalhealthworkers': totalHealthWorkers,
      'totalguests': totalGuests,
      'totalpatients': totalPatients,
      'totalmissingpersons': totalMissingPersons,
      'totalcasualties': totalCasualties,
      'totaldistribution': totalDistribution,
    };
  }

  /* ===========================
     Helpers
     =========================== */
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  DateTime get startDate =>
      DateTime(timeStampStart.year, timeStampStart.month, timeStampStart.day);

  DateTime get endDate =>
      DateTime(timeStampEnd.year, timeStampEnd.month, timeStampEnd.day);

  Map<String, dynamic> toJson() {
    return {
      'eventid': eventId,
      'timestampstart': timeStampStart.toIso8601String(),
      'timestampend': timeStampEnd.toIso8601String(),
      'expecteddata': expectedData,
      'receiveddata': receivedData,
      'isactual': isActual,
      'reportsid': reportsId,
      'totaldistribution': totalDistribution,
    };
  }
}
