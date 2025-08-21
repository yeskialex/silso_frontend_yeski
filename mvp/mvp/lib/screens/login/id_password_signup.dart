// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IDPasswordSignUpScreen extends StatefulWidget {
  const IDPasswordSignUpScreen({super.key});

  @override
  State<IDPasswordSignUpScreen> createState() => _IDPasswordSignUpScreenState();
}

class _IDPasswordSignUpScreenState extends State<IDPasswordSignUpScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isIdAvailable = false; // 아이디 중복 확인 상태
  bool _isIdAvailableInitial = true; // 아이디 중복 확인 처음 상태
  bool _isPasswordValid = false; // 비밀번호 유효성 상태

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // 아이디 중복 확인 로직  
  void _checkIdAvailability() async {
    final id = _idController.text;

    // 1) 로컬 유효성 검사 (정규식 사용)
    final idRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9]{3,11}$');
    _isIdAvailableInitial = false; // 최초 상태 false 

    if (!idRegex.hasMatch(id)) {
      setState(() {
        _isIdAvailable = false;
      });
      return;
    }

    // 2) Firebase Firestore 탐색 및 중복 확인
    try {
      final firestore = FirebaseFirestore.instance;
      // 'users' 컬렉션의 모든 문서를 탐색하여 id 필드가 입력값과 일치하는지 확인합니다.
      final result = await firestore.collection('users').where('profile.id', isEqualTo: id).limit(1).get();

      if (result.docs.isEmpty) {
        // 중복되는 ID가 없으면 사용 가능
        setState(() {
          _isIdAvailable = true;
        });
      } else {
        // 이미 존재하는 ID가 있음
        setState(() {
          _isIdAvailable = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 사용 중인 아이디입니다. 다른 아이디를 사용해주세요.')),
        );
      }
    } catch (e) {
      print('아이디 중복 확인 중 오류 발생: $e');
      setState(() {
        _isIdAvailable = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // 비밀번호 유효성 검사 로직
  void _validatePassword() {
    final password = _passwordController.text;
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    final meetsTwoCriteria = (hasLetters && hasNumbers) ||
                             (hasLetters && hasSpecial) ||
                             (hasNumbers && hasSpecial);
    
    final isLengthValid = password.length >= 6 && password.length <= 20;
    final isValid = isLengthValid && meetsTwoCriteria;

    setState(() {
      _isPasswordValid = isValid;
    });
  }

// '다음' 버튼 로직
void _onNext() async {
  // 모든 유효성 검사 및 상태 확인
  if (_formKey.currentState!.validate() && _isIdAvailable && _isPasswordValid) {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // 1. Firebase Authentication으로 사용자 계정 생성
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _idController.text + '@silso.com', // 임시 이메일 형식 사용
        password: _passwordController.text,
      );

      // 2. 계정 생성 후 사용자 객체가 유효한지 확인
      final user = userCredential.user;
      if (user == null) {
        throw Exception('회원가입 후 사용자 UID를 가져올 수 없습니다.');
      }
      final currentUserId = user.uid;

      // 3. Firestore에 사용자 프로필 정보 저장
      await firestore.collection('users').doc(currentUserId).set({
        'profile': {
          'id': _idController.text,
          'email': _idController.text + '@silso.com', // 이메일 저장
          'createdAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      // 4. 다음 페이지로 이동
      Navigator.of(context).pushReplacementNamed('/after-signup');

    } on FirebaseAuthException catch (e) {
      String errorMessage = '회원가입 중 오류가 발생했습니다.';
      if (e.code == 'weak-password') {
        errorMessage = '비밀번호가 너무 약합니다.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = '이미 사용 중인 아이디(이메일)입니다.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print('회원가입 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 중 예상치 못한 오류가 발생했습니다.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 조건을 충족해야 합니다.')),
    );
  }
}

// lib/screens/signup_screen.dart 파일의 build 메서드

  @override
  Widget build(BuildContext context) {
    const double baseWidth = 393.0;
    const double baseHeight = 852.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final double widthRatio = screenWidth / baseWidth;
    final double heightRatio = MediaQuery.of(context).size.height / baseHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // 상단 AppBar와 뒤로가기 버튼
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 393 * widthRatio,
              height: 118 * heightRatio,
              decoration: BoxDecoration(color: const Color(0xFFFAFAFA)),
              child: Stack(
                children: [
                  Positioned(
                    left: 16 * widthRatio,
                    top: 68 * heightRatio,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // '아이디' 텍스트
          Positioned(
            left: 16 * widthRatio,
            top: 125 * heightRatio,
            child: Text(
              '아이디',
              style: TextStyle(
                color: const Color(0xFF121212),
                fontSize: 16 * widthRatio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 아이디 입력 필드
          Positioned(
            left: 17 * widthRatio,
            top: 155 * heightRatio,
            child: Container(
              width: 245 * widthRatio,
              height: 52 * heightRatio,
              child: TextFormField(
                controller: _idController,
                style: TextStyle(
                  color: const Color(0xFF121212),
                  fontSize: 16 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEAEAEA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 17 * widthRatio),
                  hintText: '아이디를 입력하세요', // 디자인에 없지만, 사용자 편의를 위해 추가
                  hintStyle: TextStyle(
                    color: const Color(0xFFBBBBBB),
                    fontSize: 16 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // 중복확인 버튼
          Positioned(
            left: 271 * widthRatio,
            top: 155 * heightRatio,
            child: ElevatedButton(
              onPressed: _checkIdAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF121212),
                fixedSize: Size(106 * widthRatio, 52 * heightRatio),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                '중복확인',
                style: TextStyle(
                  color: const Color(0xFFFAFAFA),
                  fontSize: 16 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // 아이디 사용 가능 메시지
          Positioned(
            left: 38 * widthRatio,
            top: 218 * heightRatio,
            child: SizedBox(
              width: 296 * widthRatio,
              child: Text(
                _isIdAvailableInitial ? (_isIdAvailable ? '사용 가능한 아이디!' : '영문과 숫자만 사용하여, 영문으로 시작되는 4-12자의 아이디를 입력해주세요.') : (_isIdAvailable ? '사용 가능한 아이디!' : '사용 불가한 아이디'),
                style: TextStyle(
                  color: _isIdAvailableInitial ? (_isIdAvailable ? const Color(0xFF03A20B) : const Color(0xFF5F37CF)) : (_isIdAvailable ? const Color(0xFF03A20B) : const Color(0xFFC31A1A)),
                  fontSize: 12 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // '비밀번호' 텍스트
          Positioned(
            left: 16 * widthRatio,
            top: 295 * heightRatio,
            child: Text(
              '비밀번호',
              style: TextStyle(
                color: const Color(0xFF121212),
                fontSize: 16 * widthRatio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 비밀번호 입력 필드
          Positioned(
            left: 17 * widthRatio,
            top: 329 * heightRatio,
            child: Container(
              width: 360 * widthRatio,
              height: 52 * heightRatio,
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (_) => _validatePassword(),
                style: TextStyle(
                  color: const Color(0xFF121212),
                  fontSize: 16 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEAEAEA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 17 * widthRatio),
                  hintText: '비밀번호를 입력하세요',
                  hintStyle: TextStyle(
                    color: const Color(0xFFBBBBBB),
                    fontSize: 16 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),

                  suffix: Padding( // 메시지 좌우 여백을 위해 Padding 위젯 사용
                  padding: EdgeInsets.symmetric(horizontal: 10 * widthRatio),
                  child: Text(
                    _isPasswordValid ? '사용가능' : '사용불가',
                    style: TextStyle(
                      color: _isPasswordValid ? const Color(0xFF03A20B) : const Color(0xFFC31A1A),
                      fontSize: 12 * widthRatio,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),

          // 비밀번호 확인 입력 필드
          Positioned(
            left: 17 * widthRatio,
            top: 392 * heightRatio,
            child: Container(
              width: 360 * widthRatio,
              height: 52 * heightRatio,
              child: TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                onChanged: (_) {
                  setState(() {}); // 텍스트가 변경될 때마다 화면을 다시 그리도록 합니다.
                },
                validator: (value) {
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
                style: TextStyle(
                  color: const Color(0xFF121212),
                  fontSize: 16 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEAEAEA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 17 * widthRatio),
                  hintText: '비밀번호를 다시 입력하세요',
                  hintStyle: TextStyle(
                    color: const Color(0xFFBBBBBB),
                    fontSize: 16 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),

                 suffix: Padding( // 메시지 좌우 여백을 위해 Padding 위젯 사용
                  padding: EdgeInsets.symmetric(horizontal: 10 * widthRatio),
                  child: (_confirmPasswordController.text.isEmpty) ? null : 
                    (_confirmPasswordController.text != _passwordController.text) ? 
                    const Icon(Icons.cancel_outlined, color: Color(0xFFC31A1A)) : 
                    const Icon(Icons.check_circle_outline_outlined, color: Color(0xFF03A20B)),
                ),

                ),
              ),
            ),
          ),

          // 비밀번호 유효성 메시지
          Positioned(
            left: 34 * widthRatio,
            top: 455 * heightRatio,
            child: SizedBox(
              width: 296 * widthRatio,
              child: Text(
                _isPasswordValid ? '' : '영문 대소문자, 숫자, 특수문자 중 2가지 이상을 조합하여 6-20자로 입력해주세요',
                style: TextStyle(
                  color: _isPasswordValid ? Colors.green : const Color(0xFF5F37CF),
                  fontSize: 12 * widthRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // '다음' 버튼
          Positioned(
            left: 18 * widthRatio,
            top: 732 * heightRatio, // 적절한 위치로 조정
            child: SizedBox(
              width: 360 * widthRatio,
              height: 52 * heightRatio,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIdAvailable && _isPasswordValid ? const Color(0xFF5F37CF) : const Color(0xFFBDBDBD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text( // after press this  <실소 회원가입 완료 screen : 3 seconds> 
                  '다음',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}