/* import 'package:cloud_firestore/cloud_firestore.dart'; */


class UserModel{
  final String userName; 
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String email;
  final String authId;
  final String cluster;
  final String office;
  final String bldgName;
  final String position; 
  final int userType;

  UserModel({
    required this.userName,
    this.firstName = "",
    this.middleName = "",
    this.lastName = "",
    this.suffix = "",
    this.email = "",
    this.authId = "",
    this.cluster = "",
    this.office = "",
    this.bldgName = "",
    this.position = "",
    this.userType = 0
  });



  factory UserModel.fromMap(Map<String, dynamic> data, String userName) {
    return UserModel(
      userName: userName,
      firstName: data['firstname'] ?? '',
      middleName: data['middlename'] ?? '',
      lastName: data['lastname'] ?? '',
      suffix: data['suffix'] ?? '',
      email: data['email'] ?? '',
      authId: data['authid'] ?? '',
      cluster: data['cluster'] ?? '',
      office: data['office'] ?? '',
      bldgName: data['bldgname'] ?? '',
      position: data['position'] ?? '',
      userType: data['usertype'] ?? 0,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['username'] ?? json['userName'] ?? '',
      firstName: json['firstname'] ?? json['firstName'] ?? '',
      middleName: json['middlename'] ?? json['middleName'] ?? '',
      lastName: json['lastname'] ?? json['lastName'] ?? '',
      suffix: json['suffix'] ?? '',
      email: json['email'] ?? '',
      authId: json['authid'] ?? json['authId'] ?? '',
      cluster: json['cluster'] ?? json['upcampus'] ?? json['upCampus'] ?? '',
      office: json['office'] ?? '',
      bldgName: json['bldgname'] ?? json['bldgName'] ?? '',
      position: json['position'] ?? '',
      userType: json['usertype'] ?? json['userType'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': userName,
      'firstname': firstName,
      'middlename': middleName,
      'lastname': lastName,
      'suffix': suffix,
      'email': email,
      'authid': authId,
      'cluster': cluster,
      'office': office,
      'bldgname': bldgName,
      'position': position,
      'usertype': userType
    };
  }

  // Helper method to get full name
  String get fullName {
    List<String> names = [];
    if (firstName.isNotEmpty) names.add(firstName);
    if (middleName.isNotEmpty) names.add(middleName);
    if (lastName.isNotEmpty) names.add(lastName);
    if (suffix.isNotEmpty) names.add(suffix);
    return names.join(' ');
  }

  // Helper method to get abbreviated name
  String get abbreviatedName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName ${lastName[0]}.';
    }
    return userName;
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? userName,
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    String? email,
    String? authId,
    String? cluster,
    String? office,
    String? bldgName,
    String? position,
    int? userType,
  }) {
    return UserModel(
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      suffix: suffix ?? this.suffix,
      email: email ?? this.email,
      authId: authId ?? this.authId,
      cluster: cluster ?? this.cluster,
      office: office ?? this.office,
      bldgName: bldgName ?? this.bldgName,
      position: position ?? this.position,
      userType: userType ?? this.userType,
    );
  }
}