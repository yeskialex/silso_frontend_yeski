import 'package:flutter/material.dart';
import 'dart:math' as math; // for PageController rotation

// --- 데이터 모델 ---
// 각 커뮤니티 정보를 담기 위한 간단한 데이터 클래스입니다.
class CommunityInfo {
  final int rank;
  final String title;
  final String description;
  final String imageUrl;
  final String memberCount;

  CommunityInfo({
    required this.rank,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.memberCount,
  });
}

class CommunityExplorePage extends StatefulWidget {
  const CommunityExplorePage({super.key});

  @override
  State<CommunityExplorePage> createState() => _CommunityExplorePageState();
}

class _CommunityExplorePageState extends State<CommunityExplorePage> {
  // --- 상태 변수 ---
  int _carouselCurrentPage = 0; // 배너 캐러셀의 현재 페이지 인덱스
  String _activeFilter = '인기순'; // 현재 선택된 필터
  final PageController _pageController = PageController(
    viewportFraction: 0.91, // 화면 너비의 91% 만큼 각 페이지가 보이도록 설정
  );

  // --- Mock 데이터 ---
  // 실제 앱에서는 서버에서 이 데이터를 가져와야 합니다.
  final List<CommunityInfo> topCommunities = [
    CommunityInfo(rank: 1, title: '대학교 빌런이 되지말자', description: '대학교에서 팀플 많은 사람들 모여라! 팀플 꿀팁 대방출', imageUrl: 'https://placehold.co/159x217', memberCount: '9,909'),
    CommunityInfo(rank: 2, title: '스타트업 시작하는 사람들의 모임', description: '스타트업을 시작하며 겪었던 여러 실패들을 서로 공유하는 공간', imageUrl: 'https://placehold.co/159x217', memberCount: '8,513'),
    CommunityInfo(rank: 3, title: '엄빠가 처음이라', description: '육아에서 시행착오를 겪은 부모들이 진솔한 경험담을 나누는 공간', imageUrl: 'https://placehold.co/159x217', memberCount: '8,112'),
    CommunityInfo(rank: 4, title: '연애는 어렵조', description: '연애에서의 크고 작은 실패 경험을 나누며 위로와 조언을 주고받는 커뮤니티', imageUrl: 'https://placehold.co/159x217', memberCount: '6,953'),
    CommunityInfo(rank: 5, title: '퇴사를 두려워 하지맙세', description: '퇴사가 아직 두려우신가요?\n퇴사를 두려워하지 맙시다!', imageUrl: 'https://placehold.co/159x217', memberCount: '6,478'),
  ];
  
  final List<Map<String, String>> communityList = [
    {'title': '인기가 필요한 사람들', 'description': '인기가 필요한 사람들', 'members': '300'},
    {'title': '이성과의 교류가 힘든 사람들의 모임', 'description': '이성과 대화하기 힘든 사람들에게 꿀팁을!', 'members': '300'},
    {'title': '건강관리에 진심인 사람 모이자', 'description': '운동, 영양제, 이너관리에 대한 모든걸 공유', 'members': '300'},
  ];

  @override
  Widget build(BuildContext context) {
    // --- 화면 크기 및 비율 계산 ---
    final screenSize = MediaQuery.of(context).size;
    final double scale = screenSize.width / 393.0; // 기준 너비 393px에 대한 비율

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(scale),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 18 * scale),
            _buildTopCommunityCarousel(scale),
            SizedBox(height: 12 * scale),
            _buildCarouselIndicator(scale),
            SizedBox(height: 30 * scale),
            const Divider(color: Color(0xFFF4F4F4), thickness: 1.5, height: 1.5),
            SizedBox(height: 24 * scale),
            _buildFilterButtons(scale),
            SizedBox(height: 24 * scale),
            _buildCommunityList(scale),
          ],
        ),
      ),
    );
  }

  /// ## 상단 앱바 위젯
  PreferredSizeWidget _buildAppBar(double scale) {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 24 * scale),
        onPressed: () {
          // TODO: 뒤로가기 로직 구현
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/community/logo.png", width: 69, height: 25),
          SizedBox(width: 10 * scale),
          Text(
            '커뮤니티',
            style: TextStyle(
              color: const Color(0xFF5F37CF),
              fontSize: 22 * scale,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      centerTitle: false, // 왼쪽 정렬 위함. 
      titleSpacing: 0, // 왼쪽 정렬 위함. 
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.black, size: 28 * scale),
          onPressed: () {
            // TODO: 검색 로직 구현
          },
        ),
        SizedBox(width: 8 * scale),
      ],
    );
  }

  /// ## 상단 TOP 5 커뮤니티 배너 캐러셀
  Widget _buildTopCommunityCarousel(double scale) {
    return SizedBox(
      height: 212 * scale,
      child: PageView.builder(
        controller: _pageController,
        itemCount: topCommunities.length,
        onPageChanged: (index) {
          setState(() {
            _carouselCurrentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return _TopCommunityCard(
            info: topCommunities[index],
            scale: scale,
          );
        },
      ),
    );
  }

  /// ## 캐러셀 인디케이터 (페이지 표시 점)
  Widget _buildCarouselIndicator(double scale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(topCommunities.length, (index) {
        return Container(
          width: 6 * scale,
          height: 6 * scale,
          margin: EdgeInsets.symmetric(horizontal: 4.5 * scale),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _carouselCurrentPage == index
                ? const Color(0xFF5F37CF)
                : const Color(0xFFDFD4FF),
          ),
        );
      }),
    );
  }

  /// ## 정렬 필터 버튼 (인기순, 최신순, 오래된순)
  Widget _buildFilterButtons(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0 * scale),
      child: Row(
        children: ['인기순', '최신순', '오래된순'].map((filter) {
          bool isActive = _activeFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 5 * scale),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeFilter = filter;
                  // TODO: 필터에 따른 데이터 정렬 로직 구현
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF5F37CF) : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(400),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFFBBBBBB),
                    fontSize: 14 * scale,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ## 전체 커뮤니티 목록
  Widget _buildCommunityList(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17 * scale),
      child: ListView.separated(
        shrinkWrap: true, // SingleChildScrollView 안에서 스크롤이 가능하도록 설정
        physics: const NeverScrollableScrollPhysics(), // 부모 스크롤과 충돌 방지
        itemCount: communityList.length,
        itemBuilder: (context, index) {
          return _CommunityListItem(
            title: communityList[index]['title']!,
            description: communityList[index]['description']!,
            memberCount: communityList[index]['members']!,
            scale: scale,
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 6 * scale),
      ),
    );
  }
}

