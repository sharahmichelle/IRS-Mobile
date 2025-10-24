class User {
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

  User({
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

  Map<String, dynamic> toJson(){
    return{
      'firstName': firstName,
      'middleName':middleName,
      'lastName': lastName,
      "suffix":suffix,
      "email":email,
      "authId":authId,
      "upCampus":upCampus,
      "office":office,
      "bldgName":bldgName,
      "position":position,
      "userType":userType
    };
  }
}