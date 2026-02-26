import 'package:flutter/foundation.dart';

class Report {
  final String id;
  final String encoderId;
  final String? reportId;
  final String cluster;
  final String office;
  final String bldgName;
  final String encoderposition;
  final String zone;
  final DateTime lastModified;
  final DateTime created;
  final String? eventId;

  final String eventType;
  final String hazardType;

  final int facultymembers;
  final int adminmembers;
  final int repsmembers;
  final int ramembers;
  final int students;
  final int philcarestaff;
  final int securitypersonnel;
  final int constructionworkers;
  final int tenants;
  final int healthworkers;
  final int nonacademicstaff;
  final int guests;
  final int nummissingpersons;
  final int numcasualties;
  final String namesofmissingpersons;
  final String identityandconditionofcasualties;
  final String damageassessment;
  final String exactlocation;

  Report({
    this.id = '',
    required this.encoderId,
    this.reportId = '',
    required this.cluster,
    required this.office,
    required this.bldgName,
    this.encoderposition = "",
    this.zone = "",
    this.eventType = "incident",
    this.hazardType = "",
    this.facultymembers = 0,
    this.adminmembers = 0,
    this.repsmembers = 0,
    this.ramembers = 0,
    this.students = 0,
    this.philcarestaff = 0,
    this.securitypersonnel = 0,
    this.constructionworkers = 0,
    this.tenants = 0,
    this.healthworkers = 0,
    this.nonacademicstaff = 0,
    this.guests = 0,
    this.nummissingpersons = 0,
    this.numcasualties = 0,
    this.namesofmissingpersons = "",
    this.identityandconditionofcasualties = "",
    this.damageassessment = "",
    this.exactlocation = "",
    DateTime? lastModified,
    DateTime? created,
    this.eventId,
  })  : lastModified = lastModified ?? DateTime.now().toUtc(),
        created = created ?? DateTime.now().toUtc();

  factory Report.fromJson(Map<String, dynamic> json) {
    int _pickInt(List<String> keys) {
      for (var k in keys) {
        if (json[k] != null) return _parseInt(json[k]);
      }
      return 0;
    }

    String _pickString(List<String> keys) {
      for (var k in keys) {
        if (json[k] != null) return json[k].toString();
      }
      return '';
    }

    DateTime parsedLastModified = DateTime.now().toUtc();
    if (json['last_modified'] != null) {
      try {
        parsedLastModified =
            DateTime.parse(json['last_modified']).toLocal();
      } catch (_) {}
    }

    DateTime parsedCreated = DateTime.now().toUtc();
    if (json['created_at'] != null) {
      try {
        parsedCreated =
            DateTime.parse(json['created_at']).toLocal();
      } catch (_) {}
    }

    return Report(
      id: json['id'] ?? '',
      encoderId: _pickString(['encoder_id', 'encoderId']),
      reportId: _pickString(['report_id', 'reportId']),
      cluster: json['cluster'] ?? '',
      office: json['office'] ?? '',
      bldgName: _pickString(['bldg_name', 'bldgName']),
      encoderposition: _pickString(['encoder_position', 'encoderposition']),
      lastModified: parsedLastModified,
      created: parsedCreated,
      eventType: _pickString(['event_type', 'eventType']),
      hazardType: _pickString(['hazard_type', 'hazardType']),
      facultymembers: _pickInt(['facultymembers']),
      adminmembers: _pickInt(['adminmembers']),
      repsmembers: _pickInt(['repsmembers']),
      ramembers: _pickInt(['ramembers']),
      students: _pickInt(['students']),
      philcarestaff: _pickInt(['philcarestaff']),
      securitypersonnel: _pickInt(['securitypersonnel']),
      constructionworkers: _pickInt(['constructionworkers']),
      tenants: _pickInt(['tenants']),
      healthworkers: _pickInt(['healthworkers']),
      nonacademicstaff: _pickInt(['nonacademicstaff']),
      guests: _pickInt(['guests']),
      nummissingpersons: _pickInt(['nummissingpersons']),
      numcasualties: _pickInt(['numcasualties']),
      namesofmissingpersons: _pickString(['namesofmissingpersons']),
      identityandconditionofcasualties:
          _pickString(['identityandconditionofcasualties']),
      damageassessment: _pickString(['damageassessment']),
      exactlocation: _pickString(['exactlocation']),
      eventId: json['event_id'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'encoderId': encoderId,
      'reportId': reportId,
      'cluster': cluster,
      'office': office,
      'bldgName': bldgName,
      'encoderposition': encoderposition,
      'lastModified': lastModified.toUtc().toIso8601String(),
      'created': created.toUtc().toIso8601String(),
      'eventType': eventType,
      'hazardType': hazardType,
      'facultymembers': facultymembers,
      'adminmembers': adminmembers,
      'repsmembers': repsmembers,
      'ramembers': ramembers,
      'students': students,
      'philcarestaff': philcarestaff,
      'securitypersonnel': securitypersonnel,
      'constructionworkers': constructionworkers,
      'tenants': tenants,
      'healthworkers': healthworkers,
      'nonacademicstaff': nonacademicstaff,
      'guests': guests,
      'nummissingpersons': nummissingpersons,
      'numcasualties': numcasualties,
      'namesofmissingpersons': namesofmissingpersons,
      'identityandconditionofcasualties':
          identityandconditionofcasualties,
      'damageassessment': damageassessment,
      'exactlocation': exactlocation,
      if (eventId != null) 'event_id': eventId,
      if (eventId != null) 'report_id': eventId,
    };
  }

  bool get isGeneralReport =>
      eventId == null || eventId!.isEmpty;

  String get formattedLastModified {
    return "${lastModified.day.toString().padLeft(2, '0')}/"
        "${lastModified.month.toString().padLeft(2, '0')}/"
        "${lastModified.year} "
        "${lastModified.hour.toString().padLeft(2, '0')}:"
        "${lastModified.minute.toString().padLeft(2, '0')}:"
        "${lastModified.second.toString().padLeft(2, '0')}";
  }
}