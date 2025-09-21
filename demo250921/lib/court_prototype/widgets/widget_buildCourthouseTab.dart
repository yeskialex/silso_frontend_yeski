import 'package:flutter/material.dart';
import '../models/court_session_model.dart';
import '../screens/court_main.dart' as court_main;

class CourthouseTabWidget extends StatelessWidget {
  final Stream<List<CourtSessionData>> liveSessionsStream;
  final Function(CourtSessionData) onNavigateToCourtSession;

  const CourthouseTabWidget({
    super.key,
    required this.liveSessionsStream,
    required this.onNavigateToCourtSession,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // No need to recreate streams - they're already real-time
        // Just provide user feedback that refresh happened
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF6037D0),
      backgroundColor: const Color(0xFF1E1E1E),
      child: StreamBuilder<List<CourtSessionData>>(
        stream: liveSessionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6037D0)),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gavel,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '진행 중인 재판이 없습니다',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '사건이 승급되면 여기에 표시됩니다',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          
          final liveSessions = snapshot.data!;
          
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: liveSessions.length,
            itemBuilder: (context, index) => _buildCourthouseCard(liveSessions[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        },
      ),
    );
  }

  Widget _buildCourthouseCard(CourtSessionData session) {
    return GestureDetector(
      onTap: () => onNavigateToCourtSession(session),
      child: Container(
        height: 101,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.asset(
                      "assets/images/community/judge_1.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (session.isLive)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC31A1A),
                          borderRadius: BorderRadius.circular(400),
                        ),
                        child: const Text('Live',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(session.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.25)),
                    Text('참여자 ${session.currentLiveMembers}명',
                        style: const TextStyle(
                            color: Color(0xFFC7C7C7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.25)),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF5F37CF)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(_formatTimeLeft(session.timeLeft),
                          style: const TextStyle(
                              color: Color(0xFF5F37CF),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeLeft(Duration duration) {
    if (duration.inHours > 0) {
      return '판결까지 ${duration.inHours}시간 남음';
    } else if (duration.inMinutes > 0) {
      return '판결까지 ${duration.inMinutes}분 남음';
    } else {
      return '곧 종료';
    }
  }
}
