import 'package:flutter/material.dart';
import  'community_search_page.dart';

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

class _SilsoCourtPageState extends State<SilsoCourtPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // [수정] PageView를 위한 컨트롤러와 현재 페이지 인덱스 변수 추가
  late PageController _pageController;
  int _currentPage = 0;

  // [수정] 카드 데이터를 리스트로 관리
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
    // [수정] PageController 초기화, viewportFraction으로 옆 카드 살짝 보이게 설정
    _pageController = PageController(viewportFraction: 0.65);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose(); // [수정] pageController 메모리 해제
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
            // Part 2: 상단 배너 섹션 (흰색 배경)
            _buildBannerSection(screenSize),

            // Part 3: 탭 메뉴와 탭 콘텐츠 섹션
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
            // 뒤로가기 아이콘
            IconButton(
              padding: EdgeInsets.zero, // IconButton의 기본 패딩 제거
              constraints: const BoxConstraints(), // 아이콘 버튼의 최소 크기 제약 제거
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
              onPressed: () {
                // 현재 화면을 닫고 이전 화면(community_main.dart)으로 돌아갑니다.
                Navigator.of(context).pop();
              },
            ),            // 로고와 페이지 제목
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
            // 검색 아이콘
              IconButton(
              padding: EdgeInsets.zero, // IconButton의 기본 패딩 제거
              constraints: const BoxConstraints(), // 아이콘 버튼의 최소 크기 제약 제거
              icon: const Icon(Icons.search, color: Colors.white, size: 24),
              onPressed: () {
                // 현재 화면을 닫고 이전 화면(community_main.dart)으로 돌아갑니다.
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ExploreSearchPage()),
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
      color: const Color(0xFF1E1E1E), // 배너 영역 배경은 흰색
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
          // [수정] 페이지 인디케이터 추가
          _buildPageIndicators(_trialDataList.length),
        ],
      ),
    );
  }

  /// [추가] 페이지 인디케이터 위젯
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
            color: _currentPage == index ? Color(0xFF6037D0) : Color(0xFF301D67),
          ),
        );
      }),
    );
  }

  /// Part 3: 탭 바(Tab Bar) 위젯을 생성합니다.
  /// [수정] 기존 '재판소', '사건', '판결ZIP' 탭 바의 스타일을 변경합니다.
  Widget _buildTabBar() {
    return SizedBox(
      height: 45,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFAFAFA), // 활성 탭 색상
        unselectedLabelColor: const Color(0xFF2E2E2E), // 비활성 탭 색상
        // [수정] 인디케이터를 밑줄 스타일로 변경
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xFFFAFAFA), // 밑줄 색상
            width: 3.0, // 밑줄 두께
          ),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Pretendard',
        ),
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
          _buildSectionHeader(title: '🔥 HOT한 사건', subtitle: '요즘 뜨는 사건은?', isDark: true),
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
          _buildSectionHeader(title: '최신 사건', subtitle: '따끈따끈한 사건이 왔어요', isDark: true),
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
          _buildSectionHeader(title: '완결된 판결', subtitle: '사람들은 어떤 판결을 내렸을까요?', isDark: true),
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

  Widget _buildSectionHeader({required String title, String? subtitle, bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color:  Color(0xFFFAFAFA),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFC7C7C7) ,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// '실시간 재판소'의 가로 스크롤 리스트를 생성하는 함수입니다.
  /// [수정] SingleChildScrollView -> PageView
  Widget _buildLiveTrialsList(Size screenSize) {
    return SizedBox(
      height: 155, // 카드(121) + 제목(16) + 여백 등 고려한 높이
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
          // PageView 아이템 간 간격을 주기 위해 Padding 사용
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildTrialCard(
              imageUrl: cardData.imageUrl,
              title: cardData.title,
              timeLeft: cardData.timeLeft,
              participants: cardData.participants,
              isLive: cardData.isLive,
              width: screenSize.width, // 너비는 PageView가 제어하므로 최대값으로 설정
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC31A1A),
                        borderRadius: BorderRadius.circular(400),
                      ),
                      child: const Text('Live', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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
          // [수정] 이미지가 1/3을 차지하도록 Expanded와 flex: 1 적용
          Expanded(
            flex: 1,
            child: Stack(
              // [수정] Stack의 자식이 Expanded 공간을 꽉 채우도록 설정
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.asset(
                    "assets/images/community/judge_1.png",
                    // [수정] fit: BoxFit.cover를 통해 이미지가 잘리지 않고 채워지도록 함
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC31A1A),
                      borderRadius: BorderRadius.circular(400),
                    ),
                    child: const Text('Live', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          // [수정] 텍스트 영역이 2/3를 차지하도록 flex: 2 적용
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('내가 그렇게 잘못함?', style: TextStyle(color: Color(0xFFFAFAFA), fontSize: 14, fontWeight: FontWeight.w600, height: 1.25)),
                  const Text('참여자 342명', style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 10, fontWeight: FontWeight.w600, height: 1.25)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF5F37CF)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('판결까지 2시간 남음', style: TextStyle(color: Color(0xFF5F37CF), fontSize: 10, fontWeight: FontWeight.w600, height: 1.5)),
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
          // [추가] 가장 뒤에 깔리는 연한 보라색 종이 효과
          Container(
            width: 148,
            height: 155,
            decoration: BoxDecoration(
              color: const Color(0xFF6037D0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // [추가] 중간에 끼워진 흰색 종이 효과
          // Container(
          //   width: 120,
          //   height: 120,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(8),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.05),
          //         spreadRadius: 1,
          //         blurRadius: 4,
          //         offset: const Offset(2, 2),
          //       )
          //     ],
          //   ),
          // ),
          // 기존 보라색 폴더 UI (가장 위에 위치)
          SizedBox(
            width: 145,
            height: 145,
            child: Stack(
              children: [
                // 폴더 몸체
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
                // 폴더 탭
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
                // 텍스트 콘텐츠
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
 Widget _buildFolderCard({
    required Color folderColor,
    required Color borderColor,
    required String title,
    String? timeLeft,
    String? verdict,
    required bool isCase,
  }) {
    return SizedBox(
      height: 140,
      child: Stack(
        // [수정] 자식 위젯들을 중앙 정렬합니다.
        alignment: Alignment.center,
        children: [
          // 폴더의 뒷부분(탭)처럼 보이는 레이어
          Positioned(
            top: 0,
            left: 8,
            child: Container(
              width: MediaQuery.of(context).size.width - 245,
              height: 115,
              decoration: BoxDecoration(
                color: isCase ? const Color(0xFF6037D0).withOpacity(0.4) : const Color(0xFF393939).withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // [수정] 폴더에 끼워진 흰색 종이 부분
          Positioned(
            bottom: 5, // 메인 폴더보다 5px 위에 위치하여 살짝 보이게 함
            child: Container(
              width: MediaQuery.of(context).size.width - 48, // 메인 폴더보다 약간 좁게
              height: 122,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),

          // 메인 폴더 (가장 앞 레이어)
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              height: 122, // [수정] UI 균형을 위해 높이 원복
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 15),
              decoration: BoxDecoration(
                color: folderColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (isCase && timeLeft != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(timeLeft, style: TextStyle(color: borderColor, fontSize: 12, fontWeight: FontWeight.w600)),
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
                      child: Text(verdict, textAlign: TextAlign.center, style: TextStyle(color: borderColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}