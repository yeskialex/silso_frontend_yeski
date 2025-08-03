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
  // 화면에 표시될 메시지 데이터를 관리하는 리스트입니다.
  final List<Message> _messages = [];
  final Random _random = Random();

  // 메시지 스택이 한계에 도달했는지 여부를 저장합니다.
  bool _isLimitReached = false;
  // '리셋' 메시지를 잠시 보여줄지 여부를 제어합니다.
  bool _showResetNotice = false;

  // 버블 하나의 대략적인 높이 (패딩 포함)
  static const double _bubbleHeight = 55.0;

  // 버튼을 눌렀을 때 호출되는 메인 함수입니다.
  void _addBubble() {
    setState(() {
      // 1) 새로운 버블을 좌우 랜덤으로 배치합니다.
      final isLeft = _random.nextBool();
      _messages.add(
        Message(
          text: "새로운 의견입니다! ✨ (${_messages.length + 1})",
          isLeft: isLeft,
        ),
      );

      // 메시지를 추가한 후, 스택의 높이가 화면의 3/4를 넘었는지 확인합니다.
      final screenHeight = MediaQuery.of(context).size.height;
      final stackHeight = _messages.length * _bubbleHeight;

      if (stackHeight > screenHeight * 0.75) {
        // 한계에 도달하면, 경고 메시지를 표시하고 자동 리셋 타이머를 시작합니다.
        _isLimitReached = true;
        _startAutoResetTimer();
      }
    });
  }

  // 2) 3초 후 자동 리셋을 실행하는 타이머 함수입니다.
  void _startAutoResetTimer() {
    Timer(const Duration(seconds: 3), () {
      // 타이머가 실행되면 상태를 업데이트합니다.
      if (!mounted) return; // 위젯이 화면에 없으면 실행하지 않습니다.
      setState(() {
        _messages.clear(); // 모든 메시지 삭제
        _isLimitReached = false; // 한계 도달 상태 해제
        _showResetNotice = true; // '리셋' 알림 활성화
      });

      // 1.5초 후에 '리셋' 알림을 자동으로 숨깁니다.
      Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _showResetNotice = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
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

          // 메시지 버블 스택
          Stack(
            children: _messages.asMap().entries.map((entry) {
              int index = entry.key;
              Message message = entry.value;
              // 각 버블을 Positioned로 하단부터 쌓고, Align으로 좌우 정렬합니다.
              return Positioned(
                bottom: 20.0 + (index * _bubbleHeight),
                left: 200,
                right: 200,
                child: Align(
                  alignment: message.isLeft
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: ChatBubble(text: message.text),
                ),
              );
            }).toList(),
          ),

          // 한계 도달 메시지
          if (_isLimitReached)
            Container(
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
            ),
          
          // 리셋 알림 메시지
          if (_showResetNotice)
            Container(
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
            ),
        ],
      ),
      // 글쓰기 버튼 (한계 도달 시 비활성화)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLimitReached ? null : _addBubble, // 한계 도달 시 버튼 비활성화
        backgroundColor: _isLimitReached ? Colors.grey : Colors.white,
        icon: Icon(
          Icons.add,
          color: _isLimitReached ? Colors.white70 : Colors.black,
        ),
        label: Text(
          '메시지 추가',
          style: TextStyle(
            color: _isLimitReached ? Colors.white70 : Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
      // 버블의 최대 너비를 화면의 60%로 제한하여 좌우 배치를 명확하게 합니다.
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
