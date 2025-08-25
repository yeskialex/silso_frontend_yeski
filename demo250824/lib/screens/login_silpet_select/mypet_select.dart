import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:rive/rive.dart'; // Rive 애니메이션을 사용하는 경우
// import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용 시
// import 'package:firebase_auth/firebase_auth.dart';     // Firebase Auth 사용 시
import '../login/after_signup_splash.dart'; 

// 1. UI 상태를 enum으로 정의합니다.
enum PetCreationStep {
  intro,
  revealPet,
  startNaming,
  keyboardActive,
  namingDone,
}

class PetCreationScreen extends StatefulWidget {
  const PetCreationScreen({super.key});

  @override
  State<PetCreationScreen> createState() => _PetCreationScreenState();
}

class _PetCreationScreenState extends State<PetCreationScreen> {
  // 2. 현재 UI 상태를 관리하는 변수
  PetCreationStep _currentStep = PetCreationStep.intro;

  // 닉네임 입력을 위한 컨트롤러와 포커스 노드
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();

  // 랜덤 펫 이미지 번호와 최종 닉네임 저장 변수
  int _petImageNumber = 1;
  String _finalNickname = '';
  
  // 애니메이션 효과를 위한 투명도 값
  double _splashAnimationOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    // 랜덤 펫 번호 초기화
    _petImageNumber = Random().nextInt(11) + 1;

    // ✅ 실시간 텍스트 업데이트를 위한 리스너 추가
    _nicknameController.addListener(() {
      setState(() {
        // 컨트롤러의 텍스트가 변경될 때마다 UI를 새로고침합니다.
      });
    });

