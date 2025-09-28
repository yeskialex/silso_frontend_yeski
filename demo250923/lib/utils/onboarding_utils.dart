import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingUtils {
  /// Mark social authentication as completed for a user
  static Future<void> markSocialAuthCompleted(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'onboardingProgress': {
          'socialAuthCompleted': true,
          'emailPasswordCompleted': false,
          'phoneVerified': false,
          'categorySelected': false,
          'petSelected': false,
          'onboardingComplete': false,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error marking social auth completed: $e');
    }
  }
}