class Pagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  const Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> j) => Pagination(
        total: j['total'] as int,
        page: j['page'] as int,
        limit: j['limit'] as int,
        pages: j['pages'] as int,
      );

  Map<String, dynamic> toJson() => {
        'total': total,
        'page': page,
        'limit': limit,
        'pages': pages,
      };
}

class ApiResponse<T> {
  final bool success;
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
    Map<String, dynamic> j,
    T Function(dynamic) fromData,
  ) =>
      ApiResponse(
        success: j['success'] as bool,
        message: j['message'] as String,
        data: fromData(j['data']),
        pagination: j['pagination'] != null
            ? Pagination.fromJson(j['pagination'] as Map<String, dynamic>)
            : null,
      );
}

class PaginatedResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final Pagination pagination;

  const PaginatedResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) fromItem,
  ) =>
      PaginatedResponse(
        success: j['success'] as bool,
        message: j['message'] as String,
        data: (j['data'] as List).map((e) => fromItem(e as Map<String, dynamic>)).toList(),
        pagination: Pagination.fromJson(j['pagination'] as Map<String, dynamic>),
      );
}
