import 'package:flutter/material.dart';
import 'court_session_model.dart';
import 'ai_conclusion_model.dart';
import '../services/case_service.dart';
import '../widgets/widget_buildDocumentUi.dart';

class VoteResultModal extends StatefulWidget {
  final CourtSessionData courtResult;
  const VoteResultModal({super.key, required this.courtResult});

  @override
  State<VoteResultModal> createState() => _VoteResultModalState();
}

class _VoteResultModalState extends State<VoteResultModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final modalWidth = screenSize.width * 0.9;
    final modalHeight = screenSize.height * 0.65;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: modalWidth,
            height: modalHeight,
            child: PageView(
              controller: _pageController,
              children: [
                _buildResultDocumentPage(modalWidth, modalHeight),
                _buildAiVerdictPage(modalWidth, modalHeight),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildPageIndicators(),
        ],
      ),
    );
  }

  // First page: Shows the case description and vote results
  Widget _buildResultDocumentPage(double modalWidth, double modalHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: buildDocumentUi(
            width: modalWidth,
            height: modalHeight,
            title: widget.courtResult.title,
            content: Text(
              widget.courtResult.description.isNotEmpty 
                ? widget.courtResult.description
                : "이 사건에 대한 상세 내용이 없습니다.",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            pageInfo: '1/2'
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: modalWidth * 0.05),
          child: _buildVoteResultBar(widget.courtResult),
        ),
      ],
    );
  }

  // Second page: AI-generated final verdict using Gemini
  Widget _buildAiVerdictPage(double modalWidth, double modalHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: buildDocumentUi(
            width: modalWidth,
            height: modalHeight,
            title: '🤖 AI 최종 판결문',
            content: FutureBuilder<AiConclusionModel?>(
              future: CaseService().getAiConclusion(widget.courtResult.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF6037D0)),
                      SizedBox(height: 16),
                      Text(
                        "AI가 판결문을 생성하고 있습니다...",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }
                
                if (snapshot.hasError) {
                  return Text(
                    "판결문 생성 중 오류가 발생했습니다: ${snapshot.error}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                
                final aiConclusion = snapshot.data;
                if (aiConclusion == null) {
                  return const Text(
                    "아직 AI 판결문이 생성되지 않았습니다.\n\n법정이 종료된 후 잠시 후에 다시 확인해주세요.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  );
                }
                
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Verdict Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: aiConclusion.finalVerdict == 'GUILTY' 
                              ? const Color(0xFFFF3838) 
                              : const Color(0xFF3146E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${aiConclusion.finalVerdict} (신뢰도: ${aiConclusion.metadata['confidence_score']}%)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // AI Generated Summary
                      Text(
                        aiConclusion.summary,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // AI Model Info
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.psychology, size: 16, color: Color(0xFF6037D0)),
                            const SizedBox(width: 8),
                            Text(
                              '${aiConclusion.metadata['ai_model']} • ${aiConclusion.metadata['processing_time_ms']}ms',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            pageInfo: '2/2'
          ),
        ),
        const SizedBox(height: 64), // Match height of result bar area
      ],
    );
  }

  // Page indicator dots
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  // Vote result bar inspired by court_history.dart
  Widget _buildVoteResultBar(CourtSessionData session) {
    final guiltyVotes = session.guiltyVotes;
    final notGuiltyVotes = session.notGuiltyVotes;
    final totalVotes = guiltyVotes + notGuiltyVotes;
    final guiltyRatio = totalVotes > 0 ? guiltyVotes / totalVotes : 0.5;

    return Column(
      children: [
        Container(
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background (not guilty - blue)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3146E6),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              // Guilty section (red)
              if (totalVotes > 0)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: guiltyRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3838),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              // Vote count labels
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$guiltyVotes',
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
                        ),
                      ),
                      Text(
                        '$notGuiltyVotes',
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text('반대', style: TextStyle(color: Color(0xFFFF3838), fontWeight: FontWeight.bold)),
               Text('찬성', style: TextStyle(color: Color(0xFF3146E6), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

