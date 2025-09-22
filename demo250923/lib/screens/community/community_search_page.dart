import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/community_service.dart';
import '../../services/search_analytics_service.dart';
import '../../services/blocking_integration_service.dart';
import '../../models/community_model.dart';
import '../../models/search_analytics_model.dart';
import 'community_detail_page.dart';
import '../../widgets/blocking_utils.dart';

class ExploreSearchPage extends StatefulWidget {
  const ExploreSearchPage({super.key});

  @override
  State<ExploreSearchPage> createState() => _ExploreSearchPageState();
}

class _ExploreSearchPageState extends State<ExploreSearchPage> {
  final CommunityService _communityService = CommunityService();
  final SearchAnalyticsService _searchAnalyticsService = SearchAnalyticsService();
  final BlockingIntegrationService _blockingService = BlockingIntegrationService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Community> _allCommunities = [];
  List<Community> _searchResults = [];
  List<String> _searchHistory = [];
  List<PopularSearch> _popularSearches = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _showPopularSearches = true;
  String _currentQuery = '';
  
  static const String _searchHistoryKey = 'community_search_history';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadCommunities();
    _loadPopularSearches();
    
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_searchHistoryKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        setState(() {
          _searchHistory = historyList.cast<String>().reversed.toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(_searchHistory.reversed.toList());
      await prefs.setString(_searchHistoryKey, historyJson);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  Future<void> _addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    final trimmedQuery = query.trim();
    setState(() {
      _searchHistory.remove(trimmedQuery);
      _searchHistory.insert(0, trimmedQuery);
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.sublist(0, 20);
      }
    });
    
    await _saveSearchHistory();
  }

  Future<void> _removeFromSearchHistory(String query) async {
    setState(() {
      _searchHistory.remove(query);
    });
    await _saveSearchHistory();
  }

  Future<void> _clearSearchHistory() async {
    setState(() {
      _searchHistory.clear();
    });
    await _saveSearchHistory();
  }

  Future<void> _loadCommunities() async {
    try {
      final communities = await _blockingService.getFilteredCommunities();
      setState(() {
        _allCommunities = communities;
      });
    } catch (e) {
      debugPrint('Error loading communities: $e');
    }
  }

