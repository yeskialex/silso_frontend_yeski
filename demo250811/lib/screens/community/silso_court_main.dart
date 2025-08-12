import 'package:flutter/material.dart';
import 'community_search_page.dart';

// 카드 데이터를 관리하기 위한 간단한 클래스 정의
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

/// 메인 페이지 위젯입니다. (StatefulWidget)
class SilsoCourtPage extends StatefulWidget {
  const SilsoCourtPage({super.key});

  @override
  State<SilsoCourtPage> createState() => _SilsoCourtPageState();
}

class _SilsoCourtPageState extends State<SilsoCourtPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentPage = 0;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
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

  /// Part 1: 커스텀 AppBar를 생성하는 함수입니다.
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

  /// Part 2: 실시간 재판소 배너 섹션을 생성하는 함수입니다.
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

  /// Part 3: 탭 바(Tab Bar) 위젯을 생성합니다.
  Widget _buildTabBar() {
    return SizedBox(
      height: 45,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFAFAFA),
        unselectedLabelColor: const Color(0xFF2E2E2E),
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

  /// Part 3: 탭 뷰(TabBarView) 위젯을 생성합니다.
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

  /// Part 3.1: '재판소' 탭의 내용을 생성합니다.
  Widget _buildCourthouseTab() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) => _buildCourthouseCard(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  /// Part 3.2: '사건' 탭의 내용을 생성합니다.
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
          const Divider(color: Color(0xFF2D2D2D), thickness: 2),
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

  /// Part 3.3: '판결ZIP' 탭의 내용을 생성합니다.
  Widget _buildVerdictZipTab() {
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
            itemCount: 5,
            itemBuilder: (context, index) => _buildFolderCard(
              folderColor: const Color(0xFF6B6B6B),
              borderColor: const Color(0xFFFAFAFA),
              title: '빨리 들어와봐. 내기 중임.',
              verdict: '반대',
              isCase: false,
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

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

  /// [REFACTORED] Shows the voting modal pop-up.
  void _showVoteModal(BuildContext context, String title, bool isCase) {
    // Only show the modal for cards in the 'Cases' tab.
    if (!isCase) return;

    showDialog(
      context: context,
      // Use a semi-transparent barrier to dim the background.
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        // Return the new VoteModal widget.
        return VoteModal(caseTitle: title);
      },
    );
  }

  /// [REFACTORED] This card is now interactive.
  Widget _buildFolderCard({
    required Color folderColor,
    required Color borderColor,
    required String title,
    String? timeLeft,
    String? verdict,
    required bool isCase,
  }) {
    return InkWell(
      // Add tap functionality.
      onTap: () => _showVoteModal(context, title, isCase),
      // Set a border radius for the ripple effect to match the card shape.
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
                      : const Color(0xFF393939).withOpacity(0.7),
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
                          color: const Color(0xFFFF3838),
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(verdict,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: borderColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
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

// --- [NEW WIDGET] The Modal for Voting ---

/// An enum to manage the user's voting choice.
enum VoteChoice { none, pros, cons }

/// A stateful widget for the interactive voting modal.
class VoteModal extends StatefulWidget {
  final String caseTitle;

  const VoteModal({super.key, required this.caseTitle});

  @override
  State<VoteModal> createState() => _VoteModalState();
}

class _VoteModalState extends State<VoteModal> {
  VoteChoice _voteChoice = VoteChoice.none;
  bool _isVoted = false;

  /// Handles the voting logic and triggers the animation.
  void _handleVote(VoteChoice choice) {
    if (_isVoted) return; // Prevent voting more than once

    setState(() {
      _voteChoice = choice;
      _isVoted = true;
    });

    // After the animation plays, close the modal automatically.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Make dimensions responsive based on screen width.
    final modalWidth = screenSize.width * 0.85;
    // Maintain a consistent aspect ratio for the height.
    final modalHeight = modalWidth * 1.25;

    return Dialog(
      backgroundColor: Colors.transparent, // Make default background transparent
      insetPadding: const EdgeInsets.all(10),
      child: SizedBox(
        width: modalWidth,
        height: modalHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- Animation Layers ---
            // These are positioned off-screen and slide in when a vote is cast.

            // Red "File" for 'Cons' vote.
            _buildAnimatedFile(
              modalHeight,
              modalWidth,
              const Color(0xFFFF3838), // Red
              VoteChoice.cons,
            ),
            // Blue "File" for 'Pros' vote.
            _buildAnimatedFile(
              modalHeight,
              modalWidth,
              const Color(0xFF3146E6), // Blue
              VoteChoice.pros,
            ),

            // --- UI Layer ---
            // This is the main document UI, placed on top of the animation layers.
            _buildDocumentUi(modalWidth, modalHeight),
          ],
        ),
      ),
    );
  }

  /// Builds the animated container that slides in.
  Widget _buildAnimatedFile(
      double mHeight, double mWidth, Color color, VoteChoice choice) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      // If this choice was selected, move to top: 0. Otherwise, hide it at the bottom.
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

  /// Builds the main content of the modal, styled like a case document.
  Widget _buildDocumentUi(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2E3BC), // Paper background color
        border: Border.all(color: const Color(0xFF79673F), width: 10), // Frame
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.06, vertical: height * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFFE0C898),
          ), // Divider
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
          const SizedBox(height: 20),
          _buildVoteButtons(),
        ],
      ),
    );
  }

  /// Builds the header with the '사건' title.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Spacer for centering title
          const Text(
            '사건',
            style: TextStyle(
              color: Color(0xFF5E4E2C),
              fontSize: 24,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            '1/1',
            style: TextStyle(
              color: Color(0xFFA68A54),
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the voting buttons or a confirmation message after voting.
  Widget _buildVoteButtons() {
    // If user has already voted, show a confirmation message.
    if (_isVoted) {
      return Container(
        height: 44, // Maintain same height as buttons for smooth UI
        alignment: Alignment.center,
        child: Text(
          _voteChoice == VoteChoice.pros ? '찬성 투표 완료' : '반대 투표 완료',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _voteChoice == VoteChoice.pros
                ? const Color(0xFF3146E6)
                : const Color(0xFFFF3838),
          ),
        ),
      );
    }
    // Otherwise, show the voting buttons.
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleVote(VoteChoice.cons),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3838).withOpacity(0.9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('반대',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleVote(VoteChoice.pros),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3146E6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('찬성',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}