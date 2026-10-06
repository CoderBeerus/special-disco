import 'package:aniweb/state/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugPerformanceOverlay extends ConsumerWidget {
  const DebugPerformanceOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kReleaseMode) return const SizedBox.shrink();
    final downloads = ref.watch(downloadsProvider).length;
    return Positioned(
      right: 12,
      top: 12,
      child: Card(
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontSize: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Downloads: $downloads'),
                const Text('FPS: debug tools'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
