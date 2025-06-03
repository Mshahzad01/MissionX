class UserModel {
  final String uid;
  final String name;
  final String email;
 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
   
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    double? coins,
    int? level,
    List<String>? tools,
    bool? autoMiner,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? energyBoosts,
    DateTime? lastMiningTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
   
    );
  }
} 