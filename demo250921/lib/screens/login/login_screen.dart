import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/authentication/auth_service.dart';
import 'phone_confirm.dart';
import '../login_silpet_select/mypet_select.dart';
import 'after_signup_splash.dart'; 
import 'id_password_signup.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for privacy password, using auth firebase

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late double widthRatio;
  late double heightRatio;

  Future<bool> _checkUserExists(String uid) async {
    print('🔍 Checking user existence for UID: $uid');
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      print('📄 User document does not exist - treating as new user');
      return false; // No document = new user
    }
    
    print('📄 User document exists - checking onboarding progress');
    // Check if ALL onboarding steps are complete
    final data = userDoc.data();
    final progress = data?['onboardingProgress'] as Map<String, dynamic>?;
    
    if (progress == null) {
      print('❌ No onboarding progress found - treating as incomplete user');
      return false; // No progress tracking = incomplete
    }
    
    // All steps must be completed
    final socialAuth = progress['socialAuthCompleted'] == true;
    final emailPassword = progress['emailPasswordCompleted'] == true;
    final phoneVerified = progress['phoneVerified'] == true;
    final categorySelected = progress['categorySelected'] == true;
    final petSelected = progress['petSelected'] == true;
    final onboardingComplete = progress['onboardingComplete'] == true;
    
    print('📊 Onboarding Progress:');
    print('  - socialAuth: $socialAuth');
    print('  - emailPassword: $emailPassword');
    print('  - phoneVerified: $phoneVerified');
    print('  - categorySelected: $categorySelected');
    print('  - petSelected: $petSelected');
    print('  - onboardingComplete: $onboardingComplete');
    
    final allComplete = socialAuth && emailPassword && phoneVerified && categorySelected && petSelected && onboardingComplete;
    print('✅ All steps complete: $allComplete');
    
    return allComplete;
  }

  Future<void> _markSocialAuthCompleted(String uid) async {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widthRatio = MediaQuery.of(context).size.width / 393.0;
    heightRatio = MediaQuery.of(context).size.height / 852.0;

  }

  @override
  void initState() {
    super.initState();
    print("screens/korean_ui/login_screen.dart is currently showing");
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithIdAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // 사용자가 입력한 ID에 도메인을 추가하여 Firebase Auth가 인식하는 이메일 형식으로 변환합니다.
    final email = '${_idController.text.trim()}@silso.com';
    final password = _passwordController.text.trim();

    try {
      // AuthService를 사용하여 이메일과 비밀번호로 로그인을 시도합니다.
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 로그인 성공 시, 다음 화면으로 이동합니다.
      // mounted 체크를 통해 위젯이 여전히 화면에 있는지 확인합니다.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AfterSignupSplash(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // FirebaseAuth에서 발생하는 예외를 처리합니다.
      String errorMessage = '로그인에 실패했습니다. 다시 시도해주세요.';
      print('FirebaseAuthException code: ${e.code}'); // 디버깅을 위해 에러 코드 출력

      // 에러 코드에 따라 사용자에게 더 친절한 메시지를 보여줍니다.
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = '존재하지 않는 아이디입니다.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = '비밀번호가 일치하지 않습니다.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = '네트워크 연결을 확인해주세요.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // 그 외 일반적인 예외를 처리합니다.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    } finally {
      // 작업이 성공하든 실패하든 로딩 상태를 해제합니다.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);

    try {
      // Enter guest mode (client-side only)
      _authService.enterGuestMode();
      
      if (mounted) {
        // Navigate directly to community page for guests
        Navigator.of(context).pushReplacementNamed('/mvp_community');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게스트 모드 진입 오류: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInAnonymously();
      if (mounted) {
        // 익명 로그인 시에도 PhoneConfirmScreen으로 이동 (회원가입 플로우)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const  MyPetSelect(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

 Widget _buildCircularButton({
  required VoidCallback? onTap,
  required Color backgroundColor,
  String? imagePath,
  IconData? iconData,
  Color? iconColor,
}) {
  // 에러 방지: 두 매개변수 중 하나만 제공되었는지 확인
  assert(imagePath != null || iconData != null, 'Either imagePath or iconData must be provided.');
  assert(imagePath == null || iconData == null, 'Cannot provide both imagePath and iconData.');

  // 버튼 내부에 표시할 위젯을 결정
  Widget content;
  if (imagePath != null) {
    // 이미지 경로가 제공된 경우 Image 위젯 사용
    content = ClipOval(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 72 * widthRatio,
        height: 72 * widthRatio,
      ),
    );
  } else {
    // 아이콘 데이터가 제공된 경우 Icon 위젯 사용
    content = Center(
      child: Icon(
        iconData,
        color: iconColor,
        size: 32 * widthRatio,
      ),
    );
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(400),
      child: Container(
        width: 72 * widthRatio,
        height: 72 * widthRatio,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: const CircleBorder(),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content, // 동적으로 결정된 위젯(content) 사용
      ),
    ),
  );
}

Widget _buildInputField({
  required TextEditingController controller,
  required String hintText,
  bool isPassword = false,
  String? Function(String?)? validator,
}) {
  return Container(
    width: 360 * widthRatio,
    height: 65 * heightRatio,
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: const Color(0xFFBDBDBD),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword, // 비밀번호 필드일 경우 텍스트를 가립니다.
      validator: validator,
      style: TextStyle(
        color: const Color(0xFF121212),
        fontSize: 18 * widthRatio,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        border: InputBorder.none, // 컨테이너에 이미 테두리가 있어 기본 테두리를 제거합니다.
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFFBDBDBD),
          fontSize: 18 * widthRatio,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * widthRatio,
          vertical: 15 * heightRatio,
        ),
      ),
    ),
  );
}

