import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic UI Test', (WidgetTester tester) async {
    // Test super simpel: render satu widget text doang
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Test UI'),
        ),
      ),
    );

    // Pastikan text-nya muncul
    expect(find.text('Test UI'), findsOneWidget);
  });
}
