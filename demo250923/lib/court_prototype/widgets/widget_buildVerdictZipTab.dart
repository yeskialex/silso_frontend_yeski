import 'package:flutter/material.dart';
import '../models/court_session_model.dart';
import '../models/silso_court_voteResult.dart';

class VerdictZipTabWidget extends StatelessWidget {
  final Stream<List<CourtSessionData>> historySessionsStream;
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

  const VerdictZipTabWidget({
    super.key,
    required this.historySessionsStream,
    required this.buildSectionHeader,
    required this.buildFolderCard,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CourtSessionData>>(
      stream: historySessionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF6037D0)));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              '완결된 판결이 없습니다.',
              style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 16),
            ),
          );
        }

        final completedSessions = snapshot.data!;

 return ListView.separated(
                shrinkWrap: true,
                physics: const  AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: completedSessions.length+1,
                itemBuilder: (context, index) {
                  index -= 1;
                  if(index == -1){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: buildSectionHeader(
                            title: '완결된 판결',
                            subtitle: '완결된 판결 내역을 확인해보세요.',
                            isDark: false,
                          ),
                       ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  final session = completedSessions[index];

                  String verdictText;
                  switch (session.resultWin) {
                    case 'guilty':
                      verdictText = '반대';
                      break;
                    case 'not_guilty':
                      verdictText = '찬성';
                      break;
                    case 'tie':
                      verdictText = '무승부';
                      break;
                    default:
                      verdictText = '결과 없음';
                  }

                  return buildFolderCard(
                    folderColor: const Color(0xFF6B6B6B),
                    borderColor: const Color(0xFFFAFAFA),
                    title: session.title,
                    verdict: verdictText,
                    isCase: false,
                    onTap: () => _showResultModal(context, session, false),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
              );
            },
          );
        }

  void _showResultModal(BuildContext context, CourtSessionData courtResult, bool isCase) {
    if (isCase) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return VoteResultModal(courtResult: courtResult);
      },
    );
  }
}