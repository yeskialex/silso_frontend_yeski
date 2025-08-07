import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community/main.dart';
import 'package:community/views/splash_screen_view.dart';
import 'package:community/pages/welcome_page.dart';
import 'package:community/views/loading_screen_view.dart';
import 'package:community/pages/category_selection_page.dart';
import 'package:community/models/splash_screen_model.dart';

void main() {
  group('Splash Screen Navigation Tests', () {
    testWidgets('App starts with splash screen', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify that SplashScreenView is displayed
      expect(find.byType(SplashScreenView), findsOneWidget);
      
      // Verify splash screen content
      expect(find.text(SplashScreenModel.appName), findsOneWidget);
      expect(find.text(SplashScreenModel.appSubtitle), findsOneWidget);
      expect(find.text('v${SplashScreenModel.appVersion}'), findsOneWidget);
      
      // Verify loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Splash screen shows for exactly 5 seconds then navigates to welcome', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify splash screen is shown
      expect(find.byType(SplashScreenView), findsOneWidget);
      expect(find.byType(WelcomePage), findsNothing);

      // Test that splash screen is still showing before 5 seconds
      await tester.pump(const Duration(seconds: 4, milliseconds: 500));
      expect(find.byType(SplashScreenView), findsOneWidget);
      expect(find.byType(WelcomePage), findsNothing);

      // Wait for the remaining time plus small buffer
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify navigation to welcome page
      expect(find.byType(SplashScreenView), findsNothing);
      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.text('Join Community'), findsOneWidget);
    });

    testWidgets('Complete navigation flow: Splash → Welcome → Loading → Category', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Step 1: Verify splash screen
      expect(find.byType(SplashScreenView), findsOneWidget);
      expect(find.text(SplashScreenModel.appName), findsOneWidget);

      // Step 2: Wait for splash to complete and navigate to welcome
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.text('Join Community'), findsOneWidget);

      // Step 3: Tap Join Community button to navigate to loading
      await tester.tap(find.text('Join Community'));
      await tester.pumpAndSettle();
      expect(find.byType(LoadingScreenView), findsOneWidget);

      // Step 4: Wait for loading to complete and navigate to category selection
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.byType(CategorySelectionPage), findsOneWidget);
    });

    testWidgets('Splash screen animations work correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify initial state
      expect(find.byType(SplashScreenView), findsOneWidget);
      
      // Pump a few frames to let animations start
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      
      // Verify animated elements are still present
      expect(find.text(SplashScreenModel.appName), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.forum_rounded), findsOneWidget);
    });

    testWidgets('Skip button works in debug mode', (WidgetTester tester) async {
      // This test only runs in debug mode where skip button is visible
      await tester.pumpWidget(const MyApp());

      // Verify splash screen is shown
      expect(find.byType(SplashScreenView), findsOneWidget);

      // In debug mode, skip button should be present
      // Note: Skip button visibility depends on debug mode
      if (find.text('Skip').evaluate().isNotEmpty) {
        // Tap skip button
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        // Should navigate directly to welcome page
        expect(find.byType(WelcomePage), findsOneWidget);
        expect(find.byType(SplashScreenView), findsNothing);
      }
    });

    testWidgets('Splash screen handles multiple rapid pumps', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Rapidly pump multiple times to test stability
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should still be on splash screen
      expect(find.byType(SplashScreenView), findsOneWidget);
      
      // Wait for completion
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      
      // Should navigate to welcome
      expect(find.byType(WelcomePage), findsOneWidget);
    });

    testWidgets('Splash screen minimum 5-second guarantee test', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Record start time
      final startTime = DateTime.now();
      
      // Verify splash screen is shown
      expect(find.byType(SplashScreenView), findsOneWidget);

      // Pump in small intervals until navigation occurs
      bool navigationOccurred = false;
      DateTime? navigationTime;
      
      while (!navigationOccurred && DateTime.now().difference(startTime).inSeconds < 10) {
        await tester.pump(const Duration(milliseconds: 100));
        
        if (find.byType(WelcomePage).evaluate().isNotEmpty) {
          navigationOccurred = true;
          navigationTime = DateTime.now();
        }
      }

      // Verify navigation occurred
      expect(navigationOccurred, true);
      expect(navigationTime, isNotNull);
      
      // Verify minimum 5 seconds elapsed
      if (navigationTime != null) {
        final elapsedTime = navigationTime.difference(startTime);
        expect(elapsedTime.inSeconds, greaterThanOrEqualTo(5));
        print('실제 스플래시 표시 시간: ${elapsedTime.inMilliseconds}ms');
      }
    });
  });

  group('Splash Screen Component Tests', () {
    testWidgets('Splash screen displays all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreenView(),
        ),
      );

      // Verify all key elements are present
      expect(find.text(SplashScreenModel.appName), findsOneWidget);
      expect(find.text(SplashScreenModel.appSubtitle), findsOneWidget);
      expect(find.text('v${SplashScreenModel.appVersion}'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.forum_rounded), findsOneWidget);
    });

    testWidgets('Splash screen has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreenView(),
        ),
      );

      // Find the main scaffold
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFF5F37CF)));

      // Verify text styling (basic checks)
      final appNameText = tester.widget<Text>(find.text(SplashScreenModel.appName));
      expect(appNameText.style?.color, equals(Colors.white));
      expect(appNameText.style?.fontSize, equals(36));
      expect(appNameText.style?.fontWeight, equals(FontWeight.bold));
    });
  });
}