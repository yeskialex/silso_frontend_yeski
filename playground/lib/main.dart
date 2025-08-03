import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/chat_bubble_view.dart';
import 'views/vote_appbar_view.dart';
import 'controllers/chat_controller.dart';
import 'controllers/vote_controller.dart';
import 'models/vote_model.dart';

// 앱의 시작점입니다.
void main() {
  runApp(const MyApp());
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
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ChatController()),
          ChangeNotifierProvider(create: (context) => VoteModel()),
          ChangeNotifierProxyProvider<VoteModel, VoteController>(
            create: (context) => VoteController(context.read<VoteModel>()),
            update: (context, voteModel, voteController) => 
                voteController ?? VoteController(voteModel),
          ),
        ],
        child: const BubbleStackScreen(),
      ),
    );
  }
}

// 버블 스택 기능을 보여줄 메인 화면입니다.
class BubbleStackScreen extends StatefulWidget {
  const BubbleStackScreen({super.key});

  @override
  BubbleStackScreenState createState() => BubbleStackScreenState();
}

class BubbleStackScreenState extends State<BubbleStackScreen> {
  final TextEditingController _textController = TextEditingController();

  void _handleSendMessage(ChatController controller) {
    if (_textController.text.isNotEmpty) {
      controller.addMessage(_textController.text, context);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        return Scaffold(
          appBar: const VoteAppBarView(
            title: '실소재판소',
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                // 배경 이미지
                Positioned.fill(
                  child: Image.network(
                    "https://placehold.co/800x1200/3F3329/white?text=Background",
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),

                // 메시지 리스트 뷰
                MessageListView(
                  messages: chatController.messages,
                  keyboardHeight: keyboardHeight,
                ),
                
                // 경고 및 알림 메시지
                Center(
                  child: chatController.isLimitReached
                      ? const LimitReachedWarningView()
                      : chatController.showResetNotice
                          ? const ResetNoticeView()
                          : const SizedBox.shrink(),
                ),

                // 하단 입력창
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: keyboardHeight,
                  child: BottomInputView(
                    controller: _textController,
                    participantCount: chatController.participantCount,
                    onSend: () {
                      if (!chatController.isLimitReached) {
                        _handleSendMessage(chatController);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

