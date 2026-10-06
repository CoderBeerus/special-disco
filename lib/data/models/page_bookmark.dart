class PageBookmark {
  const PageBookmark({
    required this.id,
    required this.groupId,
    required this.title,
    required this.url,
    required this.domain,
    this.favicon,
    this.thumbnail,
    required this.dateAdded,
    this.lastVisited,
    this.customTitle,
    this.notes,
    this.sortOrder = 0,
  });

  final String id;
  final String groupId;
  final String title;
  final String url;
  final String domain;
  final String? favicon;
  final String? thumbnail;
  final DateTime dateAdded;
  final DateTime? lastVisited;
  final String? customTitle;
  final String? notes;
  final int sortOrder;

  PageBookmark copyWith({
    String? id,
    String? groupId,
    String? title,
    String? url,
    String? domain,
    String? favicon,
    String? thumbnail,
    DateTime? dateAdded,
    DateTime? lastVisited,
    String? customTitle,
    String? notes,
    int? sortOrder,
  }) {
    return PageBookmark(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      url: url ?? this.url,
      domain: domain ?? this.domain,
      favicon: favicon ?? this.favicon,
      thumbnail: thumbnail ?? this.thumbnail,
      dateAdded: dateAdded ?? this.dateAdded,
      lastVisited: lastVisited ?? this.lastVisited,
      customTitle: customTitle ?? this.customTitle,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
