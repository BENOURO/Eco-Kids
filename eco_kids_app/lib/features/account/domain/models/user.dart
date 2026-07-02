class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final int age;
  final String level;
  final String? profilePhoto;
  final DateTime dateJoined;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.level,
    this.profilePhoto,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
    age: json['age'],
    level: json['level'],
    profilePhoto: json['profilePhoto'],
    dateJoined: DateTime.parse(json['dateJoined']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'age': age,
    'level': level,
    'profilePhoto': profilePhoto,
    'dateJoined': dateJoined.toIso8601String(),
  };
}
