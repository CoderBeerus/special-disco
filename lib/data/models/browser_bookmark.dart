class BrowserBookmark {
  const BrowserBookmark({
    required this.url,
    required this.title,
    required this.createdAt,
  });

  final String url;
  final String title;
  final DateTime createdAt;
}
