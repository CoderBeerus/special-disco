class WebsiteShortcut {
  const WebsiteShortcut({
    required this.id,
    required this.name,
    required this.url,
    this.faviconUrl,
    this.category,
    this.isPinned = false,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String url;
  final String? faviconUrl;
  final String? category;
  final bool isPinned;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WebsiteShortcut copyWith({
    String? id,
    String? name,
    String? url,
    String? faviconUrl,
    String? category,
    bool? isPinned,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WebsiteShortcut(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
