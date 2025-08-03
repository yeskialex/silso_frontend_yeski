import 'dart:math';
import 'package:flutter/material.dart';

// 앱의 시작점입니다.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Bubble Animation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard', // 앱 전체에 Pretendard 폰트 적용
      ),
      home: const AnimationScreen(),
    );
  }
}

// 애니메이션을 보여줄 메인 화면입니다.
class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  // 화면에 표시될 모든 채팅 버블 위젯을 관리하는 리스트입니다.
  // 각 버블은 고유한 Key를 가집니다.
  final List<Widget> _bubbles = [];
  final Random _random = Random();

  // 새로운 채팅 버블을 추가하는 함수입니다.
  void _addBubble() {
    // 버블마다 고유한 Key를 생성하여 Flutter가 각 위젯을 식별할 수 있도록 합니다.
    final key = UniqueKey();
    
    // 화면 좌우 랜덤 위치를 결정합니다.
    final double horizontalPosition = _random.nextDouble() * (MediaQuery.of(context).size.width - 150);
    
    // 버블이 사라질 때 리스트에서 제거하는 콜백 함수입니다.
    final onCompleted = () {
      setState(() {
        _bubbles.removeWhere((widget) => widget.key == key);
      });
    };

    setState(() {
      _bubbles.add(
        AnimatedChatBubble(
          key: key,
          text: "새로운 의견입니다! ✨",
          startHorizontalPosition: horizontalPosition,
          screenHeight: MediaQuery.of(context).size.height,
          onCompleted: onCompleted,

        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 배경 이미지 설정 (화면 비율에 맞게 채움)
          Positioned.fill(
            child: Image.network(
              "https://placehold.co/800x1200/3F3329/white?text=Background",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3), // 이미지를 약간 어둡게 처리
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // 생성된 모든 채팅 버블을 Stack 위에 표시합니다.
          ..._bubbles,
        ],
      ),
      // 2. 글쓰기(버블 추가) 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _addBubble,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// 개별 채팅 버블의 애니메이션을 담당하는 위젯입니다.
class AnimatedChatBubble extends StatefulWidget {
  final String text;
  final double startHorizontalPosition;
  final double screenHeight; 
  final VoidCallback onCompleted; // 애니메이션이 끝나면 호출될 콜백

  const AnimatedChatBubble({
    required Key key,
    required this.text,
    required this.startHorizontalPosition,
    required this.screenHeight,
    required this.onCompleted,
  }) : super(key: key);

  @override
  _AnimatedChatBubbleState createState() => _AnimatedChatBubbleState();
}

class _AnimatedChatBubbleState extends State<AnimatedChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _driftAnimation;

  @override
  void initState() {
    super.initState();
    
    // 4초 동안 애니메이션을 재생하는 컨트롤러를 생성합니다.
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // 애니메이션의 각 단계를 정의합니다.
    // Fade(투명도) 애니메이션: 0~25% 구간에서 나타나고, 75~100% 구간에서 사라집니다.
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_controller);

    // Drift(이동) 애니메이션: 전체 시간에 걸쳐 화면의 높이만큼 위로 이동하여 사라집니다.
    _driftAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, widget.screenHeight * (3/4)), // 화면 높이의 만큼 위로 이동
    ).animate(_controller);

    // 애니메이션이 끝나면 onCompleted 콜백을 호출하여 위젯을 제거하도록 합니다.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });

    // 애니메이션을 시작합니다.
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder를 사용하여 애니메이션 값의 변화에 따라 위젯을 다시 그립니다.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          // 시작 위치에서 애니메이션 값만큼 이동합니다.
          left: widget.startHorizontalPosition,
          bottom: 50 + _driftAnimation.value.dy,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: _buildBubble(),
    );
  }

  // 채팅 버블의 모양을 정의하는 위젯입니다.
  Widget _buildBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 3, color: Color(0xFF121212)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        widget.text,
        style: const TextStyle(
          color: Color(0xFF121212),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
