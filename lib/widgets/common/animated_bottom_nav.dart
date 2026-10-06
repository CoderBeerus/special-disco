import 'package:flutter/material.dart';

class AnimatedBottomNav extends StatelessWidget {
  const AnimatedBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <NavigationDestination>[
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.language), label: 'Browser'),
      NavigationDestination(icon: Icon(Icons.download), label: 'Downloads'),
      NavigationDestination(icon: Icon(Icons.video_library_outlined), label: 'Gallery'),
      NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'Bookmarks'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
    ];

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: items,
      animationDuration: const Duration(milliseconds: 250),
      height: 72,
    );
  }
}
