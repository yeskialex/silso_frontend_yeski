import 'package:flutter/material.dart';
import '../models/chat_model.dart';

// 채팅 버블 위젯 - UI 컴포넌트
class ChatBubbleView extends StatelessWidget {
  final Message message;

  const ChatBubbleView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * ChatConfig.maxBubbleWidthRatio,
      ),
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
        message.text,
        style: const TextStyle(
          color: Color(0xFF121212),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 메시지 리스트를 표시하는 위젯
class MessageListView extends StatelessWidget {
  final List<Message> messages;
  final double keyboardHeight;

  const MessageListView({
    super.key,
    required this.messages,
    required this.keyboardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ChatConfig.inputBarHeight + keyboardHeight),
      child: Stack(
        children: messages.asMap().entries.map((entry) {
          int index = entry.key;
          Message message = entry.value;
          return Positioned(
            bottom: 20.0 + (index * ChatConfig.bubbleHeight),
            left: 20,
            right: 20,
            child: Align(
              alignment: message.isLeft
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: ChatBubbleView(message: message),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 하단 입력창 위젯
class BottomInputView extends StatelessWidget {
  final TextEditingController controller;
  final int participantCount;
  final VoidCallback onSend;

  const BottomInputView({
    super.key,
    required this.controller,
    required this.participantCount,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3F3329),
      child: SafeArea(
        top: false,
        child: Container(
          height: ChatConfig.inputBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 정보 표시 행
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 참여자 수: $participantCount명',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 100),
                    const Text(
                      '남은 시간: 3시간',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 입력창과 아이콘 행
              Expanded(
                flex: 3,
                child: Row(
                  children: [
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

// 한계 도달 경고 위젯
class LimitReachedWarningView extends StatelessWidget {
  const LimitReachedWarningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        '의견이 가득 찼습니다! ${ChatConfig.autoResetSeconds}초 후 초기화됩니다.',
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// 리셋 알림 위젯
class ResetNoticeView extends StatelessWidget {
  const ResetNoticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.8),
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