import 'package:aniweb/core/routing/app_router.dart';
import 'package:aniweb/core/theme/app_theme.dart';
import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AniWebApp extends ConsumerWidget {
  const AniWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp.router(
      title: 'AniWeb',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
