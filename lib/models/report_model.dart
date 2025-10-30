// import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String encoderId;
  final String reportId;
  final String upSystem;
  final String office;
  final String encoderPosition;
  final int headCountFaculty;
  final int headCountadminMember;
  final int headCountRepsMember;
  final int headCountCustodian;
  final int headCountJoCosMember;
  final int headCountStudent;
  final int headCountSecurity;
  final int headCountConstructionWorker;
  final int headCountHealthWorker;
  final int headCountGuest;
  final int headCountPatient;
  final int numMissingPerson;
  final int numCasualty;

  Report({
    required this.encoderId,
    required this.reportId,
    required this.upSystem,
    required this.office,
    this.encoderPosition = "",
    this.headCountFaculty = 0,
    this.headCountadminMember = 0,
    this.headCountRepsMember = 0,
    this.headCountCustodian = 0,
    this.headCountJoCosMember = 0,
    this.headCountStudent = 0,
    this.headCountSecurity = 0,
    this.headCountConstructionWorker = 0,
    this.headCountHealthWorker = 0,
    this.headCountGuest = 0,
    this.headCountPatient = 0,
    this.numMissingPerson = 0,
    this.numCasualty = 0,
  });

  // factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  //   final data = doc.data()!;
  //   return Report(
  //     encoderId: data['encoderId'] ?? '',
  //     reportId: doc.id,
  //     upSystem: data['upSystem'] ?? '',
  //     office: data['office'] ?? '',
  //     encoderPosition: data['encoderPosition'] ?? '',
  //     headCountFaculty: _parseInt(data['headCountFaculty']),
  //     headCountadminMember: _parseInt(data['headCountadminMember']),
  //     headCountRepsMember: _parseInt(data['headCountRepsMember']),
  //     headCountCustodian: _parseInt(data['headCountCustodian']),
  //     headCountJoCosMember: _parseInt(data['headCountJoCosMember']),
  //     headCountStudent: _parseInt(data['headCountStudent']),
  //     headCountSecurity: _parseInt(data['headCountSecurity']),
  //     headCountConstructionWorker: _parseInt(data['headCountConstructionWorker']),
  //     headCountHealthWorker: _parseInt(data['headCountHealthWorker']),
  //     headCountGuest: _parseInt(data['headCountGuest']),
  //     headCountPatient: _parseInt(data['headCountPatient']),
  //     numMissingPerson: _parseInt(data['numMissingPerson']),
  //     numCasualty: _parseInt(data['numCasualty']),
  //   );
  // }

  // static int _parseInt(dynamic value) {
  //   if (value == null) return 0;
  //   if (value is int) return value;
  //   if (value is String) return int.tryParse(value) ?? 0;
  //   return 0;
  // }

  Map<String, dynamic> toJson() {
    return {
      'encoderId': encoderId,
      'reportId': reportId,
      'upSystem': upSystem,
      'office': office,
      'headCountFaculty': headCountFaculty,
      'headCountadminMember': headCountadminMember,
      'headCountRepsMember': headCountRepsMember,
      'headCountCustodian': headCountCustodian,
      'headCountJoCosMember': headCountJoCosMember,
      'headCountStudent': headCountStudent,
      'headCountSecurity': headCountSecurity,
      'headCountConstructionWorker': headCountConstructionWorker,
      'headCountHealthWorker': headCountHealthWorker,
      'headCountGuest': headCountGuest,
      'headCountPatient': headCountPatient,
      'numMissingPerson': numMissingPerson,
      'numCasualty': numCasualty,
    };
  }
}
