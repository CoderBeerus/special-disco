import 'package:media_kit/media_kit.dart';

class PlaybackService {
  PlaybackService() {
    MediaKit.ensureInitialized();
    _player = Player();
  }

  late final Player _player;
  Player get player => _player;

  Future<void> open(String url) => _player.open(Media(url));
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setRate(double rate) => _player.setRate(rate);

  Future<void> dispose() => _player.dispose();
}
