import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.homepage = 'https://www.google.com',
    this.contentBlockingEnabled = true,
    this.strictContentBlocking = false,
    this.gestureControls = true,
    this.autoplay = false,
    this.defaultPlaybackSpeed = 1.0,
  });

  final ThemeMode themeMode;
  final String homepage;
  final bool contentBlockingEnabled;
  final bool strictContentBlocking;
  final bool gestureControls;
  final bool autoplay;
  final double defaultPlaybackSpeed;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? homepage,
    bool? contentBlockingEnabled,
    bool? strictContentBlocking,
    bool? gestureControls,
    bool? autoplay,
    double? defaultPlaybackSpeed,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      homepage: homepage ?? this.homepage,
      contentBlockingEnabled: contentBlockingEnabled ?? this.contentBlockingEnabled,
      strictContentBlocking: strictContentBlocking ?? this.strictContentBlocking,
      gestureControls: gestureControls ?? this.gestureControls,
      autoplay: autoplay ?? this.autoplay,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'homepage': homepage,
      'contentBlockingEnabled': contentBlockingEnabled,
      'strictContentBlocking': strictContentBlocking,
      'gestureControls': gestureControls,
      'autoplay': autoplay,
      'defaultPlaybackSpeed': defaultPlaybackSpeed,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? ThemeMode.system.index],
      homepage: json['homepage'] as String? ?? 'https://www.google.com',
      contentBlockingEnabled: json['contentBlockingEnabled'] as bool? ?? true,
      strictContentBlocking: json['strictContentBlocking'] as bool? ?? false,
      gestureControls: json['gestureControls'] as bool? ?? true,
      autoplay: json['autoplay'] as bool? ?? false,
      defaultPlaybackSpeed: (json['defaultPlaybackSpeed'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
