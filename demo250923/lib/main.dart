
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/authentication/korean_auth_service.dart';
import 'config/kakao_config.dart';
import 'screens/splash_screen.dart';
// Community UI imports
import 'screens/login/login_screen.dart';
import 'screens/login/intro_after_login_splash2.dart';  // After login flow 
import 'screens/community/community_main.dart';
import 'screens/temporary_home.dart'; // Temporary home page
import 'widgets/navigation_bar.dart'; // Main Navigation Bar
import 'screens/contents_page/contents_main.dart'; // Contents page
import 'screens/my_page/my_page_main.dart'; // My page
// Initial login & sign_up
import 'screens/login/id_password_signup.dart'; 
import 'screens/login/intro_signin_splash.dart';
import 'screens/login/phone_confirm.dart'; 
import 'screens/login/category_selection_screen.dart'; 
import 'screens/login/after_signup_splash.dart';
import 'screens/login/policy_agreement_screen.dart';
import 'screens/login_silpet_select/mypet_select.dart';

import 'court_prototype/silso_court_main.dart';

import 'package:flutter/foundation.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha.dart';

class _NoTransitionPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Kakao SDK with correct keys for each platform
  await KoreanAuthService.initialize(
    kakaoAppKey: AuthConfig.kakaoJavascriptKey, // JavaScript key for web
    nativeAppKey: AuthConfig.kakaoNativeAppKey, // Native app key for mobile
  );

  // Initialize reCAPTCHA only for mobile platforms (not web)
  if (!kIsWeb) {
    try {
      // Platform-specific reCAPTCHA site keys for mobile only
      String siteKey;
      if (defaultTargetPlatform == TargetPlatform.android) {
        siteKey = "6Ldsy5krAAAAAJ8WA_yTis_appCYssKMc4Z9Fp5E";
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        siteKey = "6Ld2MZkrAAAAANhGiZTCyJ4LB83DV-rWL7Eosw6v";
      } else {
        siteKey = "6LewvNUrAAAAALwfV2QU4BTGRj6bwcUuQjchfJv0";
      }

      await Recaptcha.fetchClient(siteKey);
      print('✅ reCAPTCHA initialized for mobile platform');
    } catch (e) {
      print('⚠️ reCAPTCHA initialization failed: $e');
    }
  } else {
    print('📱 Web platform: Firebase will handle reCAPTCHA automatically');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silso',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoTransitionPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoTransitionPageTransitionsBuilder(),
            TargetPlatform.windows: _NoTransitionPageTransitionsBuilder(),
            TargetPlatform.macOS: _NoTransitionPageTransitionsBuilder(),
            TargetPlatform.linux: _NoTransitionPageTransitionsBuilder(),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>  SplashScreen(),
        '/login': (context) => const LoginScreen(), // Korean UI
        '/after-login-splash': (context) => const AfterLoginSplashScreen(), // Korean UI
        '/temporary-home': (context) => const TemporaryHomePage(), // Temporary home
        '/main-navigation': (context) => const MainNavigationBar(), // Main Navigation with 3 tabs
        '/contents-main': (context) => const ContentsMainPage(), // Contents page
        '/my-page': (context) => const MyPageMain(), // My page
        '/mvp_community' : (context) => const CommunityMainTabScreenMycom(), // Korean UI
        // Initial profile setup flow
        // '/intro-community-splash': (context) => const IntroCommunitySplash(),
        // // '/category-selection': (context) => const CategorySelectionScreen(),
        // '/profile-information': (context) => const ProfileInformationScreen(),
        //'/policy-agreement': (context) => const PolicyAgreementScreen(),
        // initial login flow
        '/login-splash' : (context) => const SigininSplashScreen(), 
        '/id-password-signup': (context) => const IDPasswordSignUpScreen(isIdAndPasswordShortCut: false),
        '/login-phone-confirm' : (context) => const PhoneConfirmScreen(), 
        '/category-selection': (context) => const CategorySelectionScreen(),
        '/after-signup' : (context) => const AfterSignupSplash(), 
        '/policy-agreement': (context) => const PolicyAgreementScreen(),
        '/pet-creation': (context) => const MyPetSelect(),
      },
    );
  }
}

