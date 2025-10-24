class User {
  final String name;
  final int employeeNumber;
  final String password;
  final String campus;
  final int isDeactivated;
  final int isAdmin;

  User({
    required this.name,
    required this.employeeNumber,
    required this.password,
    required this.campus,
    required this.isDeactivated,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      employeeNumber: json['employeeNumber'],
      password: json['password'],
      campus: json['campus'],
      isDeactivated: json['isDeactivated'],
      isAdmin: json['isAdmin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'employeeNumber': employeeNumber,
      'password': password,
      'campus': campus,
      'isDeactivated': isDeactivated,
      'isAdmin': isAdmin,
    };
  }

  bool get isActive => isDeactivated == 0;
}
