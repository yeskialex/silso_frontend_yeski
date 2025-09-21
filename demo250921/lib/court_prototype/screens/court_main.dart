import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../views/chat_bubble_view.dart';
import '../controllers/chat_controller.dart';
import '../controllers/vote_controller.dart';
import '../models/vote_model.dart';
import '../widgets/keyboard_aware_scaffold.dart';
import '../widgets/png_background.dart';
import '../widgets/selective_transparent_design.dart';
import '../widgets/court_chat_input.dart';
import '../widgets/court_chat_message_widget.dart';
import '../services/court_service.dart';
import '../models/court_chat_message.dart';
import '../models/court_session_model.dart';
import '../config/court_config.dart';
import '../models/case_model.dart'; 

// Main screen of the Court app
class CourtPrototypeScreen extends StatelessWidget {
  final CourtSessionData? courtSession;
  
  const CourtPrototypeScreen({
    super.key,
    this.courtSession,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatController()),
        ChangeNotifierProvider(create: (context) => VoteModel()),
        ChangeNotifierProxyProvider<VoteModel, VoteController>(
          create: (context) => VoteController(context.read<VoteModel>()),
          update: (context, voteModel, voteController) => 
              voteController ?? VoteController(voteModel),
        ),
      ],
      child: BubbleStackScreen(courtSession: courtSession),
    );
  }
}

// Main screen that displays bubble stack functionality.
class BubbleStackScreen extends StatefulWidget {
  final CourtSessionData? courtSession;
  
  const BubbleStackScreen({
    super.key,
    this.courtSession,
  });

  @override
  BubbleStackScreenState createState() => BubbleStackScreenState();
}

class BubbleStackScreenState extends State<BubbleStackScreen> {
  final TextEditingController _textController = TextEditingController();
  final CourtService _courtService = CourtService();
  final ScrollController _scrollController = ScrollController();
  late Stream<List<CourtChatMessage>> _chatMessagesStream;
  late Stream<CourtSessionData?> _sessionUpdateStream;
  bool _isInitialized = false;
  int _messageCount = 0;
  bool _isSilenced = false;
  DateTime? _silenceTimestamp;
  DateTime? _lastSilenceEndTime;
  bool _hasUserSentMessage = false;
  bool _hasScrolledToBottomOnFirstLoad = false;
  Timer? _silenceTimer;
  int _silenceCountdown = 0;
  String? _silenceMessageId;
  bool _isImagePopupVisible = false; // ✅ 이 상태 변수를 추가합니다. ('정숙' 애니메이션)
  late CaseModel _caseModel;


