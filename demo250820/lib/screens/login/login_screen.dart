import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSignUp = false;
  late double widthRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widthRatio = MediaQuery.of(context).size.width / 393.0;
  }

  @override
  void initState() {
    super.initState();
    print("screens/korean_ui/login_screen.dart is currently showing");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await _authService.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed( '/after-login-splash');
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

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInAnonymously();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed( '/after-login-splash');
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
  required String imagePath,
}) {
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
        child:ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 72 * widthRatio,
          height: 72 * widthRatio,
        ),
      ),
      ),
    ),
  );
}


// lib/screens/login_screen.dart 파일의 build 메서드

  void _showButtonPressDialog(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$provider Button Pressed!'),
      backgroundColor: Colors.black26,
      duration: const Duration(milliseconds: 400),
    ));
  }


@override
Widget build(BuildContext context) {
  // 기준 해상도 (iPhone 16)
  const double baseWidth = 393.0;
  const double baseHeight = 852.0;

  // 현재 화면의 너비와 높이를 가져와 비율 계산
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final double widthRatio = screenWidth / baseWidth;
  final double heightRatio = screenHeight / baseHeight;

  // 새로운 디자인에서는 어두운 배경 대신 밝은 배경을 사용
  return Scaffold(
    backgroundColor: const Color(0xFFFAFAFA),
    body: Stack(
      children: [

        // 로고 이미지
        // silso-logo
        Positioned(
        left: 16 * widthRatio,
        top: 145 * heightRatio,
        child: SizedBox(
        width: 90 * widthRatio,
        height: 37 * heightRatio,
        child: Image.asset(
        'assets/images/silso_logo/login_logo.png', // 확장자를 .svg에서 .png로 변경
        fit: BoxFit.contain, // 또는 BoxFit.fill 등 필요에 따라 조절
        ),
        ),
        ),

        // 메인 제목
        Positioned(
          left: 16 * widthRatio,
          top: 199 * heightRatio,
          child: Text(
            '로그인을 시작합니다!',
            style: TextStyle(
              color: const Color(0xFF121212),
              fontSize: 24 * widthRatio,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),

        // 서브 텍스트
        Positioned(
          left: 16 * widthRatio,
          top: 235 * heightRatio,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '실소의 맴버가 되어주세요!',
                  style: TextStyle(
                    color: const Color(0xFFC7C7C7),
                    fontSize: 14 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 2.14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 로그인 버튼 그룹
 Positioned(
  left: 17 * widthRatio,
  top: 337 * heightRatio,
  child: Container(
    width: 360 * widthRatio,
    child: Row( // Column 대신 Row를 사용하여 버튼들을 가로로 배치합니다.
      mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
      children: [
        // 카카오 로그인 원형 버튼
        _buildCircularButton(
          onTap: _isLoading ? null : _handleKakaoSignInWithImage,
          backgroundColor: const Color(0xFFFFE600),
          imagePath: 'assets/button/kakao_login_circular.png', // 카카오 원형 로고 이미지 경로
        ),
        SizedBox(width: 16 * widthRatio), // 버튼 간 간격
        // 구글 로그인 원형 버튼
        _buildCircularButton(
          onTap: _isLoading ? null : _handleGoogleSignInWithImage,
          backgroundColor: Colors.white,
          imagePath: 'assets/button/google_login_circular.png', // 구글 원형 로고 이미지 경로
        ),
      ],
    ),
  ),
),
        // 전화번호로 계속하기 버튼
        Positioned(
          left: 17 * widthRatio,
          top: 590 * heightRatio,
          child: Container(
            width: 360 * widthRatio,
            height: 52 * heightRatio,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () {}, // 전화번호 로그인 로직으로 연결 필요
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F37CF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * widthRatio),
                ),
                padding: EdgeInsets.symmetric(vertical: 14 * heightRatio),
              ),
              child: Text(
                '전화번호로 계속하기',
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
          ),
        ),

        // 비회원으로 구경하기 버튼
        Positioned(
          left: 136 * widthRatio,
          top: 672 * heightRatio,
          child: GestureDetector(
            onTap: _isLoading ? null : _signInAnonymously,
            child: Column(
              children: [
                Text(
                  '비회원으로 구경하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF8E8E8E),
                    fontSize: 14 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.58,
                  ),
                ),
                Container(
                  width: 113 * widthRatio,
                  height: 1 * widthRatio, // underline
                  color: const Color(0xFF8E8E8E),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}



  Future<void> _handleKakaoSignInWithImage() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithKakao();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed( '/after-login-splash');
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

    Future<void> _handleGoogleSignInWithImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/after-login-splash');
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
}

