class BrowserHistory {
  BrowserHistory({
    required this.id,
    required this.url,
    required this.title,
    this.favicon,
    required this.timestamp,
  });

  final String id;
  final String url;
  final String title;
  final String? favicon;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'favicon': favicon,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BrowserHistory.fromMap(Map<String, dynamic> map) {
    return BrowserHistory(
      id: map['id'],
      url: map['url'],
      title: map['title'],
      favicon: map['favicon'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
