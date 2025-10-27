class User {
  final String name;
  final int employeeNumber;
  final String token;
  final String campus;
  final int isDeactivated;
  final int isAdmin;

  User({
    required this.name,
    required this.employeeNumber,
    required this.token,
    required this.campus,
    required this.isDeactivated,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['userFullName'],
      employeeNumber: json['employeeNumber'],
      token: json['token'],
      campus: json['userCampus'],
      isDeactivated: json['status'],
      isAdmin: json['userRole'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'employeeNumber': employeeNumber,
      'password': token,
      'campus': campus,
      'isDeactivated': isDeactivated,
      'isAdmin': isAdmin,
    };
  }

  bool get isActive => isDeactivated == 0;
}
