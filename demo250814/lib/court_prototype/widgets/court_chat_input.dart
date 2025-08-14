import 'package:flutter/material.dart';
import '../models/court_chat_message.dart';

// Chat input widget with guilty/not guilty toggle
class CourtChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String message, ChatMessageType messageType) onSend;
  final bool isEnabled;

  const CourtChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<CourtChatInput> createState() => _CourtChatInputState();
}

class _CourtChatInputState extends State<CourtChatInput> {
  ChatMessageType _selectedMessageType = ChatMessageType.notGuilty;

  void _handleSend() {
    final message = widget.controller.text.trim();
    if (message.isNotEmpty && widget.isEnabled) {
      widget.onSend(message, _selectedMessageType);
      widget.controller.clear();
    }
  }


  // ✅ 새로운 스위치 버튼 위젯을 여기에 정의합니다.
  Widget _buildChatTypeSwitcher1(double widthRatio) {
    // 선택된 타입에 따라 배경색과 아이콘 색상을 결정합니다.
    final Color selectedColor = _selectedMessageType == ChatMessageType.notGuilty 
        ? const Color(0xFF5F37CF) // Not Guilty color
        : const Color(0xFFE93D40); // Guilty color

    return GestureDetector(
      onTap: () {
        // 탭 시 타입을 변경합니다.
        setState(() {
          _selectedMessageType = _selectedMessageType == ChatMessageType.notGuilty
              ? ChatMessageType.guilty
              : ChatMessageType.notGuilty;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 70 * widthRatio,
        height: 35 * widthRatio,
        decoration: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(20 * widthRatio),
        ),
        padding: EdgeInsets.all(4 * widthRatio),
        child: Stack(
          children: [
            // guilty 아이콘 (오른쪽에 위치)
            Positioned(
              right: 0,
              child: Icon(
                Icons.thumb_down,
                color: Colors.white.withOpacity(0.5),
                size: 20 * widthRatio,
              ),
            ),
            // not guilty 아이콘 (왼쪽에 위치)
            Positioned(
              left: 0,
              child: Icon(
                Icons.thumb_up,
                color: Colors.white.withOpacity(0.5),
                size: 20 * widthRatio,
              ),
            ),
            // 좌우로 움직이는 동그란 버튼
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: _selectedMessageType == ChatMessageType.notGuilty
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: 28 * widthRatio,
                height: 28 * widthRatio,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  // 선택된 타입에 따라 아이콘을 변경합니다.
                  _selectedMessageType == ChatMessageType.notGuilty
                      ? Icons.thumb_up
                      : Icons.thumb_down,
                  color: selectedColor,
                  size: 18 * widthRatio,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTypeSwitcher2(double widthRatio) {
    // 선택된 타입에 따라 아이콘과 색상을 결정합니다.
    final IconData iconData = _selectedMessageType == ChatMessageType.notGuilty
        ? Icons.thumb_up
        : Icons.thumb_down;
    final Color iconColor = _selectedMessageType == ChatMessageType.notGuilty
        ? const Color(0xFF5F37CF)
        : const Color(0xFFE93D40);

    return IconButton(
      icon: Icon(
        iconData,
        color: iconColor,
        size: 30 * widthRatio,
      ),
      onPressed: () {
        setState(() {
          // 상태를 변경하여 아이콘을 전환합니다.
          _selectedMessageType = _selectedMessageType == ChatMessageType.notGuilty
              ? ChatMessageType.guilty
              : ChatMessageType.notGuilty;
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Responsive design calculations
    const double baseWidth = 393.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final double widthRatio = screenWidth / baseWidth;

    return  Container(
      // 고정된 높이를 제거하여 내용에 맞게 자동 조절되도록 합니다.
      // height: 100 * widthRatio,
      padding: EdgeInsets.symmetric(
        horizontal: 4 * widthRatio,
        vertical: 1 * widthRatio,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,  
        children: [
          // Message type toggle buttons // -> 
          _buildChatTypeSwitcher1(widthRatio), // 전환 case1 - sliding button
          _buildChatTypeSwitcher2(widthRatio), // 전환 case2 - icon button

          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildMessageTypeButton(
          //         type: ChatMessageType.notGuilty,
          //         label: 'Not Guilty',
          //         icon: Icons.thumb_up,
          //         widthRatio: widthRatio,
          //       ),
          //     ),
          //     SizedBox(width: 8 * widthRatio),
          //     Expanded(
          //       child: _buildMessageTypeButton(
          //         type: ChatMessageType.guilty,
          //         label: 'Guilty',
          //         icon: Icons.thumb_down,
          //         widthRatio: widthRatio,
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 0.5 * widthRatio),
          // Text input with send button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.isEnabled,
                  maxLines: 1,
                  maxLength: 200,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * widthRatio,
                    fontFamily: 'Pretendard',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share your ${_selectedMessageType.displayName.toLowerCase()} argument...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16 * widthRatio,
                      fontFamily: 'Pretendard',
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24 * widthRatio),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12 * widthRatio,
                      vertical: 2 * widthRatio,
                    ),
                    counterStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12 * widthRatio,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              SizedBox(width: 8 * widthRatio),
              // Send button
              GestureDetector(
                onTap: widget.isEnabled ? _handleSend : null,
                child: Container(
                  width: 30 * widthRatio,
                  height: 30 * widthRatio,
                  decoration: BoxDecoration(
                    color: widget.isEnabled
                        ? Color(_selectedMessageType.colorValue)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 16 * widthRatio,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build message type toggle button
  Widget _buildMessageTypeButton({
    required ChatMessageType type,
    required String label,
    required IconData icon,
    required double widthRatio,
  }) {
    final isSelected = _selectedMessageType == type;
    final color = Color(type.colorValue);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMessageType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 4 * widthRatio,
          vertical: 1 * widthRatio,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? color 
              : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20 * widthRatio),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 18 * widthRatio,
            ),
            SizedBox(width: 6 * widthRatio),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 14 * widthRatio,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }
}