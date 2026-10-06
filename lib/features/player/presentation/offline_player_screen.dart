import 'package:aniweb/features/player/presentation/online_player_screen.dart';
import 'package:flutter/material.dart';

class OfflinePlayerScreen extends StatelessWidget {
  const OfflinePlayerScreen({
    required this.filePath,
    required this.title,
    super.key,
  });

  final String filePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return OnlinePlayerScreen(url: filePath, title: title);
  }
}
