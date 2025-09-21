import 'package:flutter/material.dart';
import 'dart:async';
import '../../screens/community/community_search_page.dart';
import 'services/court_service.dart';
import 'services/case_service.dart';
import 'models/case_model.dart';
import 'models/court_session_model.dart';
import 'screens/add_case_screen.dart';
import 'screens/court_main.dart' as court_main;
import 'config/court_config.dart';

// Import main widget files
import 'widgets/widget_buildCasesTab.dart';
import 'widgets/widget_buildCourthouseTab.dart';
import 'widgets/widget_buildFolderCard.dart';
import 'widgets/widget_buildLivetrial.dart';
import 'widgets/widget_buildVerdictZipTab.dart';


// Removed unused _TrialData class since we now use real data

/// Main page widget... (no changes here)
class SilsoCourtPage extends StatefulWidget {
  const SilsoCourtPage({super.key});

  @override
  State<SilsoCourtPage> createState() => _SilsoCourtPageState();
}

// Main page state... (no significant changes here, only in helper widgets)
class _SilsoCourtPageState extends State<SilsoCourtPage>
  with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentPage = 0;

  final CourtService _courtService = CourtService();
  final CaseService _caseService = CaseService();
  
  // Use cached streams to prevent recreation and improve performance
  Stream<List<CourtSessionData>>? _historySessionsStream;
  Stream<List<CourtSessionData>>? _liveSessionsStream;
  Stream<List<CaseModel>>? _queuedCasesStream;
  Stream<List<CaseModel>>? _votingCasesStream;

  // Lazy getters for streams to ensure they're only created once
  Stream<List<CourtSessionData>> get historySessionsStream {
    return _historySessionsStream ??= _courtService.getCompletedCourtSessions();
  }

  Stream<List<CourtSessionData>> get liveSessionsStream {
    return _liveSessionsStream ??= _courtService.getLiveCourtSessions();
  }

  Stream<List<CaseModel>> get queuedCasesStream {
    return _queuedCasesStream ??= _caseService.getQueuedCases();
  }

  Stream<List<CaseModel>> get votingCasesStream {
    return _votingCasesStream ??= _caseService.getActiveVotingCases();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(viewportFraction: 0.65);
    
    // Streams are now lazy-loaded when needed, improving initial load time
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black, // Added for consistent background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBannerSection(screenSize),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 24),
                  _buildTabBarView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCase(),
        backgroundColor: const Color(0xFF5F37CF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          '사건 제출',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
        elevation: 8,
        heroTag: "submit_case_fab",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Column(
              children: [
                Image.asset(
                  "assets/images/community/silso_court.png",
                  width: 70,
                  height: 25,
                ),
                const SizedBox(height: 5),
                const Text(
                  '실시간 재판소',
                  style: TextStyle(
                    color: Color(0xFFC7C7C7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.search, color: Colors.white, size: 24),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ExploreSearchPage()),
                );
              },
            ),
          ],
        ),
      ),
      toolbarHeight: 90,
    );
  }

  Widget _buildBannerSection(Size screenSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader(
              title: '실시간 재판소',
              subtitle: 'TOP 3 판결을 확인해 보세요',
            ),
          ),
          const SizedBox(height: 16),
          LiveTrialsListWidget(
            liveSessionsStream: liveSessionsStream,
            pageController: _pageController,
            onNavigateToCourtSession: _navigateToCourtSession,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            screenSize: screenSize,
          ),
          const SizedBox(height: 16),
          _buildPageIndicators(),  // Remove hardcoded length
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return StreamBuilder<List<CourtSessionData>>(
      stream: liveSessionsStream,
      builder: (context, snapshot) {
        final sessionCount = snapshot.hasData ? snapshot.data!.length : 0;
        if (sessionCount == 0) return const SizedBox.shrink();
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(sessionCount, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF6037D0)
                    : const Color(0xFF301D67),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 45,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFAFAFA),
        unselectedLabelColor: const Color(0xFF6B6B6B),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFFFAFAFA), width: 3.0),
        ),
        labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard'),
        unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard'),
        tabs: const [
          Tab(text: '재판소'),
          Tab(text: '사건'),
          Tab(text: '판결ZIP'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 1200,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Wrap each tab in KeepAlive to maintain state when switching tabs
          _KeepAliveWrapper(
            child: CourthouseTabWidget(
              liveSessionsStream: liveSessionsStream,
              onNavigateToCourtSession: _navigateToCourtSession,
            ),
          ),
          _KeepAliveWrapper(
            child: CasesTabWidget(
              queuedCasesStream: queuedCasesStream,
              votingCasesStream: votingCasesStream,
              caseService: _caseService,
              onNavigateToCourtSessionFromCase: _navigateToCourtSessionFromCase,
              onNavigateToAddCase: _navigateToAddCase,
              buildSectionHeader: _buildSectionHeader,
              buildFolderCard: ({
                required Color folderColor,
                required Color borderColor,
                required String title,
                String? timeLeft,
                String? verdict,
                required bool isCase,
                required VoidCallback onTap,
              }) => FolderCardWidget(
                folderColor: folderColor,
                borderColor: borderColor,
                title: title,
                timeLeft: timeLeft,
                verdict: verdict,
                isCase: isCase,
                onTap: onTap,
              ),
            ),
          ),
          _KeepAliveWrapper(
            child: VerdictZipTabWidget(
              historySessionsStream: historySessionsStream,
              buildSectionHeader: _buildSectionHeader,
              buildFolderCard: ({
                required Color folderColor,
                required Color borderColor,
                required String title,
                String? timeLeft,
                String? verdict,
                required bool isCase,
                required VoidCallback onTap,
              }) => FolderCardWidget(
                folderColor: folderColor,
                borderColor: borderColor,
                title: title,
                timeLeft: timeLeft,
                verdict: verdict,
                isCase: isCase,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, String? subtitle, bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFAFAFA),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFC7C7C7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Color _getVerdictColor(String? verdict) {
    switch (verdict) {
      case '반대':
        return const Color(0xFFFF3838); // Red for "Cons"
      case '찬성':
        return const Color(0xFF3146E6); // Blue for "Pros"
      default:
        return const Color(0xFFC7C7C7); // Gray for "Tie" or other cases
    }
  }

  void _navigateToCourtSession(CourtSessionData session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => court_main.CourtPrototypeScreen(courtSession: session),
      ),
    );
  }

  // Navigate to court session from case model
  void _navigateToCourtSessionFromCase(CaseModel caseModel) {
    if (caseModel.courtSessionId != null) {
      // Find the court session and navigate
      _courtService.getCourtSession(caseModel.courtSessionId!).then((session) {
        if (session != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => court_main.CourtPrototypeScreen(courtSession: session),
            ),
          );
        }
      }).catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('법정 세션을 찾을 수 없습니다: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  // Navigate to add case screen
  void _navigateToAddCase() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddCaseScreen(),
      ),
    );
  }

  // Format time left for display
  String _formatTimeLeft(Duration duration) {
    if (duration.inHours > 0) {
      return '판결까지 ${duration.inHours}시간 남음';
    } else if (duration.inMinutes > 0) {
      return '판결까지 ${duration.inMinutes}분 남음';
    } else {
      return '곧 종료';
    }
  }

  // Format case time left
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

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  
  const _KeepAliveWrapper({required this.child});
  
  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
 