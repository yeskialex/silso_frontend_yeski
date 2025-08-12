import 'package:flutter/material.dart';
import 'dart:math' as math; // Needed for PI constant
import '../screens/community/community_search_page.dart';
import '../services/court_service.dart';
import 'add_court.dart';


// Card data class... (no changes here)
class _TrialData {
  final String imageUrl;
  final String title;
  final String timeLeft;
  final String participants;
  final bool isLive;

  _TrialData({
    required this.imageUrl,
    required this.title,
    required this.timeLeft,
    required this.participants,
    required this.isLive,
  });
}

/// Main page widget... (no changes here)
class SilsoCourtPage extends StatefulWidget {
  const SilsoCourtPage({super.key});

  @override
  State<SilsoCourtPage> createState() => _SilsoCourtPageState();
}

// Main page state... (no significant changes here, only in helper widgets)
class _SilsoCourtPageState extends State<SilsoCourtPage>
  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentPage = 0;

  final CourtService _courtService = CourtService();
  late Stream<List<CourtSessionData>> _historySessionsStream;

  final List<_TrialData> _trialDataList = [
    _TrialData(
      imageUrl: "assets/images/community/judge_1.png",
      title: '여친이랑 헤어짐; 드루와',
      timeLeft: '판결까지 3시간 남음',
      participants: '현재 참여수 56명',
      isLive: true,
    ),
    _TrialData(
      imageUrl: "assets/images/community/judge_2.png",
      title: '상사한테 꾸중을 들었...',
      timeLeft: '판결까지 9시간 남음',
      participants: '현재 참여수 56명',
      isLive: true,
    ),
    _TrialData(
      imageUrl: "assets/images/community/judge_1.png",
      title: '또 다른 재판 이야기',
      timeLeft: '판결까지 1일 남음',
      participants: '현재 참여수 102명',
      isLive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(viewportFraction: 0.65);
    _historySessionsStream = _courtService.getCompletedCourtSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // The rest of the _SilsoCourtPageState build methods are unchanged...
  // build(), _buildAppBar(), _buildBannerSection(), etc. are the same as before.
  // I'm omitting them here for brevity, but they are in your original file.
  // The key changes are in the VoteModal widget and its helpers.

  @override
  Widget build(BuildContext context) {
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
          _buildLiveTrialsList(screenSize),
          const SizedBox(height: 16),
          _buildPageIndicators(_trialDataList.length),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
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
          _buildCourthouseTab(),
          _buildCasesTab(),
          _buildVerdictZipTab(),
        ],
      ),
    );
  }

  Widget _buildCourthouseTab() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) => _buildCourthouseCard(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildCasesTab() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              title: '✅ 통과된 사건',
              subtitle: '조금있으면 재판이 시작되는 사건들이에요!',
              isDark: true),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => _buildCaseCarouselCard(),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF6B6B6B), thickness: 2),
          const SizedBox(height: 24),
          _buildSectionHeader(
              title: '배심원 투표',
              subtitle: '재판소에 입장하시기 전에, 판결을 위한 투표에 먼저 참여해 주세요!',
              isDark: true),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) => _buildFolderCard(
              folderColor: const Color(0xFF4B2CA4),
              borderColor: const Color(0xFFA38EDC),
              title: '여사친 남사친 있는 것 같음?',
              timeLeft: '투표 종료까지 1시간 남음',
              isCase: true,
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 24),
          )
        ],
      ),
    );
  }

  Widget _buildVerdictZipTab() {
    return StreamBuilder<List<CourtSessionData>>(
      stream: _historySessionsStream,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF6037D0)));
        }

        // Handle error state
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Handle empty or no data state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              '완결된 판결이 없습니다.',
              style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 16),
            ),
          );
        }

        // Handle success state
        final completedSessions = snapshot.data!;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                  title: '완결된 판결',
                  subtitle: '사람들은 어떤 판결을 내렸을까요?',
                  isDark: true),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedSessions.length,
                itemBuilder: (context, index) {
                  final session = completedSessions[index];

                  // Convert verdict from English to Korean
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

                  return _buildFolderCard(
                    folderColor: const Color(0xFF6B6B6B),
                    borderColor: const Color(0xFFFAFAFA),
                    title: session.title, // Use dynamic title
                    verdict: verdictText, // Use dynamic verdict
                    isCase: false,
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
              ),
            ],
          ),
        );
      },
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

  Widget _buildLiveTrialsList(Size screenSize) {
    return SizedBox(
      height: 155,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _trialDataList.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final cardData = _trialDataList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildTrialCard(
              imageUrl: cardData.imageUrl,
              title: cardData.title,
              timeLeft: cardData.timeLeft,
              participants: cardData.participants,
              isLive: cardData.isLive,
              width: screenSize.width,
            ),
          );
        },
      ),
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

  Widget _buildCourthouseCard() {
    return Container(
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
                  const Text('내가 그렇게 잘못함?',
                      style: TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.25)),
                  const Text('참여자 342명',
                      style: TextStyle(
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
                    child: const Text('판결까지 2시간 남음',
                        style: TextStyle(
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
    );
  }

  Widget _buildCaseCarouselCard() {
    return SizedBox(
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
                const Positioned.fill(
                  top: 25,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Center(
                      child: Text(
                        '내가 그렇게 잘못함?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVoteModal(BuildContext context, String title, bool isCase) {
    if (!isCase) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return VoteModal(caseTitle: title);
      },
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

  Widget _buildFolderCard({
    required Color folderColor,
    required Color borderColor,
    required String title,
    String? timeLeft,
    String? verdict,
    required bool isCase,
  }) {
    return InkWell(
      onTap: () => _showVoteModal(context, title, isCase),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 8,
              child: Container(
                width: MediaQuery.of(context).size.width - 245,
                height: 115,
                decoration: BoxDecoration(
                  color: isCase
                      ? const Color(0xFF6037D0).withOpacity(0.4)
                      : const Color.fromARGB(255, 107, 107, 107).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              child: Container(
                width: MediaQuery.of(context).size.width - 48,
                height: 122,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                height: 122,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 15),
                decoration: BoxDecoration(
                  color: folderColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (isCase && timeLeft != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(timeLeft,
                            style: TextStyle(
                                color: borderColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    if (!isCase && verdict != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          // The complex if-else is now a clean function call
                          color: _getVerdictColor(verdict),
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          verdict,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: borderColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum VoteChoice { none, pros, cons }

class VoteModal extends StatefulWidget {
  final String caseTitle;
  const VoteModal({super.key, required this.caseTitle});

  @override
  State<VoteModal> createState() => _VoteModalState();
}

class _VoteModalState extends State<VoteModal> {
  VoteChoice _voteChoice = VoteChoice.none;
  bool _isVoted = false;

  void _handleVote(VoteChoice choice) {
    if (_isVoted) return;
    setState(() {
      _voteChoice = choice;
      _isVoted = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  /// It now uses a Column to place the buttons below the document.
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final modalWidth = screenSize.width * 0.9;
    final modalHeight = screenSize.height * 0.6; // Adjusted for better layout

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // This flexible container holds the document and the animations
          Flexible(
            child: SizedBox(
              width: modalWidth,
              height: modalHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- Animation Layers (Restored) ---
                  _buildAnimatedFile(modalHeight, modalWidth,
                      const Color(0xFFFF3838), VoteChoice.cons),
                  _buildAnimatedFile(modalHeight, modalWidth,
                      const Color(0xFF3146E6), VoteChoice.pros),
                  // --- UI Layer ---
                  _buildDocumentUi(modalWidth, modalHeight),
                      //  Sliding folder animation layer
                  _buildSlidingFolderAnimation(modalWidth, modalHeight),
                ],
              ),
            ),
          ),
          // --- Vote Buttons (Moved outside the document) ---
          const SizedBox(height: 20), // Spacing
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

  ///  Builds the document UI using a Stack for a "pixel layout"
  /// and a ClipPath for the folded corner effect.
  Widget _buildDocumentUi(double width, double height) {
    const double borderWidth = 12.0;
    const double foldSize = 50.0;

    // 테두리 위젯을 생성하는 헬퍼 함수
    Widget buildBorder(Widget child) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // 1. 테두리의 기본 갈색 배경
          Container(color: const Color(0xFF79673F)),
          // 2. 테두리 위에 겹쳐질 어두운 픽셀 패턴
          CustomPaint(
            painter: _PixelPatternPainter(
              dotColor: Colors.black.withOpacity(0.1), // 테두리 패턴은 조금 더 진하게
              step: 3.0, // 테두리 패턴은 조금 더 촘촘하게
            ),
            child: Container(), // CustomPaint가 전체 영역을 차지하도록 함
          ),
          child, // 추가적인 자식 위젯이 있을 경우를 위함 (현재는 사용 안함)
        ],
      );
    }

    return Stack(
      children: [
        // Layer 1: 문서의 기본 배경색
        Container(color: const Color(0xFFF2E3BC)),
        
        // Layer 2: 배경 위에 겹쳐질 옅은 픽셀 패턴
        CustomPaint(
          size: Size(width, height),
          painter: _PixelPatternPainter(
            dotColor: Colors.black.withOpacity(0.05),
          ),
        ),

        // Layer 3: 접힌 코너 효과
        Positioned(
          bottom: 0,
          right: 0,
          width: foldSize,
          height: foldSize,
          child: ClipPath(
            clipper: _FoldedCornerClipper(),
            child: Container(color: const Color(0xFFD4C0A1)), // 접힌 부분의 색
          ),
        ),

        // Layer 4: 픽셀 패턴이 적용된 테두리들
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: SizedBox(width: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          right: 0, top: 0, bottom: 0,
          child: SizedBox(width: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          left: 0, top: 0, right: 0,
          child: SizedBox(height: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          left:  0, bottom: 0, right: 0,
          child: SizedBox(height: borderWidth, child: buildBorder(const SizedBox())),
        ),
        
        // Layer 5: 메인 콘텐츠
        Padding(
          padding: const EdgeInsets.all(borderWidth + 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 15),
              Container(width: double.infinity, height: 1, color: const Color(0xFFE0C898)),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '카페에서 친구들이랑 모이기로 했는데\n먼저 와 있던 두 명이 나란히 앉아서 아이스라떼 마시고 있더라.\n남자는 여사친 빨대 정리해주고, 여자는 남사친 머리에 먼지 떼주고...\n딱 봐도 커플 분위기였는데 정작 본인들은 “10년 된 친구”래.\n\n근데 말이 되냐?\n그렇게 자연스럽게 다정한 사이가 진짜 아무 사이 아니라고?\n\n내 친구랑 나 10년 친구인데\n서로 컵도 안 만짐 ㅋㅋㅋ\n진심 있는 거 같지 않냐 ?',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Spacer for centering title
          const Text('사건', style: TextStyle(color: Color(0xFF5E4E2C), fontSize: 24, fontFamily: 'Pretendard', fontWeight: FontWeight.w700)),
          const Text('1/1', style: TextStyle(color: Color(0xFFA68A54), fontSize: 16, fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  
  Widget _buildVoteButtons() {
    if (_isVoted) {
      return Container(
        height: 44, // Maintain same height as buttons for smooth UI
        alignment: Alignment.center,
        child: Text(
          _voteChoice == VoteChoice.pros ? '찬성 투표 완료' : '반대 투표 완료',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _voteChoice == VoteChoice.pros ? const Color(0xFF3146E6) : const Color(0xFFFF3838),
          ),
        ),
      );
    }
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(child: ElevatedButton(onPressed: () => _handleVote(VoteChoice.cons), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3838).withOpacity(0.9), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 8)), child: const Text('반대', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () => _handleVote(VoteChoice.pros), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3146E6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 8)), child: const Text('찬성', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)))),
        ],
      ),
    );
  }

  /// 고정된 폴더 안으로 파일이 들어가는 애니메이션
  Widget _buildSlidingFolderAnimation(double modalWidth, double modalHeight) {
    const double folderWidth = 214.0;
    const double folderHeight = 166.0;

    // 투표 결과에 따라 파일 색상을 결정합니다.
    Color fileColor;
    if (_voteChoice == VoteChoice.pros) {
      fileColor = const Color(0xFF3146E6); // 찬성은 파란색
    } else if (_voteChoice == VoteChoice.cons) {
      fileColor = const Color(0xFFFF3838); // 반대는 빨간색
    } else {
      fileColor = Colors.transparent; // 투표 전에는 투명
    }

    final double folderTopPosition = (modalHeight / 2 - folderHeight / 1.5);

    return IgnorePointer( // 애니메이션 중 터치 방지
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 움직이는 파일 UI
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            // _isVoted 상태에 따라 화면 밖(-folderHeight)에서 폴더 안(folderTopPosition)으로 이동
            top: _isVoted ? folderTopPosition : -folderHeight,
            child: SizedBox(
              width: folderWidth,
              height: folderHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 색상이 변하는 파일 부분
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

          // 2. 고정된 폴더 UI (항상 중앙에 위치)
          if (_isVoted)
            Positioned(
              top: folderTopPosition,
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
                          color: const Color(0xFF4B2CA4).withOpacity(0.9), // 반투명 폴더
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.86)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),


        ],
      ),
    );
  }
}

///Custom Painter to draw a subtle pixel pattern on the background.
class _PixelPatternPainter extends CustomPainter {
  final Color dotColor;
  final double step;
  _PixelPatternPainter({required this.dotColor, this.step = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FoldedCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

///  An animated folder card widget.
class AnimatedFolderCard extends StatefulWidget {
  final Color folderColor;
  final Color fileColor;
  final String title;
  final bool isCase;
  final VoidCallback onAnimationComplete;

  const AnimatedFolderCard({
    super.key,
    required this.folderColor,
    required this.fileColor,
    required this.title,
    required this.isCase,
    required this.onAnimationComplete,
  });

  @override
  State<AnimatedFolderCard> createState() => _AnimatedFolderCardState();
}

class _AnimatedFolderCardState extends State<AnimatedFolderCard> {
  bool _isTapped = false;

  void _handleTap() {
    // isCase가 아니거나 이미 탭된 상태면 아무것도 하지 않음
    if (!widget.isCase || _isTapped) return;

    setState(() {
      _isTapped = true;
    });

    // 애니메이션이 끝난 후(0.5초 뒤) 모달을 띄우는 콜백 함수를 실행
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onAnimationComplete();
      // 모달이 닫힌 후 다시 탭할 수 있도록 잠시 뒤 상태를 초기화
      Future.delayed(const Duration(milliseconds: 500), () {
        if(mounted) {
          setState(() {
            _isTapped = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 214.0;
    const double cardHeight = 166.0;
    
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 파일 부분: AnimatedPositioned로 위치가 부드럽게 변함
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              // _isTapped 상태에 따라 top 위치가 변경됨
              top: _isTapped ? 23.46 : -85.0, // 시작 위치 -> 끝 위치
              child: Container(
                width: 190.57,
                height: 129.73,
                decoration: ShapeDecoration(
                  color: widget.fileColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.93),
                  ),
                ),
              ),
            ),
            // 고정된 폴더 부분
            Positioned(
              left: 0,
              top: 32.98,
              child: Container(
                width: 214.02,
                height: 145.13,
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5.86),
                      bottomRight: Radius.circular(5.86),
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ]
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: ShapeDecoration(
                          color: widget.folderColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.86),
                          ),
                        ),
                      ),
                    ),
                    // 폴더 안의 제목
                    Positioned(
                      left: 15,
                      top: 25,
                      right: 15,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
}