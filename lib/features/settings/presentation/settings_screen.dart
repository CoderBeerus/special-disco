import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Content Blocking'),
            value: settings.contentBlockingEnabled,
            onChanged: (v) => controller.setBlockingMode(
              enabled: v,
              strict: settings.strictContentBlocking,
            ),
          ),
          SwitchListTile(
            title: const Text('Strict Blocking'),
            value: settings.strictContentBlocking,
            onChanged: (v) => controller.setBlockingMode(
              enabled: settings.contentBlockingEnabled,
              strict: v,
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settings.themeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (value) {
                if (value != null) controller.updateThemeMode(value);
              },
              items: ThemeMode.values
                  .map((mode) => DropdownMenuItem(value: mode, child: Text(mode.name)))
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
