import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vote_model.dart';
import '../services/court_service.dart';
import '../models/court_chat_message.dart';

/// Selective transparency design - only background transparent, content fully visible
class SelectiveTransparentDesign {
  /// AppBar 배경만 투명하게 만드는 래퍼
  static PreferredSizeWidget createTransparentBackgroundAppBar({
    required PreferredSizeWidget originalAppBar,
    bool transparentBackground = true,
  }) {
    return SelectiveTransparentAppBar(
      originalAppBar: originalAppBar,
      transparentBackground: transparentBackground,
    );
  }

  /// Wrapper that makes only the bottom input field background transparent
  static Widget createTransparentBackgroundBottom({
    required Widget originalBottom,
    bool transparentBackground = true,
  }) {
    return SelectiveTransparentBottom(
      originalBottom: originalBottom,
      transparentBackground: transparentBackground,
    );
  }
}

/// AppBar의 배경만 투명하게 만드는 커스텀 AppBar
class SelectiveTransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget originalAppBar;
  final bool transparentBackground;

  const SelectiveTransparentAppBar({
    super.key,
    required this.originalAppBar,
    this.transparentBackground = true,
  });

  @override
  Size get preferredSize => originalAppBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    // Use original AppBar as is, but change only background to transparent
    return Container(
      decoration: BoxDecoration(
        // Set background to transparent
        color: transparentBackground ? Colors.transparent : null,
      ),
      child: originalAppBar,
    );
  }
}

/// Wrapper that makes only the bottom widget background transparent
class SelectiveTransparentBottom extends StatelessWidget {
  final Widget originalBottom;
  final bool transparentBackground;

  const SelectiveTransparentBottom({
    super.key,
    required this.originalBottom,
    this.transparentBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: transparentBackground ? Colors.transparent : null,
      ),
      child: originalBottom,
    );
  }
}

