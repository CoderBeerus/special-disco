import 'package:aniweb/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('open browser and sections', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AniWebApp()));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Browser'));
    await tester.pumpAndSettle();
    expect(find.text('Search or enter URL'), findsOneWidget);
  });
}
