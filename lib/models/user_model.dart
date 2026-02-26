// lib/models/user_model.dart

class UserModel {
  final String userName;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String email;
  final String authId;

  /// UUID stored in `users.encoder_id` — used as the foreign key in `reports.encoder_id`.
  /// This is the field you must pass to [Reports.setCurrentUser].
  final String encoderId;

  final String cluster;
  final String office;
  final String bldgName;
  final String position;
  final String zone;
  final int userType;

  UserModel({
    required this.userName,
    String firstName    = '',
    String middleName   = '',
    String lastName     = '',
    String suffix       = '',
    String email        = '',
    String authId       = '',
    String encoderId    = '',
    String cluster      = '',
    String office       = '',
    String bldgName     = '',
    String position     = '',
    String zone         = '',
    int    userType     = 0,
  })  : firstName  = firstName,
        middleName = middleName,
        lastName   = lastName,
        suffix     = suffix,
        email      = email,
        authId     = authId,
        encoderId  = encoderId,
        cluster    = cluster,
        office     = office,
        bldgName   = bldgName,
        position   = position,
        zone       = zone,
        userType   = userType;

  factory UserModel.fromMap(Map<String, dynamic> data, String userName) {
    return UserModel(
      userName:   userName,
      firstName:  data['firstname']?.toString()        ?? '',
      middleName: data['middlename']?.toString()       ?? '',
      lastName:   data['lastname']?.toString()         ?? '',
      suffix:     data['suffix']?.toString()           ?? '',
      email:      data['email']?.toString()            ?? '',
      authId:     data['authid']?.toString()           ?? '',
      encoderId:  data['encoder_id']?.toString()       ?? '',
      cluster:    data['cluster']?.toString()          ?? '',
      office:     data['office']?.toString()           ?? '',
      bldgName:   data['bldgname']?.toString()         ?? '',
      position:   data['encoder_position']?.toString() ?? '',
      zone:       data['zone']?.toString()             ?? '',
      userType:   int.tryParse(data['usertype']?.toString() ?? '0') ?? 0,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName:   json['username']         ?? json['userName']   ?? '',
      firstName:  json['firstname']        ?? json['firstName']  ?? '',
      middleName: json['middlename']       ?? json['middleName'] ?? '',
      lastName:   json['lastname']         ?? json['lastName']   ?? '',
      suffix:     json['suffix']           ?? '',
      email:      json['email']            ?? '',
      authId:     json['authid']           ?? json['authId']     ?? '',
      // encoder_id is the UUID used to link reports to users
      encoderId:  json['encoder_id']       ?? json['encoderId']  ?? '',
      cluster:    json['cluster']          ?? json['upcampus']   ?? json['upCampus'] ?? '',
      office:     json['office']           ?? '',
      bldgName:   json['bldgname']         ?? json['bldgName']   ?? '',
      position:   json['encoder_position'] ?? '',
      zone:       json['zone']?.toString() ?? '',
      userType:   int.tryParse(
                    json['usertype']?.toString() ??
                    json['userType']?.toString()  ??
                    '0',
                  ) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'username':         userName,
      'firstname':        firstName,
      'middlename':       middleName,
      'lastname':         lastName,
      'suffix':           suffix,
      'email':            email,
      'authid':           authId,
      'cluster':          cluster,
      'office':           office,
      'bldgname':         bldgName,
      'encoder_position': position,
      'zone':             zone,
      'usertype':         userType,
    };
    
    // Only include encoder_id if it's not empty - 
    // this allows the database default (gen_random_uuid()) to be used
    if (encoderId.isNotEmpty) {
      map['encoder_id'] = encoderId;
    }
    
    return map;
  }

  // ─── Computed helpers ─────────────────────────────────────────────────────

  String get fullName {
    final parts = [firstName, middleName, lastName, suffix]
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.join(' ');
  }

  String get abbreviatedName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName ${lastName[0]}.';
    }
    return userName;
  }

  UserModel copyWith({
    String? userName,
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    String? email,
    String? authId,
    String? encoderId,
    String? cluster,
    String? office,
    String? bldgName,
    String? position,
    String? zone,
    int?    userType,
  }) {
    return UserModel(
      userName:   userName   ?? this.userName,
      firstName:  firstName  ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName:   lastName   ?? this.lastName,
      suffix:     suffix     ?? this.suffix,
      email:      email      ?? this.email,
      authId:     authId     ?? this.authId,
      encoderId:  encoderId  ?? this.encoderId,
      cluster:    cluster    ?? this.cluster,
      office:     office     ?? this.office,
      bldgName:   bldgName   ?? this.bldgName,
      position:   position   ?? this.position,
      zone:       zone       ?? this.zone,
      userType:   userType   ?? this.userType,
    );
  }
}