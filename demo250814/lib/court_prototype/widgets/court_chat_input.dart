import 'package:flutter/material.dart';
import '../models/court_chat_message.dart';

// popup court info 
import '../models/case_model.dart'; // Add this import for CaseModel
import 'case_card_widget.dart'; // Add this import for CaseCardWidget


// Chat input widget with guilty/not guilty toggle
class CourtChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String message, ChatMessageType messageType) onSend;
  final bool isEnabled;
  final CaseModel caseModel; // Add CaseModel here

  const CourtChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isEnabled = true,
    required this.caseModel, // Make it a required parameter
  });

  @override
  State<CourtChatInput> createState() => _CourtChatInputState();
}

class _CourtChatInputState extends State<CourtChatInput> {
  ChatMessageType _selectedMessageType = ChatMessageType.notGuilty;
  bool _isKeyboardVisible = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  void _handleSend() {
    final message = widget.controller.text.trim();
    if (message.isNotEmpty && widget.isEnabled) {
      widget.onSend(message, _selectedMessageType);
      widget.controller.clear();
    }
  }

  // New method to show the case card dialog
void _showCaseCardDialog() {
  // [#MODIFIED] Use a custom Dialog with the document UI
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (BuildContext context) {
      final screenSize = MediaQuery.of(context).size;
      final modalWidth = screenSize.width * 0.9;
      final modalHeight = screenSize.height * 0.65;

      // Use a custom dialog with a close button and the new document UI
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              // Add a close button
                Positioned(
                  top: 0,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFA68A54)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
            Stack(
              children: [
                SizedBox(
                  width: modalWidth,
                  height: modalHeight,
                  child: _buildDocumentUi(
                    width: modalWidth,
                    height: modalHeight,
                    title: widget.caseModel.title,
                    content: Text(
                      widget.caseModel.description.isNotEmpty
                          ? widget.caseModel.description
                          : "이 사건에 대한 상세 내용이 없습니다.",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    pageInfo: '1/1',
                  ),
                ),

              ],
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildChatTypeSwitcher(double widthRatio) {
    // 선택된 타입에 따라 아이콘과 색상을 결정합니다.
    final IconData iconData = Icons.sync;  
    final Color iconColor = _selectedMessageType == ChatMessageType.notGuilty
        ? const Color(0xFF5F37CF)
        : const Color(0xFFE93D40);

    return IconButton(
      icon: Icon(
        iconData,
        color: iconColor,
        size: 35 * widthRatio,
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

  Widget _buildHeader(String title, String pageInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Spacer for centering title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF5E4E2C), fontSize: 24, fontFamily: 'Pretendard', fontWeight: FontWeight.w700)
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(pageInfo, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFFA68A54), fontSize: 16, fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

   // Create court info card 
   Widget _buildDocumentUi({
  required double width,
  required double height,
  required String title,
  required Widget content,
  String pageInfo = '1/1',
}) {
    const double borderWidth = 12.0;
    const double foldSize = 50.0;

    Widget buildBorder(Widget child) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xFF79673F)),
          CustomPaint(
            painter: _PixelPatternPainter(
              dotColor: Colors.black.withOpacity(0.1),
              step: 3.0,
            ),
            child: Container(),
          ),
          child,
        ],
      );
    }

    return Stack(
      children: [
        Container(color: const Color(0xFFF2E3BC)),
        CustomPaint(
          size: Size(width, height),
          painter: _PixelPatternPainter(
            dotColor: Colors.black.withOpacity(0.05),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          width: foldSize,
          height: foldSize,
          child: ClipPath(
            clipper: _FoldedCornerClipper(),
            child: Container(color: const Color(0xFFD4C0A1)),
          ),
        ),
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: SizedBox(width: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          right: 0, top: 0, bottom: 0,
          child: SizedBox(width: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          left: 0, top: 0, right: 0,
          child: SizedBox(height: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          left:  0, bottom: 0, right: 0,
          child: SizedBox(height: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Padding(
          padding: const EdgeInsets.all(borderWidth + 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(title, pageInfo),
              const SizedBox(height: 15),
              Container(width: double.infinity, height: 1, color: const Color(0xFFE0C898)),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ],
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
        color: Colors.white.withValues(alpha: 0.9), // gradiation 부여 
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // 이 속성을 추가합니다.
            children: [
              Column(
                children: [
                  _buildChatTypeSwitcher(widthRatio),
                  SizedBox(
                    height: 20 * widthRatio, // 버튼과 입력 필드 사이의 간격 (text 입력을 위한 세로 layout을 위한 여백)
                  ),
                ],
              ), // 전환 case1 - sliding button
              
               
              Expanded( // color 흰색으로, 
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.isEnabled,
                  maxLines: 1,
                  maxLength: 200,
                  style: TextStyle(
                    color: Colors.black54,
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
                    fillColor: Colors.black54.withValues(alpha: 0.3),
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

              // Switch between send and docs icon based on keyboard visibility
              GestureDetector(
                onTap: widget.isEnabled 
                    ? (_isKeyboardVisible ? _handleSend : _showCaseCardDialog) 
                    : null,
                child: Container(
                  width: 30 * widthRatio,
                  height: 30 * widthRatio,
                  decoration: BoxDecoration(
                    color: _isKeyboardVisible
                        ? (widget.isEnabled 
                            ? Color(_selectedMessageType.colorValue) 
                            : Colors.grey)
                        : const Color(0xFF5F37CF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isKeyboardVisible ? Icons.send : Icons.document_scanner,
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
      child: AnimatedContainer( // layout 현재 유지 
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

class _PixelPatternPainter extends CustomPainter {
  final Color dotColor;
  final double step;
  _PixelPatternPainter({required this.dotColor, this.step = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FoldedCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}