  @override
  void initState() {
    super.initState();
    if (widget.courtSession != null) {
      _chatMessagesStream = _courtService.getCourtChatMessages(widget.courtSession!.id);
      _sessionUpdateStream = _courtService.getCourtSessionStream(widget.courtSession!.id);
      _isInitialized = true;
      
      _caseModel = _createCaseModelFromSession(widget.courtSession!);

      // Show session description popup after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionDescriptionDialog();
      });
    }
  }

  CaseModel _createCaseModelFromSession(CourtSessionData session) {
    // CourtSessionData의 필드를 사용하여 CaseModel 객체를 생성합니다.
    return CaseModel(
      id: session.caseId,
      title: session.title,
      description: session.description,
      category: session.category,
      creatorId: session.creatorId,
      creatorName: 'Unknown', // creatorName은 session에 없으므로 임의로 설정
      createdAt: session.dateCreated,
      status: CaseStatus.promoted, // 법정에서는 promoted 상태로 가정
      totalVotes: session.initialVotingResults['totalVotes'] ?? 0,
      guiltyVotes: session.guiltyVotes,
      notGuiltyVotes: session.notGuiltyVotes,
      guiltyPercentage: session.initialVotingResults['guiltyPercentage'] ?? 0.0,
      controversyScore: 0.0,
      promotionPriority: 0.0,
      voters: [],
      metadata: session.metadata,
    );
  }

  void _handleSendMessage(ChatController controller) {
    if (_textController.text.isNotEmpty) {
      controller.addMessage(_textController.text, context);
      _textController.clear();
    }
  }

  // Send court chat message
  Future<String?> _sendCourtChatMessage(String message, ChatMessageType messageType, {bool isSystemMessage = false}) async {
    if (widget.courtSession == null) return null;
    
    // Mark that user has sent a message (excluding system messages)
    if (messageType != ChatMessageType.system && !_hasUserSentMessage) {
      _hasUserSentMessage = true;
    }
    
    try {
      final messageId = await _courtService.sendChatMessage(
        courtId: widget.courtSession!.id,
        message: message,
        messageType: messageType,
        isSystemMessage: isSystemMessage,
      );
      return messageId;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send message: ${e.toString()}',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
  }

  // Delete court chat message
  Future<void> _deleteCourtChatMessage(String messageId) async {
    if (widget.courtSession == null) return;
    
    try {
      await _courtService.deleteChatMessage(messageId, widget.courtSession!.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete message: ${e.toString()}',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Auto-scroll to bottom when new messages arrive
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Scroll to bottom immediately when first loading messages
  void _scrollToBottomImmediate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // Scroll to the position where recent messages start after silence
  void _scrollToRecentMessages(List<CourtChatMessage> allMessages) {
    if (!_isSilenced || _silenceTimestamp == null || !_scrollController.hasClients) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Find the first message after silence timestamp
        final recentMessageIndex = allMessages.indexWhere((msg) => 
          msg.timestamp.isAfter(_silenceTimestamp!) && msg.messageType != ChatMessageType.system
        );
        
        if (recentMessageIndex != -1) {
          // Calculate approximate position based on message height
          const double messageHeight = 80.0; // Approximate height per message
          final double targetPosition = recentMessageIndex * messageHeight;
          
          // Scroll to that position
          _scrollController.jumpTo(
            targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent)
          );
        } else {
          // If no recent messages, scroll to bottom
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  // Handle join session (no voting needed - voting happens in case stage)
  Future<void> _handleJoinSession() async {
    if (widget.courtSession == null) return;
    
    try {
      // Join the court session
      await _courtService.joinCourtSession(widget.courtSession!.id);
      
      if (mounted) {
        // Close dialog and enter session
        Navigator.of(context).pop();
        
        // Show confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Joined court session for discussion',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(0xFF5F37CF),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to join session: ${e.toString()}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Show session description dialog when entering live session
  void _showSessionDescriptionDialog() {
    if (widget.courtSession == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView (
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with court gavel icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5F37CF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gavel,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Court Session',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8E8E8E),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Live Discussion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8E8E8E),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Session title
                Text(
                  widget.courtSession!.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                    fontFamily: 'Pretendard',
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Session description
                Text(
                  widget.courtSession!.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF424242),
                    fontFamily: 'Pretendard',
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Info section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F37CF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF5F37CF).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF5F37CF),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'How to participate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F37CF),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Voting has already been completed in the case stage\n'
                        '• Share your arguments and evidence through discussion\n'
                        '• Engage respectfully with other participants\n'
                        '• Your messages will be grouped by your position (guilty/not guilty)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5F37CF),
                          fontFamily: 'Pretendard',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Session info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.people_outline,
                        label: 'Participants',
                        value: '${widget.courtSession!.currentLiveMembers}',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.access_time,
                        label: 'Time Left',
                        value: _formatTimeLeft(widget.courtSession!.timeLeft),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Join section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Ready to join the discussion?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF121212),
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Join Discussion button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleJoinSession(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5F37CF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Join Discussion',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build info item widget
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: const Color(0xFF8E8E8E),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8E8E8E),
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF121212),
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  // Format time left for display
  String _formatTimeLeft(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Ending soon';
    }
  }

  // Show session ended dialog when time expires
  void _showSessionEndedDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clock icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF6B7280),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Session ended message
              const Text(
                'Session Ended',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF121212),
                  fontFamily: 'Pretendard',
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'The court session has ended.\nResults have been saved to history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF424242),
                  fontFamily: 'Pretendard',
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // View Results button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to court list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F37CF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Results in History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Start silence with countdown
  void _startSilence() async {
    if (!mounted || widget.courtSession == null) return;
    
    setState(() {
      _isSilenced = true;
      _silenceTimestamp = DateTime.now();
      // Don't reset _messageCount - keep track of messages that triggered silence
      _silenceCountdown = CourtSystemConfig.silenceDurationSeconds;
    });
    
    // Add initial silence message to chat that will update
    try {
      _silenceMessageId = await _sendCourtChatMessage('This session was silenced for $_silenceCountdown seconds', ChatMessageType.system, isSystemMessage: true);
    } catch (e) {
      debugPrint('Failed to send silence message: $e');
    }
    
    // Start countdown timer
    _silenceTimer?.cancel();
    _silenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _silenceCountdown--;
        _isSilenced = true;
        _isImagePopupVisible = true; // ✅ 이미지 팝업을 활성화합니다.

      });
      
        // ✅ 500ms 후 이미지 팝업을 비활성화합니다.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isImagePopupVisible = false;
            });
          }
        });

      if (_silenceCountdown > 0) {
        // Update existing silence message in chat with new countdown
        if (_silenceMessageId != null) {
          _courtService.updateChatMessage(_silenceMessageId!, 'This session was silenced for $_silenceCountdown seconds');
        }
      } else {
        // End silence and update message to final state
        timer.cancel();
        if (_silenceMessageId != null) {
          _courtService.updateChatMessage(_silenceMessageId!, 'This session was silenced.');
        }
        setState(() {
          _isSilenced = false;
          _lastSilenceEndTime = DateTime.now();
          _silenceTimestamp = null;
          _silenceMessageId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        // Use StreamBuilder to get real-time session updates
        return StreamBuilder<CourtSessionData?>(
          stream: widget.courtSession != null ? _sessionUpdateStream : null,
          initialData: widget.courtSession,
          builder: (context, sessionSnapshot) {
            final currentSession = sessionSnapshot.data ?? widget.courtSession;
            
            // Check if session has expired and auto-end it
            if (currentSession != null && currentSession.isLive && currentSession.timeLeft <= Duration.zero) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _courtService.checkAndEndExpiredSession(currentSession.id);
                // Show session ended dialog and navigate back
                _showSessionEndedDialog();
              });
            }
            
            return Scaffold(
              backgroundColor: Colors.transparent,
              // Use AppBar with real-time session data
              appBar: TransparentBackgroundVoteAppBar(
                title: '실소재판소',
                courtSession: currentSession,
              ),
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // Background that covers entire screen
              Positioned.fill(
                child: SafePngBackground(
                  imageAssetPath: 'assets/background/background.png',
                  fit: BoxFit.cover,
                  enableOverlay: true,
                  overlayColor: Colors.black.withValues(alpha: SelectiveTransparencyController.backgroundOverlayOpacity),
                  child: const SizedBox.expand(),
                ),
              ),
              
              // Main content (all content fully visible)
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Stack(
                  children: [
                    // Court chat messages or fallback to original
                    widget.courtSession != null && _isInitialized
                        ? _buildCourtChatView(keyboardHeight)
                        : MessageListView(
                            messages: chatController.messages,
                            keyboardHeight: keyboardHeight,
                          ),
                    
                    // Warning and notification messages (opacity 1.0 - fully visible)
                    Center(
                      child: chatController.isLimitReached
                          ? const LimitReachedWarningView()
                          : chatController.showResetNotice
                              ? const ResetNoticeView()
                              : const SizedBox.shrink(),
                    ),
                    
                    // Silence countdown overlay (+ 댓글 위로 rool-up 25.08.14. / 화면 밖으로 넘기기 animation) 
                    if (_isSilenced && _silenceCountdown > 0)
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // PNG 이미지 오버레이 (500ms 이후 사라짐)
                            // 이 부분은 _isImageVisible과 같은 상태 변수를 사용하여 제어해야 합니다.
                            // 예를 들어, 새로운 상태 변수 `bool _isImagePopupVisible = true;`를 추가하고
                            // initState()에서 Future.delayed를 이용해 false로 변경하는 로직이 필요합니다.
                            // 현재 코드에 상태 변수가 없으므로, 로직을 가정하여 작성합니다.
                            if (_isImagePopupVisible) // 새로운 상태 변수를 추가했다고 가정
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.0), // 배경을 어둡게 처리
                                  child: Center(
                                    child: Image.asset(
                                      'assets/animation_effect/message_effect.png', // 이미지 경로를 실제 파일 경로로 변경하세요.
                                      width: 220,
                                      height: 220,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    // Bottom input field - court chat or original
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 5,
                      child: widget.courtSession != null && _isInitialized
                          ? SafeArea(
                              child: CourtChatInput(
                                controller: _textController,
                                onSend: (message, messageType) => _sendCourtChatMessage(message, messageType),
                                isEnabled: !_isSilenced,
                                caseModel: _caseModel,
                              ),
                            )
                          : KeyboardAwarePositioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              minKeyboardPadding: 20.0,
                              child: TransparentBackgroundBottomInput(
                                controller: _textController,
                                participantCount: chatController.participantCount,
                                courtSession: currentSession,
                                onSend: () {
                                  if (!chatController.isLimitReached) {
                                    _handleSendMessage(chatController);
                                  }
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  // Build court chat view with real-time messages
  Widget _buildCourtChatView(double keyboardHeight) {
    return StreamBuilder<List<CourtChatMessage>>(
      stream: _chatMessagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading messages',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.7),
              ),
            ),
          );
        }

        final messages = snapshot.data ?? [];
        
        // Auto-scroll to bottom on first load and update message count
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Scroll to bottom immediately when messages are first loaded
          if (messages.isNotEmpty && !_hasScrolledToBottomOnFirstLoad) {
            _hasScrolledToBottomOnFirstLoad = true;
            _scrollToBottomImmediate();
          }
          
          // If silence just occurred, scroll to recent messages position
          if (_isSilenced && _silenceTimestamp != null) {
            _scrollToRecentMessages(messages);
          }
          
          final nonSystemMessages = messages.where((msg) => msg.messageType != ChatMessageType.system).toList();
          
          // Count messages since last silence ended
          final messagesSinceLastSilence = _lastSilenceEndTime != null
              ? nonSystemMessages.where((msg) => msg.timestamp.isAfter(_lastSilenceEndTime!)).length
              : nonSystemMessages.length;
          
          // Trigger silence every 5 new messages since last silence, but only if user has sent a message
          if (messagesSinceLastSilence >= 5 && _hasUserSentMessage && !_isSilenced) {
            _messageCount = nonSystemMessages.length;
            _startSilence();
          } else {
            _messageCount = nonSystemMessages.length;
          }
        });

        // Show all messages but position scroll at bottom after silence
        final displayMessages = messages;

        if (displayMessages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to share your thoughts!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          );
        }

        return Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(
              top: 100, // Account for app bar
              bottom: keyboardHeight + 160, // Account for keyboard and input
            ),
            child: ListView.builder(
              controller: _scrollController,
              reverse: false, // Show oldest first
              itemCount: displayMessages.length,
              itemBuilder: (context, index) {
                final message = displayMessages[index];
                
                // Auto-scroll when new message is added (last item)
                if (index == displayMessages.length - 1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }
                
                return CourtChatMessageWidget(
                  message: message,
                  onDelete: () => _deleteCourtChatMessage(message.id),
                );
              },
            ),
          ),
        );
      },
    );
  }
}