/// VoteAppBarView의 투명 배경 버전 with Live Vote Stream
class TransparentBackgroundVoteAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final dynamic courtSession; // CourtSessionData from add_court.dart
  final VoidCallback? onBackPressed;
  final VoidCallback? onQuitPressed;

  const TransparentBackgroundVoteAppBar({
    super.key,
    required this.title,
    this.courtSession,
    this.onBackPressed,
    this.onQuitPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(180.0);

  @override
  State<TransparentBackgroundVoteAppBar> createState() => _TransparentBackgroundVoteAppBarState();
}

class _TransparentBackgroundVoteAppBarState extends State<TransparentBackgroundVoteAppBar> {
  final CourtService _courtService = CourtService();
  late Stream<Map<String, int>> _liveVoteStream;

  @override
  void initState() {
    super.initState();
    // Initialize the live vote stream if we have a court session
    if (widget.courtSession?.id != null) {
      // Add a small delay to reduce rapid fire updates and prevent blinking
      _liveVoteStream = _courtService.getLiveVoteCountsStream(widget.courtSession.id)
          .distinct((prev, next) => 
              prev['guiltyVotes'] == next['guiltyVotes'] && 
              prev['notGuiltyVotes'] == next['notGuiltyVotes']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Change background to transparent
      decoration: const BoxDecoration(
        color: Colors.transparent, // Only background transparent
        // boxShadow 제거 (투명한 배경에는 그림자가 어울리지 않음)
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1st Row: Quit Icon (right aligned) - 콘텐츠는 그대로 유지
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: widget.onQuitPressed ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 2nd Row: Dynamic Scale Bar with Live Vote Stream
            widget.courtSession?.id != null
                ? StreamBuilder<Map<String, int>>(
                    key: ValueKey('live_votes_${widget.courtSession?.id}'),
                    stream: _liveVoteStream,
                    initialData: {
                      'guiltyVotes': widget.courtSession?.guiltyVotes ?? 0,
                      'notGuiltyVotes': widget.courtSession?.notGuiltyVotes ?? 0,
                      'totalVotes': (widget.courtSession?.guiltyVotes ?? 0) + (widget.courtSession?.notGuiltyVotes ?? 0),
                    },
                    builder: (context, snapshot) {
                      final liveVotes = snapshot.data ?? {};
                      final guiltyVotes = liveVotes['guiltyVotes'] ?? 0;
                      final notGuiltyVotes = liveVotes['notGuiltyVotes'] ?? 0;
                      final totalVotes = guiltyVotes + notGuiltyVotes;
                      final guiltyRatio = totalVotes > 0 ? guiltyVotes / totalVotes : 0.5;

                      // Update the vote model with the live data (only if data actually changed)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          final voteModel = Provider.of<VoteModel>(context, listen: false);
                          voteModel.updateWithLiveVotes(liveVotes);
                        }
                      });

                      return TransparentBackgroundScaleBar(
                        guiltyRatio: guiltyRatio,
                        guiltyVotes: guiltyVotes,
                        notGuiltyVotes: notGuiltyVotes,
                      );
                    },
                  )
                : TransparentBackgroundScaleBar(
                    guiltyRatio: 0.5,
                    guiltyVotes: 0,
                    notGuiltyVotes: 0,
                  ),
            // 3rd Row: Vote Control Row with interactive voting
            TransparentBackgroundVoteControlRow(
              title: widget.title,
              courtSession: widget.courtSession,
              onVoteChanged: (choice) {
                debugPrint('Vote changed to: $choice');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Scale bar widget with transparent background
class TransparentBackgroundScaleBar extends StatelessWidget {
  final double guiltyRatio;
  final int guiltyVotes;
  final int notGuiltyVotes;

  const TransparentBackgroundScaleBar({
    super.key,
    required this.guiltyRatio,
    required this.guiltyVotes,
    required this.notGuiltyVotes,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Stack(
          children: [
            // Background (not guilty color - blue)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3146E6).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            // Guilty section (dynamically changing area from left - red)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: (screenWidth - 32) * guiltyRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            // Center indicator showing guilty percentage
            Positioned(
              left: (screenWidth - 32) * guiltyRatio - 20,
              top: -8,
              child: Container(
                width: 40,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${(guiltyRatio * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF3F3329),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Vote count displays on both ends
            Positioned(
              left: 8,
              top: 6,
              child: Text(
                '$guiltyVotes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: Text(
                '$notGuiltyVotes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 투명한 배경을 가진 투표 컨트롤 행 위젯 (interactive voting buttons)
class TransparentBackgroundVoteControlRow extends StatefulWidget {
  final String title;
  final Function(VoteChoice)? onVoteChanged;
  final dynamic courtSession; // For vote submission

  const TransparentBackgroundVoteControlRow({
    super.key,
    required this.title,
    this.onVoteChanged,
    this.courtSession,
  });

  @override
  State<TransparentBackgroundVoteControlRow> createState() => _TransparentBackgroundVoteControlRowState();
}

/// Vote choice enumeration
enum VoteChoice { none, guilty, notGuilty }

class _TransparentBackgroundVoteControlRowState extends State<TransparentBackgroundVoteControlRow>
    with SingleTickerProviderStateMixin {
  VoteChoice _selectedVote = VoteChoice.none;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final CourtService _courtService = CourtService();
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleVote(VoteChoice choice) async {
    if (_isVoting || _selectedVote == choice) return;

    setState(() {
      _isVoting = true;
    });

    // Trigger animation
    await _animationController.forward();
    await _animationController.reverse();

    // Update local state
    setState(() {
      _selectedVote = choice;
      _isVoting = false;
    });

    // Notify parent about vote change
    widget.onVoteChanged?.call(choice);

    // Submit vote to court service if courtSession is available
    if (widget.courtSession?.id != null) {
      try {
        final voteMessage = choice == VoteChoice.guilty 
            ? '투표: 유죄 (Guilty)'
            : '투표: 무죄 (Not Guilty)';
        
        final messageType = choice == VoteChoice.guilty 
            ? ChatMessageType.guilty
            : ChatMessageType.notGuilty;
            
        await _courtService.sendChatMessage(
          courtId: widget.courtSession!.id,
          message: voteMessage,
          messageType: messageType,
          isSystemMessage: true, // 채팅창에 표시되지 않음
        );
        
        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                choice == VoteChoice.guilty 
                    ? '유죄에 투표했습니다 (Voted Guilty)'
                    : '무죄에 투표했습니다 (Voted Not Guilty)',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Color(messageType.colorValue),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Vote submission failed: $e');
        // Show error feedback to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to submit vote: ${e.toString()}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildVoteButton({
    required String label,
    required Color baseColor,
    required VoteChoice voteChoice,
    required double fontSize,
  }) {
    final isSelected = _selectedVote == voteChoice;
    final isDisabled = _isVoting;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : () => _handleVote(voteChoice),
              borderRadius: BorderRadius.circular(22),
              splashColor: baseColor.withValues(alpha: 0.3),
              highlightColor: baseColor.withValues(alpha: 0.2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? baseColor
                      : baseColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: isSelected 
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Colors.black38 : Colors.black26,
                      blurRadius: isSelected ? 4 : 2,
                      offset: Offset(0, isSelected ? 2 : 1),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSelected ? fontSize + 1 : fontSize,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                        child: Text(label),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              size: 8,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    if (_isVoting && _selectedVote == voteChoice)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Guilty button (left side - red)
          _buildVoteButton(
            label: 'Guilty',
            baseColor: const Color(0xFFF44336),
            voteChoice: VoteChoice.guilty,
            fontSize: 14,
          ),
          // 중앙 제목 영역
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_selectedVote != VoteChoice.none)
                    Text(
                      _selectedVote == VoteChoice.guilty ? 'You voted: Guilty' : 'You voted: Not Guilty',
                      style: TextStyle(
                        color: _selectedVote == VoteChoice.guilty 
                            ? const Color(0xFFF44336)
                            : const Color(0xFF3146E6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Not Guilty button (right side - blue)
          _buildVoteButton(
            label: 'Not Guilty',
            baseColor: const Color(0xFF3146E6),
            voteChoice: VoteChoice.notGuilty,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}

/// 투명한 배경을 가진 하단 입력창
class TransparentBackgroundBottomInput extends StatelessWidget {
  final TextEditingController controller;
  final int participantCount;
  final VoidCallback onSend;
  final dynamic courtSession; // CourtSessionData for timer

  const TransparentBackgroundBottomInput({
    super.key,
    required this.controller,
    required this.participantCount,
    required this.onSend,
    this.courtSession,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // 배경만 투명하게 변경
      child: SafeArea(
        top: false,
        child: Container(
          height: 80, // ChatConfig.inputBarHeight 대신 고정값 사용
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 정보 표시 행 - 콘텐츠는 그대로 유지
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
                    LiveTimerWidget(courtSession: courtSession),
                  ],
                ),
              ),
              // 입력창과 아이콘 행 - 콘텐츠는 그대로 유지
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

/// 선택적 투명도 설정
class SelectiveTransparencyController {
  /// AppBar 배경 투명도 (배경만)
  static const bool appBarBackgroundTransparent = true;
  
  /// 하단 입력창 배경 투명도 (배경만)
  static const bool bottomBackgroundTransparent = true;
  
  /// 모든 다른 위젯들의 투명도 (완전히 보이게)
  static const double contentOpacity = 1.0;
  
  /// 배경 이미지 오버레이 투명도
  static const double backgroundOverlayOpacity = 0.3;
}

// Live timer widget for court session countdown
class LiveTimerWidget extends StatefulWidget {
  final dynamic courtSession;

  const LiveTimerWidget({
    super.key,
    this.courtSession,
  });

  @override
  State<LiveTimerWidget> createState() => _LiveTimerWidgetState();
}

class _LiveTimerWidgetState extends State<LiveTimerWidget> {
  late Timer _timer;
  Duration _currentTimeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
      
      // If time is up, show expired state
      if (_currentTimeLeft <= Duration.zero && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeLeft() {
    if (mounted && widget.courtSession != null) {
      setState(() {
        _currentTimeLeft = widget.courtSession.timeLeft;
      });
    }
  }

  String _formatCountdown(Duration duration) {
    if (duration <= Duration.zero) {
      return '0:00';
    }
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.courtSession == null) {
      return const Text(
        '남은 시간: --:--',
        style: TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      );
    }

    final isExpiring = _currentTimeLeft.inSeconds <= 30;
    final isExpired = _currentTimeLeft <= Duration.zero;
    
    return Text(
      isExpired ? '남은 시간: 종료됨' : '남은 시간: ${_formatCountdown(_currentTimeLeft)}',
      style: TextStyle(
        color: isExpired 
            ? Colors.red 
            : isExpiring 
                ? const Color(0xFFFF6B35) 
                : Colors.white,
        fontSize: 14,
        fontWeight: isExpiring || isExpired ? FontWeight.w600 : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}