import 'package:aniweb/features/gallery/presentation/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery screen renders app bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
    expect(find.text('Gallery'), findsOneWidget);
  });
}
