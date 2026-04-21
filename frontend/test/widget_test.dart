import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('SmartRestaurantApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SmartRestaurantApp()));

    // Verify that the splash screen shows up initially (CircularProgressIndicator).
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
