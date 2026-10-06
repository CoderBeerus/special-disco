class WebsiteBookmarkGroup {
  const WebsiteBookmarkGroup({
    required this.id,
    required this.websiteName,
    required this.domain,
    this.favicon,
    this.bookmarkCount = 0,
    required this.createdAt,
    this.sortOrder = 0,
  });

  final String id;
  final String websiteName;
  final String domain;
  final String? favicon;
  final int bookmarkCount;
  final DateTime createdAt;
  final int sortOrder;

  WebsiteBookmarkGroup copyWith({
    String? id,
    String? websiteName,
    String? domain,
    String? favicon,
    int? bookmarkCount,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return WebsiteBookmarkGroup(
      id: id ?? this.id,
      websiteName: websiteName ?? this.websiteName,
      domain: domain ?? this.domain,
      favicon: favicon ?? this.favicon,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