  Future<void> _loadPopularSearches() async {
    try {
      final popularSearches = await _searchAnalyticsService.getPopularSearches(limit: 10);
      setState(() {
        _popularSearches = popularSearches;
      });
    } catch (e) {
      debugPrint('Error loading popular searches: $e');
    }
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _currentQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentQuery = query.trim();
    });

    // Add to search history
    await _addToSearchHistory(_currentQuery);

    // Record search in analytics database
    await _searchAnalyticsService.recordSearch(_currentQuery);

    // Perform search
    final results = _allCommunities.where((community) {
      final nameLower = community.communityName.toLowerCase();
      final queryLower = _currentQuery.toLowerCase();
      final hashtagsMatch = community.hashtags.any(
        (hashtag) => hashtag.toLowerCase().contains(queryLower),
      );
      final announcementMatch = community.announcement != null &&
          community.announcement!.toLowerCase().contains(queryLower);
      
      return nameLower.contains(queryLower) || 
             hashtagsMatch || 
             announcementMatch;
    }).toList();

    setState(() {
      _searchResults = results;
      _hasSearched = true;
      _isLoading = false;
    });

    // Refresh popular searches after recording
    _loadPopularSearches();
  }

  void _selectFromHistory(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  void _selectPopularSearch(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widthRatio = screenSize.width / 393;
    final heightRatio = screenSize.height / 852;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildSearchAppBar(widthRatio),
      body: _hasSearched ? _buildSearchResults(widthRatio, heightRatio) : _buildSearchHome(widthRatio, heightRatio),
    );
  }

  PreferredSizeWidget _buildSearchAppBar(double widthRatio) {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 24 * widthRatio),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(fontSize: 16 * widthRatio, color: Colors.black87),
        decoration: InputDecoration(
          hintText: '관심있는 키워드를 입력해주세요.',
          hintStyle: TextStyle(
            color: const Color(0xFFC7C7C7),
            fontSize: 16 * widthRatio,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: const Color(0xFFC7C7C7), size: 24 * widthRatio),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: const Color(0xFFC7C7C7), size: 20 * widthRatio),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _hasSearched = false;
                      _searchResults = [];
                      _currentQuery = '';
                    });
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {}); // Trigger rebuild to show/hide clear button
        },
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildSearchHome(double widthRatio, double heightRatio) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * widthRatio),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 28 * heightRatio),
            if (_searchHistory.isNotEmpty) ...[
              _buildRecentSearches(widthRatio, heightRatio),
              SizedBox(height: 32 * heightRatio),
            ],
            _buildPopularSearches(widthRatio, heightRatio),
            SizedBox(height: 32 * heightRatio),
            _buildAdSection(widthRatio, heightRatio),
            SizedBox(height: 40 * heightRatio),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(double widthRatio, double heightRatio) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5F37CF),
        ),
      );
    }

    return Column(
      children: [
        // Search results header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16 * widthRatio, vertical: 16 * heightRatio),
          child: Text(
            "'$_currentQuery'에 대한 검색 결과 ${_searchResults.length}개",
            style: TextStyle(
              color: const Color(0xFF121212),
              fontSize: 16 * widthRatio,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Search results list
        Expanded(
          child: _searchResults.isEmpty
              ? _buildNoResults(widthRatio, heightRatio)
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16 * widthRatio),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final community = _searchResults[index];
                    return _buildCommunityCard(community, widthRatio, heightRatio);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoResults(double widthRatio, double heightRatio) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64 * widthRatio,
            color: const Color(0xFFCCCCCC),
          ),
          SizedBox(height: 16 * heightRatio),
          Text(
            '검색 결과가 없어요',
            style: TextStyle(
              color: const Color(0xFF8E8E8E),
              fontSize: 18 * widthRatio,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8 * heightRatio),
          Text(
            '다른 키워드로 검색해보세요',
            style: TextStyle(
              color: const Color(0xFFCCCCCC),
              fontSize: 14 * widthRatio,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(Community community, double widthRatio, double heightRatio) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * heightRatio),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * widthRatio),
          side: const BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => KoreanCommunityDetailPage(community: community),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12 * widthRatio),
          child: Padding(
            padding: EdgeInsets.all(16 * widthRatio),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Community image on the left
                Container(
                  width: 60 * widthRatio,
                  height: 60 * widthRatio,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E9E9),
                    borderRadius: BorderRadius.circular(8 * widthRatio),
                  ),
                  child: community.communityBanner != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8 * widthRatio),
                          child: Image.network(
                            community.communityBanner!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.group, color: Colors.grey, size: 24);
                            },
                          ),
                        )
                      : const Icon(Icons.group, color: Colors.grey, size: 24),
                ),
                
                SizedBox(width: 16 * widthRatio),
                
                // Community info on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Community title
                      Text(
                        community.communityName,
                        style: TextStyle(
                          color: const Color(0xFF121212),
                          fontSize: 16 * widthRatio,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 4 * heightRatio),
                      
                      // Community description
                      if (community.announcement != null && community.announcement!.isNotEmpty) ...[
                        Text(
                          community.announcement!,
                          style: TextStyle(
                            color: const Color(0xFF8E8E8E),
                            fontSize: 14 * widthRatio,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8 * heightRatio),
                      ],
                      
                      // Member count at bottom right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.people,
                            size: 14 * widthRatio,
                            color: const Color(0xFF8E8E8E),
                          ),
                          SizedBox(width: 4 * widthRatio),
                          Text(
                            '${community.memberCount}명',
                            style: TextStyle(
                              color: const Color(0xFF8E8E8E),
                              fontSize: 12 * widthRatio,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Add block button for community creator
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF8E8E8E),
                  ),
                  onSelected: (value) async {
                    await BlockingUtils.handleMenuSelection(
                      context: context,
                      selectedValue: value,
                      userId: community.creatorId,
                      username: '커뮤니티 작성자',
                      onBlocked: () {
                        // Refresh search results
                        _performSearch(_currentQuery);
                      },
                    );
                  },
                  itemBuilder: (context) => [
                    BlockingUtils.createBlockMenuItem(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(double widthRatio, double heightRatio) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 검색어',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16 * widthRatio,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: _clearSearchHistory,
              child: Text(
                '전체 삭제',
                style: TextStyle(
                  color: const Color(0xFF595959),
                  fontSize: 14 * widthRatio,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * heightRatio),
        Wrap(
          spacing: 8.0 * widthRatio,
          runSpacing: 8.0 * heightRatio,
          children: _searchHistory.take(10).map((keyword) {
            return GestureDetector(
              onTap: () => _selectFromHistory(keyword),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * widthRatio,
                  vertical: 8 * heightRatio,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20 * widthRatio),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      keyword,
                      style: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: 14 * widthRatio,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    SizedBox(width: 8 * widthRatio),
                    GestureDetector(
                      onTap: () => _removeFromSearchHistory(keyword),
                      child: Icon(
                        Icons.close,
                        size: 16 * widthRatio,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularSearches(double widthRatio, double heightRatio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '인기 검색어',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16 * widthRatio,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showPopularSearches = !_showPopularSearches;
                });
              },
              child: Text(
                _showPopularSearches ? '접기' : '펼치기',
                style: TextStyle(
                  color: const Color(0xFFBBBBBB),
                  fontSize: 14 * widthRatio,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (_showPopularSearches) ...[
          SizedBox(height: 12 * heightRatio),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 16 * heightRatio,
              horizontal: 16 * widthRatio,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * widthRatio),
            ),
            child: _popularSearches.isEmpty
                ? Text(
                    '아직 인기 검색어가 없어요',
                    style: TextStyle(
                      color: const Color(0xFFCCCCCC),
                      fontSize: 14 * widthRatio,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Column(
                    children: _buildPopularSearchItems(widthRatio, heightRatio),
                  ),
          )
        ]
      ],
    );
  }

  List<Widget> _buildPopularSearchItems(double widthRatio, double heightRatio) {
    // Split items into two columns: 1-5 in left, 6-10 in right
    final int halfLength = (_popularSearches.length / 2).ceil();
    final leftColumnItems = _popularSearches.take(halfLength).toList();
    final rightColumnItems = _popularSearches.skip(halfLength).toList();
    
    final List<Widget> rows = [];
    
    // Create rows with left and right column items
    for (int i = 0; i < halfLength; i++) {
      final leftSearch = i < leftColumnItems.length ? leftColumnItems[i] : null;
      final rightSearch = i < rightColumnItems.length ? rightColumnItems[i] : null;
      
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6 * heightRatio),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column item (ranks 1-5)
              Expanded(
                child: leftSearch != null
                    ? _buildPopularSearchItem(
                        search: leftSearch,
                        rank: i + 1, // 1, 2, 3, 4, 5
                        widthRatio: widthRatio,
                        heightRatio: heightRatio,
                      )
                    : Container(),
              ),
              
              SizedBox(width: 20 * widthRatio),
              
              // Right column item (ranks 6-10)
              Expanded(
                child: rightSearch != null
                    ? _buildPopularSearchItem(
                        search: rightSearch,
                        rank: halfLength + i + 1, // 6, 7, 8, 9, 10
                        widthRatio: widthRatio,
                        heightRatio: heightRatio,
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      );
    }
    
    return rows;
  }

  Widget _buildPopularSearchItem({
    required PopularSearch search,
    required int rank,
    required double widthRatio,
    required double heightRatio,
  }) {
    return GestureDetector(
      onTap: () => _selectPopularSearch(search.query),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 4 * heightRatio,
          horizontal: 8 * widthRatio,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * widthRatio),
          color: Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rank number
            Text(
              '$rank',
              style: TextStyle(
                color: const Color(0xFF121212),
                fontSize: 14 * widthRatio,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8 * widthRatio),
            
            // Search term
            Expanded(
              child: Text(
                search.query,
                style: TextStyle(
                  color: const Color(0xFF121212),
                  fontSize: 14 * widthRatio,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(width: 4 * widthRatio),
            
            // Ranking arrow
            _buildRankingArrow(search.rankingTrend, widthRatio),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingArrow(RankingTrend trend, double widthRatio) {
    IconData iconData;
    Color iconColor;
    
    switch (trend) {
      case RankingTrend.up:
        iconData = Icons.keyboard_arrow_up;
        iconColor = const Color(0xFF5F37CF); // Purple color for up
        break;
      case RankingTrend.down:
        iconData = Icons.keyboard_arrow_down;
        iconColor = const Color(0xFF5F37CF); // Purple color for down
        break;
      case RankingTrend.neutral:
      default:
        iconData = Icons.keyboard_arrow_up; // Default to up arrow
        iconColor = const Color(0xFF5F37CF);
        break;
    }
    
    return Icon(
      iconData,
      color: iconColor,
      size: 20 * widthRatio,
    );
  }

  Widget _buildAdSection(double widthRatio, double heightRatio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '광고',
          style: TextStyle(
            color: const Color(0xFF606060),
            fontSize: 14 * widthRatio,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8 * heightRatio),
        Container(
          height: 105 * heightRatio,
          decoration: BoxDecoration(
            color: const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(6 * widthRatio),
          ),
          child: const Center(child: Text("Ad Banner 1")),
        ),
        SizedBox(height: 16 * heightRatio),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 105 * heightRatio,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(6 * widthRatio),
                ),
                child: const Center(child: Text("Ad Banner 2")),
              ),
            ),
            SizedBox(width: 12 * widthRatio),
            Expanded(
              child: Container(
                height: 105 * heightRatio,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(4 * widthRatio),
                ),
                child: const Center(child: Text("Ad Banner 3")),
              ),
            ),
          ],
        )
      ],
    );
  }
}