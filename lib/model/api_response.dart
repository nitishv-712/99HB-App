import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;
  final T data;
  final Pagination? pagination;

  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class Pagination {
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(defaultValue: 20)
  final int limit;
  // API returns either 'pages' or 'totalPages'
  @JsonKey(name: 'pages', defaultValue: 0)
  final int pages;

  const Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    // handle both 'pages' and 'totalPages' keys
    final j = Map<String, dynamic>.from(json);
    j['pages'] ??= j['totalPages'] ?? 0;
    return _$PaginationFromJson(j);
  }

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
