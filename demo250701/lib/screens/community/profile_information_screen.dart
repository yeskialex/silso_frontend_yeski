import 'package:flutter/material.dart';

/// 사용자의 프로필 정보를 표시하고 수정하는 화면입니다.
/// 기존 Stack/Positioned 레이아웃에서 발생하는 렌더링 문제를 해결하고,
/// Column/Row 기반의 반응형 레이아웃으로 재구성했습니다.
/// 
/// 사용자의 프로필 정보를 입력받는 화면입니다.
/// 사용자 입력을 처리하기 위해 StatefulWidget으로 구성되었습니다.
class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  // 이름 입력을 제어하는 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  // 국적 선택 상태를 관리하는 리스트. [내국인, 외국인]
  final List<bool> _nationalitySelection = [true, false];

  // 성별 선택 상태를 관리하는 변수. '남', '여'
  String _selectedGender = '여';

  // 통신사 선택 상태를 관리하는 변수.
  String _selectedTelecom = 'SKT';

  @override
  void dispose() {
    // 컨트롤러를 사용하지 않을 때 메모리 누수를 방지하기 위해 dispose합니다.
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 화면 배경색 설정
      backgroundColor: const Color(0xFFFAFAFA),
      // 상단 앱 바 빌드
      appBar: _buildAppBar(context),
      // 메인 컨텐츠 영역
      body: Column(
        children: [
          // 스크롤 가능한 컨텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    const SizedBox(height: 30), // 상단 여백

                    // '이름' 섹션
                    _buildSectionTitle('이름'),
                    const SizedBox(height: 8),
                    _buildNameAndNationality(),
                    const SizedBox(height: 35),

                    // '생년월일' 섹션
                    _buildSectionTitle('생년월일'),
                    const SizedBox(height: 8),
                    _buildBirthdateAndGender(),
                    const SizedBox(height: 35),

                    // '휴대폰 인증' 섹션
                    _buildSectionTitle('휴대폰 인증'),
                    const SizedBox(height: 15),
                    _buildPhoneAuthSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // 하단 '계속하기' 버튼
          _buildContinueButton(),
        ],
      ),
    );
  }

  /// 화면 상단의 앱 바 (진행률 표시 포함)를 빌드합니다.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // UI 데모를 위해 고정된 진행률 값을 사용합니다.
              child: const LinearProgressIndicator(
                value: 0.67,
                backgroundColor: Color(0xFFE0E0E0),
                color: Color(0xFF5F37CF),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  /// 각 정보 섹션의 제목 위젯을 빌드합니다.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF121212),
        fontSize: 16,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// '이름'과 '국적'을 표시하는 위젯을 빌드합니다.
  Widget _buildNameAndNationality() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 이름 입력 필드
        Expanded(
          child: TextField(
            controller: _nameController,
            style: const TextStyle(
              color: Color(0xFF121212),
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '이름',
              hintStyle: const TextStyle(color: Color(0xFF737373)),
              filled: true,
              fillColor: const Color(0xFFEAEAEA),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF5F37CF)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        // 국적 선택 토글 버튼
        ToggleButtons(
          isSelected: _nationalitySelection,
          onPressed: (int index) {
            setState(() {
              // 버튼을 누를 때마다 상태를 업데이트합니다.
              // 한 번에 하나의 버튼만 선택되도록 로직을 구현합니다.
              for (int i = 0; i < _nationalitySelection.length; i++) {
                _nationalitySelection[i] = i == index;
              }
            });
          },
          borderRadius: BorderRadius.circular(6),
          selectedColor: Colors.white,
          color: const Color(0xFF121212),
          fillColor: const Color(0xFF121212),
          splashColor: const Color(0xFF5F37CF).withOpacity(0.12),
          constraints: const BoxConstraints(
            minHeight: 52.0,
            minWidth: 70.0,
          ),
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('내국인', style: TextStyle(fontFamily: 'Pretendard')),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('외국인', style: TextStyle(fontFamily: 'Pretendard')),
            ),
          ],
        ),
      ],
    );
  }

  /// '생년월일'과 '성별'을 표시하는 위젯을 빌드합니다.
  Widget _buildBirthdateAndGender() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildTextFieldContainer(
            child: const Text(
              '030818',
              style: TextStyle(
                color: Color(0xFF121212),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 25),
        // Text.rich를 사용하여 여러 스타일의 텍스트를 조합합니다.
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '남',
                style: TextStyle(
                  color: Color(0xFFC4C4C4),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: '   |   ',
                style: TextStyle(
                  color: Color(0xFF575757),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: '여',
                style: TextStyle(
                  color: Color(0xFF121212),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  /// '휴대폰 인증' 전체 섹션 위젯을 빌드합니다.
  Widget _buildPhoneAuthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 통신사 선택 라디오 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildRadioButton('SKT', true),
            const SizedBox(width: 30),
            _buildRadioButton('KT', false),
            const SizedBox(width: 30),
            _buildRadioButton('LG U+', false),
          ],
        ),
        const SizedBox(height: 15),
        // 전화번호 입력 및 인증요청 버튼
        Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                decoration: const ShapeDecoration(
                  color: Color(0xFFEAEAEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '010-1234-5678',
                    style: TextStyle(
                      color: Color(0xFF121212),
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // '인증요청' 버튼
            Container(
              width: 116,
              height: 52,
              decoration: const ShapeDecoration(
                color: Color(0xFF121212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  '인증요청',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 인증번호 입력 필드
        _buildTextFieldContainer(
          child: const Text(
            '64832',
            style: TextStyle(
              color: Color(0xFF121212),
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 통신사 선택을 위한 라디오 버튼 위젯을 빌드합니다.
  Widget _buildRadioButton(String label, bool isSelected) {
    return Row(
      children: [
        Container(
          width: 19,
          height: 19,
          decoration: ShapeDecoration(
            shape: OvalBorder(
              side: const BorderSide(width: 1, color: Color(0xFFBBBBBB)),
            ),
          ),
          // 선택되었을 때 중앙에 원을 표시합니다.
          child: isSelected
              ? Center(
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF121212),
                      shape: OvalBorder(),
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF121212),
            fontSize: 16,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  /// 입력 필드의 기본 스타일을 정의하는 컨테이너 위젯입니다.
  Widget _buildTextFieldContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFEAEAEA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }

  /// 하단의 '계속하기' 버튼 위젯을 빌드합니다.
  Widget _buildContinueButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
        child: Container(
          width: double.infinity,
          height: 52,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFF5F37CF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Center(
            child: Text(
              '계속하기',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFAFAFA),
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
