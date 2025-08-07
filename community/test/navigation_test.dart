import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community/main.dart';
import 'package:community/pages/welcome_page.dart';
import 'package:community/views/loading_screen_view.dart';
import 'package:community/pages/category_selection_page.dart';

void main() {
  group('Navigation Flow Tests', () {
    testWidgets('Welcome page displays Join Community button', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify that WelcomePage is displayed
      expect(find.byType(WelcomePage), findsOneWidget);
      
      // Verify Join Community button exists
      expect(find.text('Join Community'), findsOneWidget);
      
      // Verify welcome message
      expect(find.text('실소 커뮤니티에 참여하세요!'), findsOneWidget);
    });

    testWidgets('Join Community button navigates to loading screen', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Find and tap the Join Community button
      final joinButton = find.text('Join Community');
      expect(joinButton, findsOneWidget);
      
      await tester.tap(joinButton);
      await tester.pumpAndSettle();

      // Verify that LoadingScreenView is displayed
      expect(find.byType(LoadingScreenView), findsOneWidget);
    });

    testWidgets('Loading screen automatically navigates to category selection', (WidgetTester tester) async {
      // Build the app and navigate to loading screen
      await tester.pumpWidget(const MyApp());
      
      // Tap Join Community button
      await tester.tap(find.text('Join Community'));
      await tester.pumpAndSettle();
      
      // Verify loading screen is shown
      expect(find.byType(LoadingScreenView), findsOneWidget);
      
      // Wait for loading to complete (3 seconds + some buffer)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      
      // Verify that CategorySelectionPage is displayed
      expect(find.byType(CategorySelectionPage), findsOneWidget);
    });

    testWidgets('Full navigation flow works correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Step 1: Start with WelcomePage
      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.text('Join Community'), findsOneWidget);

      // Step 2: Navigate to LoadingScreenView
      await tester.tap(find.text('Join Community'));
      await tester.pumpAndSettle();
      expect(find.byType(LoadingScreenView), findsOneWidget);

      // Step 3: Wait for loading to complete and navigate to CategorySelectionPage
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.byType(CategorySelectionPage), findsOneWidget);

      // Verify category selection UI elements are present
      expect(find.text('관심사 선택'), findsOneWidget);
    });
  });
}