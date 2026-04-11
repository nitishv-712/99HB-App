import 'package:homebazaar/model/property.dart';

// ─── Saved Property ───────────────────────────────────────────────────────────

class ApiSavedProperty {
  final String id;
  final String user;

  /// Populated [ApiProperty] or raw ID string
  final dynamic property;

  final String savedAt;

  const ApiSavedProperty({
    required this.id,
    required this.user,
    required this.property,
    required this.savedAt,
  });

  factory ApiSavedProperty.fromJson(Map<String, dynamic> j) => ApiSavedProperty(
    id: j['_id'] as String,
    user: j['user'] as String,
    property: j['property'] is Map
        ? ApiProperty.fromJson(j['property'] as Map<String, dynamic>)
        : j['property'] as String,
    savedAt: j['savedAt'] as String,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user,
    'property': property is ApiProperty
        ? (property as ApiProperty).toJson()
        : property,
    'savedAt': savedAt,
  };
}

// ─── Search History ───────────────────────────────────────────────────────────

class ApiSearchHistory {
  final String id;
  final String user;
  final String query;
  final Map<String, dynamic> filters;
  final String createdAt;
  final String updatedAt;

  const ApiSearchHistory({
    required this.id,
    required this.user,
    required this.query,
    required this.filters,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiSearchHistory.fromJson(Map<String, dynamic> j) => ApiSearchHistory(
    id: j['_id'] as String,
    user: j['user'] as String,
    query: j['query'] as String,
    filters: Map<String, dynamic>.from(j['filters'] as Map),
    createdAt: j['createdAt'] as String,
    updatedAt: j['updatedAt'] as String,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user,
    'query': query,
    'filters': filters,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// ─── Newsletter ───────────────────────────────────────────────────────────────

class ApiNewsletter {
  final String id;
  final String email;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const ApiNewsletter({
    required this.id,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiNewsletter.fromJson(Map<String, dynamic> j) => ApiNewsletter(
    id: j['_id'] as String,
    email: j['email'] as String,
    isActive: j['isActive'] as bool,
    createdAt: j['createdAt'] as String,
    updatedAt: j['updatedAt'] as String,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'isActive': isActive,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// ─── OTP ──────────────────────────────────────────────────────────────────────

class ApiOtp {
  final String id;
  final String? email;
  final String? phone;
  final bool isVerified;
  final int attempts;
  final String expiresAt;
  final String createdAt;

  const ApiOtp({
    required this.id,
    this.email,
    this.phone,
    required this.isVerified,
    required this.attempts,
    required this.expiresAt,
    required this.createdAt,
  });

  factory ApiOtp.fromJson(Map<String, dynamic> j) => ApiOtp(
    id: j['_id'] as String,
    email: j['email'] as String?,
    phone: j['phone'] as String?,
    isVerified: j['isVerified'] as bool,
    attempts: j['attempts'] as int,
    expiresAt: j['expiresAt'] as String,
    createdAt: j['createdAt'] as String,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'phone': phone,
    'isVerified': isVerified,
    'attempts': attempts,
    'expiresAt': expiresAt,
    'createdAt': createdAt,
  };
}

// ─── Upload ───────────────────────────────────────────────────────────────────

enum UploadFolder { avatar, aadhar, pancards, properties }

class UploadLinkResponse {
  final String uploadUrl;
  final String viewUrl;
  final String filePath;

  const UploadLinkResponse({
    required this.uploadUrl,
    required this.viewUrl,
    required this.filePath,
  });

  factory UploadLinkResponse.fromJson(Map<String, dynamic> j) =>
      UploadLinkResponse(
        uploadUrl: j['uploadUrl'] as String,
        viewUrl: j['viewUrl'] as String,
        filePath: j['filePath'] as String,
      );

  Map<String, dynamic> toJson() => {
    'uploadUrl': uploadUrl,
    'viewUrl': viewUrl,
    'filePath': filePath,
  };
}
