import 'package:flutter/material.dart';
import  'community_search_page.dart'; // Import for SilsoCourtPage
/// 메인 페이지 위젯입니다. (StatefulWidget)
class SilsoCourtPage extends StatefulWidget {
  const SilsoCourtPage({super.key});

  @override
  State<SilsoCourtPage> createState() => _SilsoCourtPageState();
}

class _SilsoCourtPageState extends State<SilsoCourtPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러를 초기화합니다. (3개의 탭)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      color: Color(0xFF1E1E1E), // 배너 영역 배경은 흰색
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
        ],
      ),
    );
  }
  
  /// Part 3: 탭 바(Tab Bar) 위젯을 생성합니다.
  Widget _buildTabBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(400),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFFC7C7C7),
        indicator: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(400),
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
    // TabBarView의 높이를 동적으로 조절하기 위해 SizedBox 사용
    // 실제 앱에서는 내용에 따라 높이를 조절해야 합니다.
    return SizedBox(
      height: 1200, // 더미 데이터에 맞춘 임시 높이
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // 탭뷰 자체 스크롤 비활성화
        children: [
          _buildCourthouseTab(), // 재판소 탭
          _buildCasesTab(),       // 사건 탭
          _buildVerdictZipTab(),  // 판결ZIP 탭
        ],
      ),
    );
  }

  /// Part 3.1: '재판소' 탭의 내용을 생성합니다.
  Widget _buildCourthouseTab() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5, // 더미 데이터 개수
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
          // 가로 스크롤 카드 리스트
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // 더미 데이터 개수
              itemBuilder: (context, index) => _buildCaseCarouselCard(),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2D2D2D), thickness: 2),
          const SizedBox(height: 24),
          _buildSectionHeader(title: '최신 사건', subtitle: '따끈따끈한 사건이 왔어요', isDark: true),
          const SizedBox(height: 16),
          // 세로 스크롤 카드 리스트
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4, // 더미 데이터 개수
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
            itemCount: 5, // 더미 데이터 개수
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

  /// 각 섹션의 헤더(제목, 부제목)를 생성하는 함수입니다.
  Widget _buildSectionHeader({required String title, String? subtitle, bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color:  const Color(0xFFFAFAFA),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color(0xFFC7C7C7) ,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// '실시간 재판소'의 가로 스크롤 리스트를 생성하는 함수입니다.
  Widget _buildLiveTrialsList(Size screenSize) {
    final cardWidth = screenSize.width * 0.55;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTrialCard(
            imageUrl: "assets/images/community/judge_1.png",
            title: '여친이랑 헤어짐; 드루와',
            timeLeft: '판결까지 3시간 남음',
            participants: '현재 참여수 56명',
            isLive: true,
            width: cardWidth,
          ),
          const SizedBox(width: 8),
          _buildTrialCard(
            imageUrl: "assets/images/community/judge_2.png",
            title: '상사한테 꾸중을 들었...',
            timeLeft: '판결까지 9시간 남음',
            participants: '현재 참여수 56명',
            isLive: true,
            width: cardWidth,
          ),
          const SizedBox(width: 8),
          _buildTrialCard(
            imageUrl: "assets/images/community/judge_1.png",
            title: '또 다른 재판 이야기',
            timeLeft: '판결까지 1일 남음',
            participants: '현재 참여수 102명',
            isLive: false,
            width: cardWidth,
          ),
        ],
      ),
    );
  }

  /// '실시간 재판소' 카드를 생성하는 함수입니다.
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

  /// '재판소' 탭의 카드 위젯을 생성합니다.
  Widget _buildCourthouseCard() {
    return Container(
      height: 101,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  "https://placehold.co/153x101/777777/FFFFFF?text=Image",
                  width: 80,
                  height: 101,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('내가 그렇게 잘못함?', style: TextStyle(color: Color(0xFFFAFAFA), fontSize: 13, fontWeight: FontWeight.w600, height: 1.25)),
                  const Text('참여자 342명', style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 8, fontWeight: FontWeight.w600, height: 1.25)),
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
  
  /// '사건' 탭의 가로 스크롤 카드(Carousel Card)를 생성합니다.
  Widget _buildCaseCarouselCard() {
    return SizedBox(
      width: 157,
      height: 159,
      child: Stack(
        children: [
          // Folder Body
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 147,
              decoration: const BoxDecoration(
                color: Color(0xFF5F37CF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          // Folder Tab
          Positioned(
            top: 0,
            left: 8,
            child: Container(
              width: 50,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF3B2283),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          // Content
          const Positioned.fill(
            top: 30,
            child: Padding(
              padding: EdgeInsets.all(12.0),
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
    );
  }

  /// '사건'과 '판결ZIP' 탭에서 사용하는 공용 폴더 카드 위젯입니다.
  Widget _buildFolderCard({
    required Color folderColor,
    required Color borderColor,
    required String title,
    String? timeLeft,
    String? verdict,
    required bool isCase,
  }) {
    return SizedBox(
      height: 160,
      child: Stack(
        //alignment: Alignment.,
        children: [
          // 뒷 배경 종이
          Positioned(
            top: 0,
            left: 8,
            child: Container(
              width: MediaQuery.of(context).size.width - 245,
              height: 115,
              decoration: BoxDecoration(
                color: isCase ? const Color(0xFFFAFAFA).withOpacity(0.1) : const Color(0xFF393939).withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // 메인 폴더
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width - 32, // 화면 너비에 맞게 조절
              height: 122,
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
                  if (isCase && timeLeft != null) // '사건' 탭용 위젯
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(timeLeft, style: TextStyle(color: borderColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  if (!isCase && verdict != null) // '판결ZIP' 탭용 위젯
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