// 기본 버튼 위젯을 만드는 함수
Widget _buildPrimaryButton({
  required String text,
  required VoidCallback? onPressed,
}) {
  return Container(
    width: 360 * widthRatio,
    height: 52 * heightRatio,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5F37CF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * widthRatio),
        ),
        padding: EdgeInsets.symmetric(vertical: 14 * heightRatio),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18 * widthRatio,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          height: 1.23,
        ),
      ),
    ),
  );
}

// lib/screens/login_screen.dart 파일의 build 메서드

@override
Widget build(BuildContext context) {
  // Ratios are still useful for sizing widgets, but not for positioning.
  final double widthRatio = MediaQuery.of(context).size.width / 393.0;
  final double heightRatio = MediaQuery.of(context).size.height / 852.0;

  return Scaffold(
    backgroundColor: const Color(0xFFFAFAFA),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * widthRatio),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
            children: [
              SizedBox(height: 88 * heightRatio), // Space from top

              // Logo Image
              SizedBox(
                width: 90 * widthRatio,
                height: 37 * heightRatio,
                child: Image.asset(
                  'assets/images/silso_logo/login_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 17 * heightRatio),

              // Main Title
              Text(
                '로그인을 시작합니다!',
                style: TextStyle(
                  color: const Color(0xFF121212),
                  fontSize: 24 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6 * heightRatio),

              // Sub Text
              Text(
                '실소의 맴버가 되어주세요!',
                style: TextStyle(
                  color: const Color(0xFFC7C7C7),
                  fontSize: 14 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 35 * heightRatio),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _idController,
                      hintText: '아이디',
                    ),
                    SizedBox(height: 16 * heightRatio),
                    _buildInputField(
                      controller: _passwordController,
                      hintText: '비밀번호',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해 주세요.';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32 * heightRatio),
                    _buildPrimaryButton(
                      text: '로그인',
                      onPressed: _isLoading ? null : _signInWithIdAndPassword,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100 * heightRatio), // Space before social buttons

              // Social Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center buttons horizontally
                children: [
                  _buildCircularButton(
                    onTap: _isLoading ? null : _handleKakaoSignInWithImage,
                    backgroundColor: const Color(0xFFFFE600),
                    imagePath: 'assets/button/kakao_login_circular.png',
                  ),
                  SizedBox(width: 40 * widthRatio),
                  _buildCircularButton(
                    onTap: _isLoading ? null : _handleGoogleSignInWithImage,
                    backgroundColor: Colors.white,
                    imagePath: 'assets/button/google_login_circular.png',
                  ),
                ],
              ),
              SizedBox(height: 100 * heightRatio),

              // Sign Up Button
              Center(
                child: TextButton(
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      color: Color(0xFF5F37CF),
                      fontSize: 15 * widthRatio,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const IDPasswordSignUpScreen(
                                  isIdAndPasswordShortCut: true),
                            ),
                          );
                        },
                ),
              ),
              SizedBox(height: 10 * heightRatio),

              // Browse as Guest Button
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _signInAsGuest,
                  child: Container(
                    width: 138 * widthRatio,
                    height: 26 * heightRatio,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0xFF5F37CF),
                        ),
                        borderRadius: BorderRadius.circular(400),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '비회원으로 구경하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF5F37CF),
                          fontSize: 14 * widthRatio,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20 * heightRatio), // Add some padding at the bottom
            ],
          ),
        ),
      ),
    ),
  );
}



  Future<void> _handleKakaoSignInWithImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 1. Kakao OAuth 로그인 실행
      final userCredential = await _authService.signInWithKakao();

      if (userCredential?.user != null && mounted) {
        // 2. Firebase Auth UID 가져오기
        final String uid = userCredential!.user!.uid;
        print('🔍 Kakao Login - User UID: $uid');

        // 3. Firestore에서 해당 UID로 사용자 문서 존재 확인
        final bool isExistingUser = await _checkUserExists(uid);
        print('🔍 Kakao Login - Is existing user: $isExistingUser');

        // 4. 기존 회원 여부에 따라 플로우 분기
        if (isExistingUser) {
          print('➡️ Kakao Login - Routing to AfterSignupSplash (existing user)');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AfterSignupSplash()),
          );
        } else {
          print('➡️ Kakao Login - Routing to IDPasswordSignUpScreen (new user)');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => IDPasswordSignUpScreen(isIdAndPasswordShortCut: false),
            ),
          );
        }
        
        // Mark social auth as completed for new users
        if (!isExistingUser) {
          await _markSocialAuthCompleted(uid);
          print('✅ Kakao Login - Social auth marked as completed for new user');
        }
      }
    } catch (e) {
      print('❌ Kakao Login Error: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 오류: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _handleGoogleSignInWithImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 1. Google OAuth 로그인 실행
      final userCredential = await _authService.signInWithGoogle();       

      if (userCredential?.user != null && mounted) {
        // 2. Firebase Auth UID 가져오기
        final String uid = userCredential!.user!.uid;
        print('🔍 Google Login - User UID: $uid');

        // 3. Firestore에서 해당 UID로 사용자 문서 존재 확인
        final bool isExistingUser = await _checkUserExists(uid);
        print('🔍 Google Login - Is existing user: $isExistingUser');

        // 4. 기존 회원 여부에 따라 플로우 분기
        if (isExistingUser) {
          print('➡️ Google Login - Routing to AfterSignupSplash (existing user)');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AfterSignupSplash()),
          );
        } else {
          print('➡️ Google Login - Routing to IDPasswordSignUpScreen (new user)');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => IDPasswordSignUpScreen(isIdAndPasswordShortCut: false),
            ),
          );
        }
        
        // Mark social auth as completed for new users
        if (!isExistingUser) {
          await _markSocialAuthCompleted(uid);
          print('✅ Google Login - Social auth marked as completed for new user');
        }
      }
    } catch (e) {
      print('❌ Google Login Error: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 오류: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

}