    // 닉네임 입력 필드의 포커스 상태를 감지하여 UI 상태 변경
    _nicknameFocusNode.addListener(() {
      if (_nicknameFocusNode.hasFocus) {
        setState(() {
          _currentStep = PetCreationStep.keyboardActive;
        });
      } else {
        // 포커스를 잃었을 때 (키보드 내려감), 닉네임이 있다면 완료 상태로 변경
        if (_nicknameController.text.isNotEmpty) {
           _handleNicknameSubmit();
        } else {
          setState(() {
            _currentStep = PetCreationStep.startNaming;
          });
        }
      }
    });
  }

  // ✅ dispose에서 리스너를 제거해야 메모리 누수가 발생하지 않습니다.
  @override
  void dispose() {
    // 리스너를 제거할 때는 아래와 같이 addListener에 전달했던 함수를 그대로 넣어주어야 합니다.
    // 여기서는 익명 함수를 썼으므로 컨트롤러를 dispose 하는 것만으로 충분합니다.
    _nicknameController.dispose();
    _nicknameFocusNode.dispose();
    super.dispose();
  }

  // 3. 상태 변경 로직을 함수로 관리
  void _handleScreenTap() {
    if (_currentStep == PetCreationStep.intro) {
      setState(() {
        _splashAnimationOpacity = 0.0; // 스플래시 애니메이션 숨기기
        _currentStep = PetCreationStep.revealPet;
      });
    }
  }

  void _handleBottomButtonTap() {
    switch (_currentStep) {
      case PetCreationStep.revealPet:
        setState(() => _currentStep = PetCreationStep.startNaming);
        break;
      case PetCreationStep.startNaming:
        // 입력 필드에 포커스를 주어 키보드를 활성화
        _nicknameFocusNode.requestFocus();
        break;
      case PetCreationStep.namingDone:
        _navigateToNextScreen();
        break;
      default:
        break;
    }
  }

  void _handleNicknameSubmit() {
    // 키보드의 '완료' 버튼을 누르거나 포커스를 잃었을 때 호출
    if (_nicknameController.text.isNotEmpty) {
      setState(() {
        // _finalNickname = _nicknameController.text;
        _currentStep = PetCreationStep.namingDone;
      });
       _nicknameFocusNode.unfocus(); // 키보드 숨기기
    }
  }
  
  // 6. Firestore에 닉네임 저장 및 다음 화면으로 이동
  Future<void> _saveNicknameToFirestore() async {
    // // Firestore 및 FirebaseAuth 설정이 필요합니다.
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null && _finalNickname.isNotEmpty) {
    //   await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
    //     'NicknamePet': _finalNickname,
    //     'petImage': 'assets/images/pets/pet$_petImageNumber.png', // 펫 이미지 정보도 함께 저장
    //   });
    // }
    print('닉네임 "$_finalNickname" 저장 완료!');
  }
  
  void _navigateToNextScreen() async {
    await _saveNicknameToFirestore();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AfterSignupSplash()));
     print('다음 화면으로 이동합니다.');
  }


  @override
  Widget build(BuildContext context) {
    // 4. 반응형 UI를 위해 화면 크기 가져오기
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: GestureDetector(
        onTap: _handleScreenTap,
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.00, -0.7),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xFF5F37CF), Color(0xFF160C32)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 스플래시 애니메이션 위젯
              _buildSplashAnimation(),
              
              // 상단 텍스트 위젯
              _buildTopText(screenHeight),

              // 펫 이미지 위젯
              _buildPetImage(screenHeight),

              // 닉네임 입력 필드 위젯
              _buildNicknameField(screenHeight),
              
              // 닉네임 표시 박스 (키보드 올라왔을 때)
              _buildNicknameDisplayBox(screenHeight),

              // 하단 버튼 위젯
              _buildBottomButton(screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  // 5. 각 UI 요소를 별도의 함수로 분리하여 관리
  
  Widget _buildSplashAnimation() {
    // TODO: 애니메이션 팀에서 받은 실제 애니메이션 위젯으로 교체하세요. (예: Rive)
    return AnimatedOpacity(
      opacity: _splashAnimationOpacity,
      duration: const Duration(milliseconds: 300),
      child: const Center(
        // child: RiveAnimation.asset('assets/animations/splash.riv'),
        child: Icon(Icons.animation, color: Colors.white, size: 150), // 임시 아이콘
      ),
    );
  }

  Widget _buildTopText(double screenHeight) {
    String text = '';
    switch (_currentStep) {
      case PetCreationStep.intro:
        text = '캡슐을 열어주세요!';
        break;
      case PetCreationStep.revealPet:
        text = '당신의 실팻이에요!';
        break;
      case PetCreationStep.startNaming:
      case PetCreationStep.keyboardActive:
        text = '이름을 지어주세요!';
        break;
      case PetCreationStep.namingDone:
        text = '$_finalNickname! 멋진 이름이네요';
        break;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      top: screenHeight * 0.18, // 화면 높이의 18% 위치
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _currentStep != PetCreationStep.intro ? 1.0 : 0.0,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFAFAFA),
            fontSize: 20,
            fontFamily: 'DungGeunMo',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
  
  Widget _buildPetImage(double screenHeight) {
    bool isVisible = _currentStep != PetCreationStep.intro;
    bool isEnlarged = _currentStep == PetCreationStep.startNaming ||
                      _currentStep == PetCreationStep.keyboardActive ||
                      _currentStep == PetCreationStep.namingDone;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut, // 통통 튀는 효과
      top: _currentStep == PetCreationStep.keyboardActive ? screenHeight * 0.21 : screenHeight * 0.35,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: isEnlarged ? 110 : 64,
          height: isEnlarged ? 288 : 169,
          child: Image.asset(
            'assets/images/pets/pet$_petImageNumber.png', 
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: isEnlarged ? 110 : 64,
                height: isEnlarged ? 288 : 169,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 40,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

// 닉네임 입력 필드 (실제 입력은 여기서, 하지만 화면엔 보이지 않음)
Widget _buildNicknameField(double screenHeight) {
  // 키보드가 활성화되었을 때만 TextField가 존재하도록 함
  if (_currentStep != PetCreationStep.keyboardActive) {
    return const SizedBox.shrink(); // 다른 상태에서는 위젯을 아예 렌더링하지 않음
  }

  return Positioned(
    top: screenHeight * 0.3,
    child: SizedBox(
      width: 224,
      height: 40,
      child: TextField( // 투명한 TextField
        controller: _nicknameController,
        focusNode: _nicknameFocusNode,
        textAlign: TextAlign.center,
        onSubmitted: (_) => _handleNicknameSubmit(),
        autofocus: true, // 상태 진입 시 자동으로 포커스
        style: const TextStyle(color: Colors.transparent), // 텍스트를 투명하게
        decoration: const InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.transparent, // 배경을 투명하게
          filled: true,
        ),
        cursorColor: Colors.transparent, // 커서도 투명하게
      ),
    ),
  );
}

// 닉네임 표시 박스 (실시간 업데이트 및 수정 기능 추가)
Widget _buildNicknameDisplayBox(double screenHeight) {
  // ✅ 키보드 활성 상태와 완료 상태 모두에서 보임
  bool isVisible = _currentStep == PetCreationStep.keyboardActive || _currentStep == PetCreationStep.namingDone;
  
  return AnimatedPositioned(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    top: screenHeight * 0.3,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      // ✅ isVisible 조건과 컨트롤러에 텍스트가 있을 때만 보이도록 수정
      opacity: isVisible && _nicknameController.text.isNotEmpty ? 1.0 : 0.0,
      child: GestureDetector(
        // ✅ 탭하면 수정 모드로 전환
        onTap: () {
          if (_currentStep == PetCreationStep.namingDone) {
            setState(() {
              _currentStep = PetCreationStep.keyboardActive;
            });
            // TextField에 다시 포커스를 주어 키보드를 올림
            _nicknameFocusNode.requestFocus();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          constraints: const BoxConstraints(minHeight: 30),
          decoration: ShapeDecoration(
            color: const Color(0xFFFAFAFA),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 2, color: Color(0xFF121212)),
              borderRadius: BorderRadius.circular(400),
            ),
          ),
          child: Center(
            child: Text(
              // ✅ _finalNickname 대신 컨트롤러의 텍스트를 직접 사용
              _nicknameController.text,
              style: const TextStyle(
                color: Color(0xFF121212),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


  Widget _buildBottomButton(double screenWidth, double screenHeight) {
    bool isVisible = _currentStep != PetCreationStep.intro;
    bool isButtonActive = _currentStep == PetCreationStep.revealPet ||
                          _currentStep == PetCreationStep.startNaming ||
                          _currentStep == PetCreationStep.namingDone;
    
    String buttonText = '';
    switch(_currentStep) {
      case PetCreationStep.revealPet:
      case PetCreationStep.startNaming:
        buttonText = '닉네임 만들기';
        break;
      case PetCreationStep.namingDone:
        buttonText = '시작하기';
        break;
      case PetCreationStep.keyboardActive:
        buttonText = '완료'; // 키보드 활성 시 '완료' 텍스트 (비활성화)
        break;
      default:
        buttonText = '터치해주세요';
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: _currentStep == PetCreationStep.keyboardActive ? screenHeight - (screenHeight * 0.92) + MediaQuery.of(context).viewInsets.bottom : screenHeight * 0.1,
      // 키보드가 올라왔을 때 키보드 바로 위에 위치하도록 조정
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: GestureDetector(
            onTap: isButtonActive ? _handleBottomButtonTap : null,
            child: Container(
              height: 52,
              decoration: ShapeDecoration(
                color: isButtonActive ? const Color(0xFF5F37CF) : const Color(0xFF44307A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isButtonActive ? const Color(0xFFFAFAFA) : const Color(0xFF896ADD),
                    fontSize: 18,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}