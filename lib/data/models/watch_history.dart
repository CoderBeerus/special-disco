class WatchHistory {
  WatchHistory({
    required this.id,
    required this.title,
    required this.url,
    this.thumbnail,
    required this.positionMs,
    required this.durationMs,
    required this.lastPlayed,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String url;
  final String? thumbnail;
  final int positionMs;
  final int durationMs;
  final DateTime lastPlayed;
  final bool isCompleted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
      'position_ms': positionMs,
      'duration_ms': durationMs,
      'last_played': lastPlayed.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory WatchHistory.fromMap(Map<String, dynamic> map) {
    return WatchHistory(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      thumbnail: map['thumbnail'],
      positionMs: map['position_ms'] as int,
      durationMs: map['duration_ms'] as int,
      lastPlayed: DateTime.parse(map['last_played']),
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }
}
