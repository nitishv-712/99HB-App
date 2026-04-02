enum AdminRole { admin, superadmin }

AdminRole _adminRoleFromString(String v) =>
    AdminRole.values.firstWhere((e) => e.name == v);

class ApiAdminUser {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final AdminRole role;
  final String? avatar;
  final bool isActive;
  final String? createdBy;
  final String? lastLoginAt;
  final String createdAt;
  final String updatedAt;

  const ApiAdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    required this.isActive,
    this.createdBy,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiAdminUser.fromJson(Map<String, dynamic> j) => ApiAdminUser(
        id: j['_id'] as String,
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        fullName: j['fullName'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String?,
        role: _adminRoleFromString(j['role'] as String),
        avatar: j['avatar'] as String?,
        isActive: j['isActive'] as bool,
        createdBy: j['createdBy'] as String?,
        lastLoginAt: j['lastLoginAt'] as String?,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role.name,
        'avatar': avatar,
        'isActive': isActive,
        'createdBy': createdBy,
        'lastLoginAt': lastLoginAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
