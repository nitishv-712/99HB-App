enum UserRole { buyer, seller, agent }

class Card {
  final String? number;
  final String? image;
  final bool isVerified;

  const Card({this.number, this.image, required this.isVerified});

  factory Card.fromJson(Map<String, dynamic> j) => Card(
    number: j['number'] as String?,
    image: j['image'] as String?,
    isVerified: j['isVerified'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'image': image,
    'isVerified': isVerified,
  };
}

class ApiUser {
  final String id;
  final String firstName;
  final String lastName;
  // final String fullName;
  final String email;
  final bool isGmailVerified;
  final String? phone;
  final bool isPhoneVerified;
  final String role;
  final String? avatar;
  final bool isVerified;
  final Card? panCard;
  final Card? aadharCard;
  final String createdAt;
  final String updatedAt;

  const ApiUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    // required this.fullName,
    required this.email,
    required this.isGmailVerified,
    this.phone,
    required this.isPhoneVerified,
    required this.role,
    this.avatar,
    required this.isVerified,
    required this.panCard,
    required this.aadharCard,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiUser.fromJson(Map<String, dynamic> j) => ApiUser(
    id: (j['_id'] ?? j['id']) as String,
    firstName: j['firstName'] as String,
    lastName: j['lastName'] as String,
    email: j['email'] as String,
    isGmailVerified: j['isGmailVerified'] as bool? ?? false,
    phone: j['phone'] as String?,
    isPhoneVerified: j['isPhoneVerified'] as bool? ?? false,
    role: j['role'] as String? ?? 'buyer',
    avatar: j['avatar'] as String?,
    isVerified: j['isVerified'] as bool? ?? false,
    panCard: j['panCard'] != null
        ? Card.fromJson(j['panCard'] as Map<String, dynamic>)
        : null,
    aadharCard: j['aadharCard'] != null
        ? Card.fromJson(j['aadharCard'] as Map<String, dynamic>)
        : null,
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'firstName': firstName,
    'lastName': lastName,
    // 'fullName': fullName,
    'email': email,
    'isGmailVerified': isGmailVerified,
    'phone': phone,
    'isPhoneVerified': isPhoneVerified,
    'role': role,
    'avatar': avatar,
    'isVerified': isVerified,
    'panCard': panCard?.toJson(),
    'aadharCard': aadharCard?.toJson(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
