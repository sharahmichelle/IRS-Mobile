import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String userName; // This should be the document ID
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String email;
  final String authId;
  final String upCampus;
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
    this.upCampus = "",
    this.office = "",
    this.bldgName = "",
    this.position = "",
    this.userType = 0
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      userName: doc.id,
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      suffix: data['suffix'] ?? '',
      email: data['email'] ?? '',
      authId: data['authId'] ?? '',
      upCampus: data['upCampus'] ?? '',
      office: data['office'] ?? '',
      bldgName: data['bldgName'] ?? '',
      position: data['position'] ?? '',
      userType: data['userType'] ?? 0,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String userName) {
    return UserModel(
      userName: userName,
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      suffix: data['suffix'] ?? '',
      email: data['email'] ?? '',
      authId: data['authId'] ?? '',
      upCampus: data['upCampus'] ?? '',
      office: data['office'] ?? '',
      bldgName: data['bldgName'] ?? '',
      position: data['position'] ?? '',
      userType: data['userType'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'suffix': suffix,
      'email': email,
      'authId': authId,
      'upCampus': upCampus,
      'office': office,
      'bldgName': bldgName,
      'position': position,
      'userType': userType
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
    String? upCampus,
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
      upCampus: upCampus ?? this.upCampus,
      office: office ?? this.office,
      bldgName: bldgName ?? this.bldgName,
      position: position ?? this.position,
      userType: userType ?? this.userType,
    );
  }

  toMap() {}
}