import 'package:aniweb/data/repositories/bookmark_repository.dart';
import 'package:aniweb/data/repositories/shortcut_repository.dart';
import 'package:aniweb/data/models/page_bookmark.dart';
import 'package:aniweb/data/models/website_bookmark_group.dart';
import 'package:aniweb/data/models/website_shortcut.dart';
import 'dart:async';
import 'dart:convert';

import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/models/app_settings.dart';
import 'package:aniweb/data/models/download_item.dart';
import 'package:aniweb/data/models/media_source.dart';
import 'package:aniweb/data/repositories/download_repository.dart';
import 'package:aniweb/services/download/download_manager_service.dart';
import 'package:aniweb/services/media_detection/media_detection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs) : super(const AppSettings()) {
    _loadSettings();
  }

  final SharedPreferences _prefs;
  static const _settingsKey = 'app_settings';

  void _loadSettings() {
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        state = AppSettings.fromJson(jsonDecode(settingsJson));
      } catch (e) {
        // Fallback to default
      }
    }
  }

  Future<void> _saveSettings(AppSettings newSettings) async {
    state = newSettings;
    await _prefs.setString(_settingsKey, jsonEncode(newSettings.toJson()));
  }

  void updateThemeMode(ThemeMode mode) {
    _saveSettings(state.copyWith(themeMode: mode));
  }

  void setBlockingMode({required bool enabled, required bool strict}) {
    _saveSettings(state.copyWith(
      contentBlockingEnabled: enabled,
      strictContentBlocking: strict,
    ));
  }
}

final mediaDetectionServiceProvider = Provider<MediaDetectionService>(
  (ref) => MediaDetectionService(),
);

final detectedMediaProvider = StateProvider<List<MediaSource>>((ref) => []);

final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => DownloadRepository(LocalDatabase.instance),
);

final downloadManagerServiceProvider = Provider<DownloadManagerService>((ref) {
  final service = DownloadManagerService(ref.read(downloadRepositoryProvider));
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final downloadsProvider =
    StateNotifierProvider<DownloadsController, List<DownloadItem>>((ref) {
  return DownloadsController(ref.read(downloadManagerServiceProvider));
});

class DownloadsController extends StateNotifier<List<DownloadItem>> {
  DownloadsController(this._service) : super(const []) {
    _bootstrap();
  }

  final DownloadManagerService _service;
  StreamSubscription<DownloadItem>? _subscription;

  Future<void> _bootstrap() async {
    state = await _service.getSavedDownloads();
    _subscription = _service.updates.listen((item) {
      final next = [...state];
      final index = next.indexWhere((e) => e.id == item.id);
      if (index == -1) {
        next.insert(0, item);
      } else {
        next[index] = item;
      }
      state = next;
    });
  }

  Future<void> enqueue(String url, String title) => _service.enqueue(
        url: url,
        title: title,
      );

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final shortcutRepositoryProvider = Provider<ShortcutRepository>(
  (ref) => ShortcutRepository(LocalDatabase.instance),
);

final bookmarkRepositoryProvider = Provider<BookmarkRepository>(
  (ref) => BookmarkRepository(LocalDatabase.instance),
);

final shortcutsProvider =
    StateNotifierProvider<ShortcutsController, AsyncValue<List<WebsiteShortcut>>>((ref) {
  return ShortcutsController(ref.read(shortcutRepositoryProvider));
});

class ShortcutsController extends StateNotifier<AsyncValue<List<WebsiteShortcut>>> {
  ShortcutsController(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  final ShortcutRepository _repository;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final shortcuts = await _repository.getAll();
      state = AsyncValue.data(shortcuts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addShortcut(String name, String url, {String? faviconUrl}) async {
    await _repository.addShortcut(name: name, url: url, faviconUrl: faviconUrl);
    await refresh();
  }

  Future<void> updateShortcut(WebsiteShortcut shortcut) async {
    await _repository.updateShortcut(shortcut);
    await refresh();
  }

  Future<void> deleteShortcut(String id) async {
    await _repository.deleteShortcut(id);
    await refresh();
  }

  Future<void> reorderShortcuts(List<String> ids) async {
    // Optimistic update
    if (state.hasValue) {
      final current = state.value!;
      final newMap = {for (var e in current) e.id: e};
      final reordered = ids.map((id) => newMap[id]!).toList();
      state = AsyncValue.data(reordered);
    }
    await _repository.reorderShortcuts(ids);
    await refresh();
  }
}

final bookmarkGroupsProvider =
    StateNotifierProvider<BookmarkGroupsController, AsyncValue<List<WebsiteBookmarkGroup>>>((ref) {
  return BookmarkGroupsController(ref.read(bookmarkRepositoryProvider));
});

class BookmarkGroupsController extends StateNotifier<AsyncValue<List<WebsiteBookmarkGroup>>> {
  BookmarkGroupsController(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  final BookmarkRepository _repository;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final groups = await _repository.getAllGroups();
      state = AsyncValue.data(groups);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGroup(String id) async {
    await _repository.deleteGroup(id);
    await refresh();
  }

  Future<void> reorderGroups(List<String> ids) async {
     // Optimistic update
    if (state.hasValue) {
      final current = state.value!;
      final newMap = {for (var e in current) e.id: e};
      final reordered = ids.map((id) => newMap[id]!).toList();
      state = AsyncValue.data(reordered);
    }
    await _repository.reorderGroups(ids);
    await refresh();
  }
}

final bookmarksForGroupProvider = FutureProvider.family<List<PageBookmark>, String>((ref, groupId) async {
  final repo = ref.read(bookmarkRepositoryProvider);
  return repo.getBookmarksForGroup(groupId);
});
