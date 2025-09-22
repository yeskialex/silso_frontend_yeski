
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'case_model.dart';
import '../services/case_service.dart';
import '../widgets/widget_buildDocumentUi.dart';

enum VoteChoice { none, pros, cons }

// This modal is for voting on active cases.
class VoteModal extends StatefulWidget {
  final CaseModel caseModel;
  final CaseService caseService;
  const VoteModal({super.key, required this.caseModel, required this.caseService});

  @override
  State<VoteModal> createState() => _VoteModalState();
}

class _VoteModalState extends State<VoteModal> {
  VoteChoice _voteChoice = VoteChoice.none;
  bool _isVoting = false;
  bool _animationCompleted = false;

  void _handleVote(VoteChoice choice) {
    if (_isVoting) return;
    
    setState(() {
      _isVoting = true;
      _voteChoice = choice; // Set choice immediately for animation
    });

    // Start animation and close modal after animation completes
    _startVotingAnimation(choice);
  }

  void _startVotingAnimation(VoteChoice choice) async {
    // Wait for sliding folder animation to complete
    // AnimatedPositioned: 1000ms + AnimatedOpacity: 600ms + buffer: 200ms
    await Future.delayed(const Duration(milliseconds: 1800));
    
    // Mark animation as complete and show final state briefly
    if (mounted) {
      setState(() {
        _animationCompleted = true;
        _isVoting = false; // Animation completed
      });
      
      // Small delay to show final animation state before closing
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (mounted) {
        Navigator.of(context).pop();
        // Perform vote in background after modal closes
        _performVoteWithErrorHandling(choice);
      }
    }
  }

  Future<void> _performVoteWithErrorHandling(VoteChoice choice) async {
    try {
      await _performVote(choice);
      if (mounted) {
        _handleVoteSuccess(choice);
      }
    } catch (e) {
      if (mounted) {
        _handleVoteError(e);
      }
    }
  }

