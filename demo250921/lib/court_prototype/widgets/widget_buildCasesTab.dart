import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import '../models/silso_court_votemodal.dart';
import 'widget_buildFolderCard.dart';

class CasesTabWidget extends StatelessWidget {
  final Stream<List<CaseModel>> queuedCasesStream;
  final Stream<List<CaseModel>> votingCasesStream;
  final CaseService caseService;
  final Function(CaseModel) onNavigateToCourtSessionFromCase;
  final VoidCallback onNavigateToAddCase;
  final Widget Function({
    required String title,
    String? subtitle,
    bool isDark,
  }) buildSectionHeader;
  final Widget Function({
    required Color folderColor,
    required Color borderColor,
    required String title,
    String? timeLeft,
    String? verdict,
    required bool isCase,
    required VoidCallback onTap,
  }) buildFolderCard;

  const CasesTabWidget({
    super.key,
    required this.queuedCasesStream,
    required this.votingCasesStream,
    required this.caseService,
    required this.onNavigateToCourtSessionFromCase,
    required this.onNavigateToAddCase,
    required this.buildSectionHeader,
    required this.buildFolderCard,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(
              title: '✅ 통과된 사건',
              subtitle: '조금있으면 재판이 시작되는 사건들이에요!',
              isDark: true),
          const SizedBox(height: 16),
          StreamBuilder<List<CaseModel>>(
            stream: queuedCasesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6037D0)),
                  ),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      '승급된 사건이 없습니다',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                );
              }
              
              final promotedCases = snapshot.data!;
              
              return SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: promotedCases.length,
                  itemBuilder: (context, index) => _buildCaseCarouselCard(promotedCases[index]),
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF6B6B6B), thickness: 2),
          const SizedBox(height: 24),
          buildSectionHeader(
              title: '배심원 투표',
              subtitle: '재판소에 입장하시기 전에, 판결을 위한 투표에 먼저 참여해 주세요!',
              isDark: true),
          const SizedBox(height: 16),
          StreamBuilder<List<CaseModel>>(
            stream: votingCasesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6037D0)),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          color: Colors.white.withOpacity(0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '투표 중인 사건이 없습니다',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onNavigateToAddCase,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5F37CF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '사건 제출하기',
                              style: TextStyle(
                                color: Colors.white,
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
                );
              }
              
              final votingCases = snapshot.data!;
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: votingCases.length,
                itemBuilder: (context, index) {
                  final caseModel = votingCases[index];
                  return buildFolderCard(
                    folderColor: const Color(0xFF4B2CA4),
                    borderColor: const Color(0xFFA38EDC),
                    title: caseModel.title,
                    timeLeft: _formatCaseTimeLeft(caseModel),
                    isCase: true,
                    onTap: () => _showVoteModal(context, caseModel.title, true, caseModel),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 24),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCaseCarouselCard(CaseModel caseModel) {
    return GestureDetector(
      onTap: () => onNavigateToCourtSessionFromCase(caseModel),
      child: SizedBox(
        width: 157,
        height: 159,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 148,
              height: 155,
              decoration: BoxDecoration(
                color: const Color(0xFF6037D0).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(
              width: 145,
              height: 145,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 135,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6037D0),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 8,
                    child: Container(
                      width: 129,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 25,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        caseModel.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
    );
  }

  void _showVoteModal(BuildContext context, String title, bool isCase, [CaseModel? caseModel]) {
    if (!isCase || caseModel == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return VoteModal(caseModel: caseModel, caseService: caseService);
      },
    );
  }

  String _formatCaseTimeLeft(CaseModel caseModel) {
    final now = DateTime.now();
    final expiresAt = caseModel.expiresAt;
    if (expiresAt == null) {
      return '시간 정보 없음';
    }
    
    final timeLeft = expiresAt.difference(now);
    
    if (timeLeft.inHours > 0) {
      return '투표 종료까지 ${timeLeft.inHours}시간 남음';
    } else if (timeLeft.inMinutes > 0) {
      return '투표 종료까지 ${timeLeft.inMinutes}분 남음';
    } else {
      return '투표 곧 종료';
    }
  }
}

