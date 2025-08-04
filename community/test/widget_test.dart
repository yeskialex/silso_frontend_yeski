// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:community/main.dart';

void main() {
  testWidgets('Community app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the certification page is displayed.
    expect(find.text('포트원 V1 본인인증'), findsOneWidget);
    expect(find.text('잠시만 기다려주세요...'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user), findsOneWidget);
  });
}
