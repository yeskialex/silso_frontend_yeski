import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/authentication/auth_service.dart';
import 'phone_confirm.dart';

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
  final _authService = AuthService();

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

  // Handle back button - sign out if coming from social auth
  Future<void> _handleBackNavigation() async {
    if (!widget.isIdAndPasswordShortCut) {
      // User came from social auth (Google/Kakao), need to clean up
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          print('🔄 Cleaning up social auth account: ${user.uid}');
          
          // 1. Delete any Firestore document that might have been created
          try {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
            print('🗑️ Deleted incomplete Firestore document');
          } catch (e) {
            print('ℹ️ No Firestore document to delete or delete failed: $e');
            // This is okay - document might not exist yet
          }
          
          // 2. Sign out from Firebase Auth
          await _authService.signOut();
          print('✅ Complete cleanup: User signed out from social auth flow');
        }
      } catch (e) {
        print('❌ Error during cleanup: $e');
        // Continue with navigation even if cleanup fails
      }
    }
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
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
      // Store email and password for later use after phone verification
      final email = '${_idController.text}@silso.com';
      final password = _passwordController.text;
      
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('다음 단계로 진행합니다. 휴대폰 인증을 완료해주세요.'),
            backgroundColor: Color(0xFF03A20B),
          ),
        );
        
        // Pass email and password to phone confirmation screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PhoneConfirmScreen(
              isFromLogin: false,
              pendingEmail: email,
              pendingPassword: password,
              isIdAndPasswordShortCut: widget.isIdAndPasswordShortCut,
            ),
          ),
        );
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

  /// Builds the app bar for the screen.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF121212)),
        onPressed: () => _handleBackNavigation(),
      ),
      title: const Text(
        '실소 회원가입',
        style: TextStyle(
          color: Color(0xFF121212),
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await _handleBackNavigation();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Logo Image
                        SizedBox(
                          width: 90,
                          height: 37,
                          child: Image.asset(
                            'assets/images/silso_logo/login_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Main Title
                        const Text(
                          '실소 계정을 만들 차례예요!',
                          style: TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 20,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 'ID' Label
                        const Text(
                          '아이디',
                          style: TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ID Input Field and Check Button
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _idController,
                                style: const TextStyle(
                                  color: Color(0xFF121212),
                                  fontSize: 16,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _textFieldDecoration(
                                  hintText: '아이디를 입력하세요',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _checkIdAvailability,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF121212),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                                child: const Text(
                                  '중복확인',
                                  style: TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ID Validation Message
                        Text(
                          _isIdAvailableInitial
                              ? '영문과 숫자만 사용하여, 영문으로 시작되는 4-12자의 아이디를 입력해주세요.'
                              : (_isIdAvailable ? '사용 가능한 아이디!' : '사용 불가한 아이디'),
                          style: TextStyle(
                            color: _isIdAvailableInitial
                                ? const Color(0xFF5F37CF)
                                : (_isIdAvailable ? const Color(0xFF03A20B) : const Color(0xFFC31A1A)),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 'Password' Label
                        const Text(
                          '비밀번호',
                          style: TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Password Input Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          onChanged: (_) => _validatePassword(),
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _textFieldDecoration(
                            hintText: '비밀번호를 입력하세요',
                          ).copyWith(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Text(
                                _isPasswordValid ? '사용가능' : '사용불가',
                                style: TextStyle(
                                  color: _isPasswordValid ? const Color(0xFF03A20B) : const Color(0xFFC31A1A),
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Confirm Password Input Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return '비밀번호가 일치하지 않습니다.';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _textFieldDecoration(
                            hintText: '비밀번호를 다시 입력하세요',
                          ).copyWith(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: (_confirmPasswordController.text.isEmpty)
                                  ? null
                                  : (_confirmPasswordController.text != _passwordController.text)
                                      ? const Icon(Icons.cancel_outlined, color: Color(0xFFC31A1A))
                                      : const Icon(Icons.check_circle_outline_outlined, color: Color(0xFF03A20B)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Password Validation Message
                        Text(
                          _isPasswordValid ? '' : '영문 대소문자, 숫자, 특수문자 중 2가지 이상을 조합하여 6-20자로 입력해주세요',
                          style: TextStyle(
                            color: _isPasswordValid ? Colors.green : const Color(0xFF5F37CF),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 'Next' Button
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isIdAvailable && _isPasswordValid ? const Color(0xFF5F37CF) : const Color(0xFFBDBDBD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      '다음',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
      ),
      ), // Scaffold
    ); // PopScope
  }

  /// Helper method for text field decoration
  InputDecoration _textFieldDecoration({required String hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFEAEAEA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFBBBBBB),
        fontSize: 16,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