/// ## [컴포넌트] 상단 캐러셀에 들어갈 카드 위젯
/// ## [컴포넌트] 상단 캐러셀에 들어갈 카드 위젯 (Overflow 해결)
class _TopCommunityCard extends StatelessWidget {
  final CommunityInfo info;
  final double scale;

  const _TopCommunityCard({required this.info, required this.scale});

  @override
  Widget build(BuildContext context) {
    // PageView의 높이와 일치시키기 위해 카드 전체 높이를 명시적으로 지정합니다.
    return Container(
      height: 212 * scale,
      margin: EdgeInsets.symmetric(horizontal: 4 * scale), // 카드 간 간격
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 왼쪽 이미지
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12 * scale),
              bottomLeft: Radius.circular(12 * scale),
            ),
            child: Image.network(
              info.imageUrl,
              width: 159 * scale,
              // ⚠️ [수정 1] 이미지 높이를 부모 컨테이너 높이에 맞춥니다.
              height: 212 * scale,
              fit: BoxFit.cover,
            ),
          ),
          // 오른쪽 텍스트 정보
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                18.0 * scale, 18.0 * scale, 18.0 * scale, 12.0 * scale // 하단 패딩 약간 조정
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 랭킹 배지
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5F37CF),
                      borderRadius: BorderRadius.circular(400),
                    ),
                    child: Text(
                      '${info.rank}위',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scale,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * scale),
                  // 커뮤니티 제목
                  Text(
                    info.title,
                    style: TextStyle(
                      color: const Color(0xFF121212),
                      fontSize: 18 * scale,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8 * scale),
                  
                  // ⚠️ [수정 2] Spacer 대신 Flexible 위젯 사용
                  // Flexible 위젯이 남은 공간을 모두 차지하여 설명 텍스트가 유연하게 표시됩니다.
                  Flexible(
                    child: Text(
                      info.description,
                      style: TextStyle(
                        color: const Color(0xFF8E8E8E),
                        fontSize: 14 * scale,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Spacer를 제거했으므로 하단 여백을 위해 SizedBox 추가
                  SizedBox(height: 8 * scale),

                  // 멤버 수
                  Row(
                    children: [
                      Icon(Icons.person, color: const Color(0xFF5F37CF), size: 14 * scale),
                      SizedBox(width: 4 * scale),
                      Text(
                        '${info.memberCount}명',
                        style: TextStyle(
                          color: const Color(0xFF5F37CF),
                          fontSize: 12 * scale,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

/// ## [컴포넌트] 하단 리스트에 들어갈 아이템 위젯
class _CommunityListItem extends StatelessWidget {
  final String title;
  final String description;
  final String memberCount;
  final double scale;

  const _CommunityListItem({
    required this.title,
    required this.description,
    required this.memberCount,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          // 왼쪽 텍스트 정보
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 15 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF121212),
                      fontSize: 16 * scale,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const Spacer(),
                  Text(
                    description,
                    style: TextStyle(
                      color: const Color(0xFF8E8E8E),
                      fontSize: 14 * scale,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          // 오른쪽 아이콘 및 멤버 수
          Container(
            width: 90 * scale,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF5F37CF),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(7 * scale),
                bottomRight: Radius.circular(7 * scale),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, color: Colors.white, size: 30 * scale),
                SizedBox(height: 8 * scale),
                Container(
                   padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(400),
                       border: Border.all(color: Colors.white, width: 1)
                   ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.person, color: Colors.white, size: 14 * scale),
                       SizedBox(width: 4 * scale),
                       Text(
                         '$memberCount명',
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 12 * scale,
                           fontFamily: 'Pretendard',
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ],
                   ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}