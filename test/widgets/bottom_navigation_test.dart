import 'package:aniweb/widgets/common/animated_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders six sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AnimatedBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Browser'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
