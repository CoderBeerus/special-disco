import 'package:aniweb/data/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app settings copyWith updates provided fields only', () {
    const settings = AppSettings();
    final next = settings.copyWith(themeMode: ThemeMode.dark, autoplay: true);
    expect(next.themeMode, ThemeMode.dark);
    expect(next.autoplay, isTrue);
    expect(next.homepage, settings.homepage);
  });
}
