import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IDPasswordSignUpScreen extends StatefulWidget {
  final bool isIdAndPasswordShortCut; // '회원가입' 로그인 경우 기존 사용자 인증 문서 인증이 필요없으므로 확인용.

  const IDPasswordSignUpScreen({super.key, required this.isIdAndPasswordShortCut});
  
  @override
  State<IDPasswordSignUpScreen> createState() => _IDPasswordSignUpScreenState();
}

class _IDPasswordSignUpScreenState extends State<IDPasswordSignUpScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isIdAvailable = false;
  bool _isIdAvailableInitial = true;
  bool _isPasswordValid = false;
 
  @override
  void initState(){
    super.initState(); 
  }

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
    final idRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9]{3,11}$');
    _isIdAvailableInitial = false;

    if (!idRegex.hasMatch(id)) {
      setState(() => _isIdAvailable = false);
      return;
    }

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final currentUser = auth.currentUser;
      
      final result = await firestore.collection('users').where('authentication.id', isEqualTo: id + '@silso.com').limit(1).get();

      if (result.docs.isEmpty) {
        setState(() => _isIdAvailable = true);
      } else {
        final existingDoc = result.docs.first;
        final isCurrentUserDoc = (currentUser != null && existingDoc.id == currentUser.uid);
        
        setState(() => _isIdAvailable = isCurrentUserDoc);
        
        if (!isCurrentUserDoc) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미 사용 중인 아이디입니다. 다른 아이디를 사용해주세요.')),
          );
        }
      }
    } catch (e) {
      print('아이디 중복 확인 중 오류 발생: $e');
      setState(() => _isIdAvailable = false);
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
    
    setState(() {
      _isPasswordValid = isLengthValid && meetsTwoCriteria;
    });
  }

  // '다음' 버튼 로직
  void _onNext() async {
    // 1. 기본 유효성 검사
    if (!_formKey.currentState!.validate() || !_isIdAvailable || !_isPasswordValid) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('입력 정보를 다시 확인해주세요.')),
       );
       return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    // 2. 로딩 상태 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final email = '${_idController.text}@silso.com';
      final password = _passwordController.text;

      if (widget.isIdAndPasswordShortCut) {
        // ✅ Case 1: 신규 회원가입 로직 (ShortCut)
        print('🚀 신규 회원가입(ShortCut)을 시작합니다...');

        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Firebase Auth 사용자 생성 완료. UID: ${userCredential.user?.uid}');

        final newUserId = userCredential.user!.uid;
        
        // Firestore에 저장할 사용자 데이터. 비밀번호는 절대 저장하지 않습니다.
        final newUserData = {
          'profile': {'uid': newUserId},
          'authentication': {
            'id': email,
            'hasPhoneAuth': false,
            'hasEmailPassword': true,
            'emailPasswordSetupAt': FieldValue.serverTimestamp(),
          },
          'settings': {
            'isActive': true,
            'signUpCompleted': true,
            'emailPasswordCompleted': true,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await firestore.collection('users').doc(newUserId).set(newUserData);
        print('✅ Firestore에 새 사용자 문서 생성 완료.');

      } else {
        // ✅ Case 2: 기존 사용자에게 이메일/비밀번호 연결 로직
        print('🔄 기존 사용자 계정에 이메일/비밀번호 연결을 시작합니다...');

        final currentUser = auth.currentUser;
        if (currentUser == null) {
          throw Exception('사용자가 로그인되어 있지 않습니다. 다시 처음부터 진행해주세요.');
        }
        
        final credential = EmailAuthProvider.credential(email: email, password: password);
        await currentUser.linkWithCredential(credential);
        print('✅ 이메일/비밀번호 인증 정보 추가 완료');

        // Firestore의 기존 사용자 문서에 추가 정보 merge. 비밀번호는 절대 저장하지 않습니다.
        final additionalUserData = {
          'authentication': {
            'id': email,
            'hasEmailPassword': true,
            'emailPasswordSetupAt': FieldValue.serverTimestamp(),
          },
          'settings': {
            'signUpCompleted': true,
            'emailPasswordCompleted': true,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await firestore.collection('users').doc(currentUser.uid).set(
          additionalUserData,
          SetOptions(merge : true)
        );
        print('✅ Firestore에 사용자 정보 업데이트 완료.');
      }

      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아이디/비밀번호 설정이 완료되었습니다!'),
            backgroundColor: Color(0xFF03A20B),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login-phone-confirm');
      }

    } on FirebaseAuthException catch (e) {
        if (mounted) Navigator.of(context).pop();
        print('🚨 FirebaseAuthException: ${e.code} - ${e.message}');
        
        String errorMessage = '아이디/비밀번호 설정 중 오류가 발생했습니다.';
        switch (e.code) {
          case 'weak-password':
            errorMessage = '비밀번호가 너무 약합니다.';
            break;
          case 'email-already-in-use':
          case 'credential-already-in-use':
            errorMessage = '이미 사용 중인 아이디(이메일)입니다.';
            break;
          case 'invalid-email':
            errorMessage = '유효하지 않은 이메일 형식입니다.';
            break;
          case 'provider-already-linked':
            errorMessage = '이미 이메일/비밀번호가 설정된 계정입니다.';
            break;
          case 'network-request-failed':
            errorMessage = '네트워크 연결을 확인해주세요.';
            break;
          default:
            errorMessage = '인증 오류: ${e.message}';
        }
        
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage), backgroundColor: const Color(0xFFC31A1A)),
            );
        }
        
    } catch (e) {
        if (mounted) Navigator.of(context).pop();
        print('🚨 일반 오류 발생: $e');
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('예상치 못한 오류가 발생했습니다: $e'), backgroundColor: const Color(0xFFC31A1A)),
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double baseWidth = 393.0;
    const double baseHeight = 852.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final double widthRatio = screenWidth / baseWidth;
    final double heightRatio = MediaQuery.of(context).size.height / baseHeight;

      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Form(
          key: _formKey,
          child: Stack(
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
                        top: 64 * heightRatio,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Color(0xFF121212),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Positioned(
                        left: (393 * widthRatio - 100) / 2,  // 80 is approximate text width
                        top: 68 * heightRatio,
                        child: Text(
                          '실소 회원가입',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: const Color(0xFF121212),
                              fontSize: 18,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.62,
                          ),
                      ),      
                      ),
                 
                    ],
                  ),
                ),
              ),

              // 로고 이미지
              Positioned(
                left: 8 * widthRatio,
                top: 133 * heightRatio,
                child: SizedBox(
                  width: 90 * widthRatio,
                  height: 37 * heightRatio,
                  child: Image.asset(
                    'assets/images/silso_logo/login_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 메인 제목
              Positioned(
                left: 16 * widthRatio,
                top: 175 * heightRatio,
                child: Text(
                  '실소 계정을 만들 차례예요!',
                  style: TextStyle(
                    color: const Color(0xFF121212),
                    fontSize: 20 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // '아이디' 텍스트
              Positioned(
                left: 16 * widthRatio,
                top: 241 * heightRatio,
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

              // 아이디 입력 필드 (TextFormField로 변경)
              Positioned(
                left: 17 * widthRatio,
                top: 271 * heightRatio,
                child: SizedBox(
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
                      hintText: '아이디를 입력하세요',
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
                top: 271 * heightRatio,
                child: SizedBox(
                  width: 106 * widthRatio,
                  height: 52 * heightRatio,
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
              ),

              // 아이디 유효성 메시지
              Positioned(
                left: 38 * widthRatio,
                top: 334 * heightRatio,
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
                top: 411 * heightRatio,
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
                top: 445 * heightRatio,
                child: SizedBox(
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
                      suffixIcon: Padding(
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
                top: 508 * heightRatio,
                child: SizedBox(
                  width: 360 * widthRatio,
                  height: 52 * heightRatio,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    onChanged: (_) {
                      setState(() {});
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
                      suffixIcon: Padding(
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
                top: 571 * heightRatio,
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
                top: 732 * heightRatio,
                child: SizedBox(
                  width: 360 * widthRatio,
                  height: 52 * heightRatio,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isIdAvailable && _isPasswordValid ? const Color(0xFF5F37CF) : const Color(0xFFBDBDBD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
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
        ),
      );
  }
}