  Future<void> _performVote(VoteChoice choice) async {
    // Check authentication first, sign in anonymously if needed
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
      } catch (authError) {
        throw Exception('AUTH_REQUIRED');
      }
    }
    
    if (user == null) {
      throw Exception('AUTH_REQUIRED');
    }
    
    // Cast the actual vote using CaseService
    final voteType = choice == VoteChoice.pros ? CaseVoteType.notGuilty : CaseVoteType.guilty;
    
    await widget.caseService.voteOnCase(
      caseId: widget.caseModel.id,
      voteType: voteType,
    );

    // Vote succeeded, success will be handled in _performVoteWithErrorHandling
  }

  void _handleVoteSuccess(VoteChoice choice) async {
    // Check if case was promoted after voting
    try {
      final updatedCase = await widget.caseService.getCase(widget.caseModel.id);
      final wasPromoted = updatedCase?.status == CaseStatus.promoted || updatedCase?.status == CaseStatus.qualified;
      
      if (mounted) {
        _showSuccessMessage(choice, wasPromoted);
      }
    } catch (e) {
      // Even if we can't check promotion status, still show success
      if (mounted) {
        _showSuccessMessage(choice, false);
      }
    }
  }

  void _handleVoteError(dynamic error) {
    final errorMessage = _translateError(error);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }


  // Build button animation for voting process - matches main sliding folder animation
  Widget _buildButtonAnimation(VoteChoice choice) {
    const double buttonWidth = 50.0;
    const double buttonHeight = 35.0;
    const double fileWidth = 42.0;
    const double fileHeight = 28.0;
    
    // Determine if this button's choice matches the selected vote
    final bool isThisChoiceSelected = _voteChoice == choice;
    
    Color fileColor;
    if (isThisChoiceSelected && choice == VoteChoice.pros) {
      fileColor = const Color(0xFF3146E6);
    } else if (isThisChoiceSelected && choice == VoteChoice.cons) {
      fileColor = const Color(0xFFFF3838);
    } else {
      fileColor = Colors.transparent;
    }
    
    final double fileTopPosition = (buttonHeight / 2 - fileHeight / 1.5);
    
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated file sliding down (similar to main animation)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            top: ((_isVoting || _animationCompleted) && isThisChoiceSelected) ? fileTopPosition : -fileHeight,
            child: Container(
              width: fileWidth * 0.85,
              height: fileHeight * 0.8,
              decoration: ShapeDecoration(
                color: fileColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Folder container (similar to main animation)
          if ((_isVoting || _animationCompleted) && isThisChoiceSelected)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              top: fileTopPosition + 2,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: ((_isVoting || _animationCompleted) && isThisChoiceSelected) ? 0.8 : 0.0,
                child: Container(
                  width: buttonWidth,
                  height: buttonHeight * 0.75,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF4B2CA4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _translateError(dynamic error) {
    String errorMsg = error.toString();
    
    // Remove common error prefixes to get clean error message
    errorMsg = errorMsg
        .replaceFirst('Exception: ', '')
        .replaceFirst('Failed to vote: ', '')
        .replaceFirst(RegExp(r'^Error: .*Use the properties.*'), '투표 처리 중 오류가 발생했습니다');
    
    // Map common error patterns to user-friendly Korean messages
    final errorTranslations = {
      'AUTH_REQUIRED': '로그인이 필요합니다',
      'User not authenticated': '로그인이 필요합니다',
      'already voted': '이미 투표하셨습니다',
      'You have already voted': '이미 투표하셨습니다',
      'Daily voting limit': '일일 투표 제한에 도달했습니다',
      'voting limit reached': '일일 투표 제한에 도달했습니다',
      'not in voting phase': '투표 기간이 아닙니다',
      'Case is not in voting phase': '투표 기간이 아닙니다',
      'expired': '투표 기간이 만료되었습니다',
      'voting period has expired': '투표 기간이 만료되었습니다',
      'permission-denied': '권한이 없습니다',
      'Permission denied': '권한이 없습니다',
      'network': '네트워크 연결을 확인해주세요',
      'timeout': '네트워크 연결을 확인해주세요',
      'Case not found': '사건을 찾을 수 없습니다',
      'Voting is temporarily disabled': '투표가 일시적으로 비활성화되었습니다',
    };
    
    // Find matching error pattern and return translated message
    for (final entry in errorTranslations.entries) {
      if (errorMsg.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Fallback for unknown errors or very long error messages
    if (errorMsg.trim().isEmpty || errorMsg.length > 150) {
      return '투표 처리 중 오류가 발생했습니다';
    }
    
    return errorMsg;
  }


  void _showSuccessMessage(VoteChoice choice, bool wasPromoted) {
    if (wasPromoted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '사건이 재판소로 승급되었습니다! 재판소 탭을 확인해보세요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF6037D0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            choice == VoteChoice.pros ? '찬성 투표가 완료되었습니다!' : '반대 투표가 완료되었습니다!',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: choice == VoteChoice.pros ? const Color(0xFF3146E6) : const Color(0xFFFF3838),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final modalWidth = screenSize.width * 0.9;
    final modalHeight = screenSize.height * 0.6;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SizedBox(
              width: modalWidth,
              height: modalHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildAnimatedFile(modalHeight, modalWidth,
                      const Color(0xFFFF3838), VoteChoice.cons),
                  _buildAnimatedFile(modalHeight, modalWidth,
                      const Color(0xFF3146E6), VoteChoice.pros),
                  buildDocumentUi(
                    width: modalWidth, 
                    height: modalHeight,
                    title: widget.caseModel.title,
                    content: Text(
                      widget.caseModel.description.isNotEmpty 
                        ? widget.caseModel.description
                        : '이 사건에 대한 상세 내용이 없습니다.',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    pageInfo: '1/1'
                  ),
                  _buildSlidingFolderAnimation(modalWidth, modalHeight),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: modalWidth * 0.05),
            child: _buildVoteButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFile(
      double mHeight, double mWidth, Color color, VoteChoice choice) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      top: _voteChoice == choice ? 0 : mHeight,
      child: Container(
        width: mWidth,
        height: mHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
  
  Widget _buildVoteButtons() {
    return _buildButtons();
  }

  Widget _buildButtons() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isVoting ? null : () => _handleVote(VoteChoice.cons),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3838).withValues(alpha: 0.9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: _isVoting
                  ? _buildButtonAnimation(VoteChoice.cons)
                  : const Text('반대', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isVoting ? null : () => _handleVote(VoteChoice.pros),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3146E6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: _isVoting
                  ? _buildButtonAnimation(VoteChoice.pros)
                  : const Text('찬성', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingFolderAnimation(double modalWidth, double modalHeight) {
    const double folderWidth = 214.0;
    const double folderHeight = 166.0;

    // Determine file color based on vote choice
    Color fileColor;
    if (_voteChoice == VoteChoice.pros) {
      fileColor = const Color(0xFF3146E6);
    } else if (_voteChoice == VoteChoice.cons) {
      fileColor = const Color(0xFFFF3838);
    } else {
      fileColor = Colors.transparent;
    }

    final double folderTopPosition = (modalHeight / 2 - folderHeight / 1.5);
    
    // Show animation when voting is in progress or just completed
    final bool shouldShowAnimation = (_isVoting || _animationCompleted) && _voteChoice != VoteChoice.none;

    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated colored file sliding down
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            top: shouldShowAnimation ? folderTopPosition : -folderHeight,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: shouldShowAnimation ? 1.0 : 0.0,
              child: SizedBox(
                width: folderWidth,
                height: folderHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 23.46,
                      child: Container(
                        width: 190.57,
                        height: 129.73,
                        decoration: ShapeDecoration(
                          color: fileColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.93)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Folder container that appears when vote is in progress
          if (shouldShowAnimation)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              top: folderTopPosition,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: shouldShowAnimation ? 1.0 : 0.0,
                child: SizedBox(
                  width: folderWidth,
                  height: folderHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        top: 32.98,
                        child: Container(
                          width: 214.02,
                          height: 145.13,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF4B2CA4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.86)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
