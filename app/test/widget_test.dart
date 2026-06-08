import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/main.dart';

import 'package:wardrobe_app/features/pages/login_page.dart';

void main() {
  testWidgets('shows validation message on empty login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WardrobeApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email and password.'), findsOneWidget);
  });

  testWidgets('shows the wardrobe app tabs after auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WardrobeShell()));

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Wardrobe'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Explore'), findsWidgets);
    expect(find.text('Account'), findsWidgets);

    await tester.tap(find.byIcon(Icons.checkroom_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Silk blouse'), findsOneWidget);
    expect(find.text('Wide-leg jeans'), findsOneWidget);
  });
}
