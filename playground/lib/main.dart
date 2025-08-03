import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// 앱의 시작점입니다.
void main() {
  runApp(const MyApp());
}

// 각 메시지의 데이터와 정렬 정보를 담는 클래스입니다.
class Message {
  final String text;
  final bool isLeft; // true이면 왼쪽, false이면 오른쪽에 정렬됩니다.

  Message({required this.text, required this.isLeft});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Stacking Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      home: const BubbleStackScreen(),
    );
  }
}

// 버블 스택 기능을 보여줄 메인 화면입니다.
class BubbleStackScreen extends StatefulWidget {
  const BubbleStackScreen({super.key});

  @override
  _BubbleStackScreenState createState() => _BubbleStackScreenState();
}

class _BubbleStackScreenState extends State<BubbleStackScreen> {
  final List<Message> _messages = [];
  final Random _random = Random();
  final TextEditingController _textController = TextEditingController();

  bool _isLimitReached = false;
  bool _showResetNotice = false;

  static const double _bubbleHeight = 55.0;
  static const double _inputBarHeight = 100.0; // 새로운 레이아웃에 맞게 높이 조정

  // 사용자가 입력한 텍스트로 새로운 버블을 추가하는 함수입니다.
  void _addBubble(String text) {
    if (text.isEmpty) return; // 입력된 텍스트가 없으면 아무것도 하지 않습니다.

    setState(() {
      final isLeft = _random.nextBool();
      _messages.add(Message(text: text, isLeft: isLeft));
      _textController.clear(); // 텍스트 필드 초기화

      final screenHeight = MediaQuery.of(context).size.height;
      final stackHeight = _messages.length * _bubbleHeight;
      // 키보드가 차지하는 공간을 제외한 실제 채팅 영역의 높이를 기준으로 한계를 계산합니다.
      final chatAreaHeight = screenHeight - MediaQuery.of(context).viewInsets.bottom;

      if (stackHeight > chatAreaHeight * 0.75) {
        _isLimitReached = true;
        _startAutoResetTimer();
      }
    });
  }

  // 3초 후 자동 리셋을 실행하는 타이머 함수입니다.
  void _startAutoResetTimer() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _isLimitReached = false;
        _showResetNotice = true;
      });

      Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _showResetNotice = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 키보드의 높이를 실시간으로 감지합니다.
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // resizeToAvoidBottomInset의 기본값은 true이므로, 키보드가 올라오면 화면이 자동으로 조절됩니다.
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 화면 다른 곳 터치 시 키보드 숨기기
        child: Stack(
          children: [
            // 배경 이미지
            Positioned.fill(
              child: Image.network(
                "https://placehold.co/800x1200/3F3329/white?text=Background",
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // 메시지 버블 스택 영역
            // 키보드와 입력창 높이를 제외한 나머지 공간을 차지합니다.
            Padding(
              padding: EdgeInsets.only(bottom: _inputBarHeight + keyboardHeight),
              child: Stack(
                children: _messages.asMap().entries.map((entry) {
                  int index = entry.key;
                  Message message = entry.value;
                  return Positioned(
                    bottom: 20.0 + (index * _bubbleHeight),
                    left: 20,
                    right: 20,
                    child: Align(
                      alignment: message.isLeft
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: ChatBubble(text: message.text),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // 경고 및 알림 메시지 (화면 중앙에 위치)
            Center(
              child: _isLimitReached
                  ? const LimitReachedWarning()
                  : _showResetNotice
                      ? const ResetNotice()
                      : const SizedBox.shrink(),
            ),

            // 화면 하단 텍스트 입력 필드
            // 키보드 높이에 따라 위치가 동적으로 변경됩니다.
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboardHeight,
              child: BottomInputBar(
                controller: _textController,
                participantCount: _messages.length + 809, // 기본 참여자 수에 현재 메시지 수 추가
                onSend: () {
                  if (!_isLimitReached) {
                    _addBubble(_textController.text);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 채팅 버블의 모양을 정의하는 위젯입니다.
class ChatBubble extends StatelessWidget {
  final String text;

  const ChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2, color: Color(0xFF121212)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF121212),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 화면 하단에 위치할 새로운 레이아웃의 입력 위젯입니다.
class BottomInputBar extends StatelessWidget {
  final TextEditingController controller;
  final int participantCount;
  final VoidCallback onSend;

  const BottomInputBar({
    super.key,
    required this.controller,
    required this.participantCount,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3F3329), // 배경색
      child: SafeArea(
        top: false,
        child: Container(
          height: 100.0, // 전체 높이
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1st Row: 정보 표시
              Expanded(
                flex: 2, // 첫 번째 컬럼이 차지할 공간 비율
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 참여자 수: $participantCount명',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(width: 100), // 텍스트 사이의 간격
                    const Text(
                      '남은 시간: 3시간',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12), // 컬럼 사이의 간격

              // 2nd Row: 입력창과 아이콘
              Expanded(
                flex: 3, // 두 번째 컬럼이 차지할 공간 비율
                child: Row(
                  children: [
                    // 타원형 입력창
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAEAEA),
                          borderRadius: BorderRadius.circular(400),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                style: const TextStyle(color: Colors.black, fontSize: 16),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 20),
                                  hintText: '의견을 입력해주세요.',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFBBBBBB),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Color(0xFFBBBBBB)),
                              onPressed: onSend,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 타원형 컨테이너 밖으로 나온 아이콘
                    IconButton(
                      icon: const Icon(Icons.document_scanner, color: Color(0xFFBBBBBB)),
                      onPressed: () {
                        // TODO: 문서 스캐너 아이콘 클릭 시 동작 추가
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 한계 도달 시 나타나는 경고 위젯입니다.
class LimitReachedWarning extends StatelessWidget {
  const LimitReachedWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Text(
        '의견이 가득 찼습니다! 3초 후 초기화됩니다.',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// 리셋 후 나타나는 알림 위젯입니다.
class ResetNotice extends StatelessWidget {
  const ResetNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Text(
        '메시지가 초기화되었습니다.',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
