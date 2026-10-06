import 'package:aniweb/widgets/common/animated_bottom_nav.dart';
import 'package:aniweb/widgets/common/debug_performance_overlay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          shell,
          const DebugPerformanceOverlay(),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: shell.currentIndex,
        onTap: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
      ),
    );
  }
}
