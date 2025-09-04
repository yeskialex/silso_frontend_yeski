import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication/auth_service.dart';

class OnboardingGuardService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if current user has completed ALL onboarding steps
  static Future<bool> isOnboardingComplete() async {
    try {
      // Check if user is in guest mode - guests bypass onboarding
      final authService = AuthService();
      if (authService.isGuest) {
        return true; // Guests bypass onboarding
      }
      
      final User? user = _auth.currentUser;
      if (user == null) {
        print('🚫 OnboardingGuard: No authenticated user found');
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        print('🚫 OnboardingGuard: User document does not exist for UID: ${user.uid}');
        return false;
      }

      final data = userDoc.data();
      final progress = data?['onboardingProgress'] as Map<String, dynamic>?;
      
      if (progress == null) {
        print('🚫 OnboardingGuard: No onboarding progress found for UID: ${user.uid}');
        return false;
      }

      // Check all required onboarding steps
      final socialAuth = progress['socialAuthCompleted'] == true;
      final emailPassword = progress['emailPasswordCompleted'] == true;
      final phoneVerified = progress['phoneVerified'] == true;
      final categorySelected = progress['categorySelected'] == true;
      final petSelected = progress['petSelected'] == true;
      final onboardingComplete = progress['onboardingComplete'] == true;
      
      // Check policy agreement timestamp
      final policyAgreementTimestamp = data?['policyAgreementTimestamp'];
      final policyAgreed = policyAgreementTimestamp != null;
      
      print('📊 OnboardingGuard: Progress for UID ${user.uid}:');
      print('  - socialAuth: $socialAuth');
      print('  - emailPassword: $emailPassword');
      print('  - phoneVerified: $phoneVerified');
      print('  - categorySelected: $categorySelected');
      print('  - policyAgreed: $policyAgreed');
      print('  - petSelected: $petSelected');
      print('  - onboardingComplete: $onboardingComplete');

      final allComplete = socialAuth && emailPassword && phoneVerified && 
                         categorySelected && policyAgreed && petSelected && onboardingComplete;
      
      print(allComplete 
        ? '✅ OnboardingGuard: All onboarding steps completed'
        : '❌ OnboardingGuard: Onboarding incomplete, blocking access');
        
      return allComplete;
      
    } catch (e) {
      print('❌ OnboardingGuard: Error checking onboarding status: $e');
      return false; // On error, assume incomplete
    }
  }

  /// Get the next onboarding step for incomplete users
  static Future<String> getNextOnboardingRoute() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return '/login';
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        return '/login';
      }

      final data = userDoc.data();
      final progress = data?['onboardingProgress'] as Map<String, dynamic>?;
      
      if (progress == null) {
        return '/login';
      }

      // Check policy agreement
      final policyAgreementTimestamp = data?['policyAgreementTimestamp'];
      final policyAgreed = policyAgreementTimestamp != null;

      // Determine next step based on completion status
      if (progress['socialAuthCompleted'] != true) {
        return '/login';
      } else if (progress['emailPasswordCompleted'] != true) {
        return '/id-password-signup';
      } else if (progress['phoneVerified'] != true) {
        return '/login-phone-confirm';
      } else if (progress['categorySelected'] != true) {
        return '/category-selection';
      } else if (!policyAgreed) {
        return '/policy-agreement';
      } else if (progress['petSelected'] != true) {
        return '/pet-creation';
      } else {
        return '/after-signup'; // All done
      }
    } catch (e) {
      print('❌ OnboardingGuard: Error determining next route: $e');
      return '/login';
    }
  }

  /// Validate and redirect if onboarding is incomplete
  /// Returns true if user can proceed, false if they need to complete onboarding
  static Future<bool> validateAccess() async {
    // Guests can always access community (read-only)
    final authService = AuthService();
    if (authService.isGuest) {
      return true;
    }
    
    final isComplete = await isOnboardingComplete();
    if (!isComplete) {
      print('🚫 OnboardingGuard: Access denied - onboarding incomplete');
    }
    return isComplete;
  }
}