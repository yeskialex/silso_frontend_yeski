import 'package:flutter/material.dart';
import '../models/court_session_model.dart';

class LiveTrialsListWidget extends StatefulWidget {
  final Stream<List<CourtSessionData>> liveSessionsStream;
  final PageController pageController;
  final Function(CourtSessionData) onNavigateToCourtSession;
  final Function(int) onPageChanged;
  final Size screenSize;

  const LiveTrialsListWidget({
    super.key,
    required this.liveSessionsStream,
    required this.pageController,
    required this.onNavigateToCourtSession,
    required this.onPageChanged,
    required this.screenSize,
  });

  @override
  State<LiveTrialsListWidget> createState() => _LiveTrialsListWidgetState();
}

class _LiveTrialsListWidgetState extends State<LiveTrialsListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CourtSessionData>>(
      stream: widget.liveSessionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 155,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF6037D0)),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 155,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gavel,
                    color: Colors.white.withOpacity(0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '진행 중인 재판이 없습니다',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final liveSessions = snapshot.data!;
        
        return SizedBox(
          height: 155,
          child: PageView.builder(
            controller: widget.pageController,
            itemCount: liveSessions.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              final session = liveSessions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () => widget.onNavigateToCourtSession(session),
                  child: _buildTrialCard(
                    imageUrl: "assets/images/community/judge_${(index % 2) + 1}.png",
                    title: session.title,
                    timeLeft: _formatTimeLeft(session.timeLeft),
                    participants: '현재 참여수 ${session.currentLiveMembers}명',
                    isLive: session.isLive,
                    width: widget.screenSize.width,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrialCard({
    required String imageUrl,
    required String title,
    required String timeLeft,
    required String participants,
    required bool isLive,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 121,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 11,
                  top: 12,
                  child: Text(
                    timeLeft,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
                if (isLive)
                  Positioned(
                    right: 11,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
                Positioned(
                  right: 11,
                  bottom: 12,
                  child: Text(
                    participants,
                    style: const TextStyle(
                      color: Color(0xFFBBBBBB),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFAFAFA),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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