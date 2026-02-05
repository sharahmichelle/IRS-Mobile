class Report {
  final String id;
  final String encoderId;
  final String reportId;
  final String cluster;
  final String office;
  final String bldgName;
  final String encoderposition;

  // New fields mapped to Supabase column names
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
    required this.reportId,
    required this.cluster,
    required this.office,
    required this.bldgName,
    this.encoderposition = "",
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
  });

  factory Report.fromMap(Map<String, dynamic> data, String id) {
    return Report(
      encoderId: id,
      reportId: data['reportId'] ?? '',
      cluster: data['cluster'] ?? '',
      office: data['office'] ?? '',
      bldgName: data['bldgName'] ?? '',
      encoderposition: data['encoderposition'] ?? '',
      facultymembers: _parseInt(data['headCountFaculty']),
      adminmembers: _parseInt(data['headCountadminMember']),
      repsmembers: _parseInt(data['headCountRepsMember']),
      ramembers: _parseInt(data['headCountRAMember']),
      students: _parseInt(data['headCountStudent']),
      securitypersonnel: _parseInt(data['headCountSecurity']),
      constructionworkers: _parseInt(data['headCountConstructionWorker']),
      tenants: _parseInt(data['tenants']),
      healthworkers: _parseInt(data['headCountHealthWorker']),
      nonacademicstaff: _parseInt(data['headCountNonAcademicStaff']),
      guests: _parseInt(data['headCountGuest']),
      philcarestaff: _parseInt(data['headCountPhilcareStaff']),
      nummissingpersons: _parseInt(data['numMissingPerson']),
      numcasualties: _parseInt(data['numCasualty']),
    );
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    // Support both legacy keys and the new Supabase column keys
    int _pickInt(List<String> keys) {
      for (var k in keys) {
        if (json[k] != null) return _parseInt(json[k]);
      }
      return 0;
    }

    String _pickString(List<String> keys) {
      for (var k in keys) {
        if (json[k] != null) return (json[k] as String);
      }
      return '';
    }

    return Report(
      id: json['id'] ?? '',
      encoderId: json['encoderId'] ?? '',
      reportId: json['reportId'] ?? '',
      cluster: json['cluster'] ?? '',
      office: json['office'] ?? '',
      bldgName: json['bldgName'] ?? '',
      encoderposition: json['encoderposition'] ?? '',
      // New explicit fields
      facultymembers: _pickInt(['facultymembers', 'headCountFaculty']),
      adminmembers: _pickInt(['adminmembers', 'headCountadminMember']),
      repsmembers: _pickInt(['repsmembers', 'headCountRepsMember']),
      ramembers: _pickInt(['ramembers', 'headCountRAMember']),
      students: _pickInt(['students', 'headCountStudent']),
      philcarestaff: _pickInt(['philcarestaff', 'headCountPhilcareStaff']),
      securitypersonnel: _pickInt(['securitypersonnel', 'headCountSecurity']),
      constructionworkers: _pickInt(['constructionworkers', 'headCountConstructionWorker']),
      tenants: _pickInt(['tenants']),
      healthworkers: _pickInt(['healthworkers', 'headCountHealthWorker']),
      nonacademicstaff: _pickInt(['nonacademicstaff', 'headCountNonAcademicStaff']),
      guests: _pickInt(['guests', 'headCountGuest']),
      nummissingpersons: _pickInt(['nummissingpersons', 'numMissingPerson']),
      numcasualties: _pickInt(['numcasualties', 'numCasualty']),
      namesofmissingpersons: _pickString(['namesofmissingpersons', 'namesOfMissingPersons', 'namesOfMissing']),
      identityandconditionofcasualties: _pickString(['identityandconditionofcasualties', 'identityAndConditionOfCasualties']),
      damageassessment: _pickString(['damageassessment', 'damageAssessment']),
      exactlocation: _pickString(['exactlocation', 'exactLocation', 'location']),
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
      // Legacy keys kept for backward compatibility
      'encoderId': encoderId,
      'reportId': reportId,
      'cluster': cluster,
      'office': office,
      'bldgName': bldgName,

      // New required Supabase column names (as requested)
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
      'identityandconditionofcasualties': identityandconditionofcasualties,
      'damageassessment': damageassessment,
      'exactlocation': exactlocation,
    };
  }

  /// Compatibility getter used by SubmittedReportsScreen and other callers.
  /// Returns the underlying event id field (adjust the field name if different).
  String get eventId => reportId;
}