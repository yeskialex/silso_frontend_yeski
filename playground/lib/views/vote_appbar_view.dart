import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vote_model.dart';

// Vote AppBar 메인 위젯
class VoteAppBarView extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const VoteAppBarView({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120.0); // AppBar + Vote bar 높이

  @override
  Widget build(BuildContext context) {
    return Consumer<VoteModel>(
      builder: (context, voteModel, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF3F3329),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 기본 AppBar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // 뒤로가기 버튼
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                      ),
                      // 제목
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // 우측 여백 (뒤로가기 버튼과 균형)
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // 투표 바
                VoteBarWidget(voteModel: voteModel),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 투표 바 위젯
class VoteBarWidget extends StatelessWidget {
  final VoteModel voteModel;

  const VoteBarWidget({
    super.key,
    required this.voteModel,
  });

  @override
  Widget build(BuildContext context) {
    final agreeRatio = voteModel.agreeRatio;
    final disagreeRatio = 1.0 - agreeRatio;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 찬성 버튼
          Expanded(
            child: GestureDetector(
              onTap: () => voteModel.addVote(true),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 투표 비율 바
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.5 * agreeRatio,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF66BB6A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // 텍스트
                    Center(
                      child: Text(
                        '찬성 ${voteModel.agreeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 반대 버튼
          Expanded(
            child: GestureDetector(
              onTap: () => voteModel.addVote(false),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 투표 비율 바
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.5 * disagreeRatio,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // 텍스트
                    Center(
                      child: Text(
                        '반대 ${voteModel.disagreeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

// 투표 결과 요약 위젯 (선택적)
class VoteSummaryWidget extends StatelessWidget {
  final VoteModel voteModel;

  const VoteSummaryWidget({
    super.key,
    required this.voteModel,
  });

  @override
  Widget build(BuildContext context) {
    final totalVotes = voteModel.agreeCount + voteModel.disagreeCount;
    final agreePercentage = (voteModel.agreeRatio * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 투표수: $totalVotes',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            '찬성률: $agreePercentage%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: agreePercentage >= 50 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFFF44336),
            ),
          ),
        ],
      ),
    );
  }
}