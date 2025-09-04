import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DeletedAccountsAdminPage extends StatefulWidget {
  const DeletedAccountsAdminPage({super.key});

  @override
  State<DeletedAccountsAdminPage> createState() => _DeletedAccountsAdminPageState();
}

class _DeletedAccountsAdminPageState extends State<DeletedAccountsAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DeletedAccountRecord> _deletedAccounts = [];
  bool _isLoading = true;
  String _selectedFilterReason = 'All';
  String _sortBy = 'Recent'; // Recent, Oldest, Name

  @override
  void initState() {
    super.initState();
    _loadDeletedAccounts();
  }

  Future<void> _loadDeletedAccounts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final QuerySnapshot querySnapshot = await _firestore
          .collection('deleted_accounts')
          .orderBy('deletedAt', descending: true)
          .get();

      final List<DeletedAccountRecord> accounts = querySnapshot.docs
          .map((doc) => DeletedAccountRecord.fromFirestore(doc))
          .toList();

      setState(() {
        _deletedAccounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제된 계정 정보를 불러오는데 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<DeletedAccountRecord> _getFilteredAndSortedAccounts() {
    List<DeletedAccountRecord> filteredAccounts = List.from(_deletedAccounts);

    // Filter by reason
    if (_selectedFilterReason != 'All') {
      filteredAccounts = filteredAccounts
          .where((account) => account.deletionReason == _selectedFilterReason)
          .toList();
    }

    // Sort accounts
    switch (_sortBy) {
      case 'Recent':
        filteredAccounts.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
        break;
      case 'Oldest':
        filteredAccounts.sort((a, b) => a.deletedAt.compareTo(b.deletedAt));
        break;
      case 'Name':
        filteredAccounts.sort((a, b) => a.username.compareTo(b.username));
        break;
    }

    return filteredAccounts;
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design calculations
    const double baseWidth = 393.0;
    const double baseHeight = 852.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double widthRatio = screenWidth / baseWidth;
    final double heightRatio = screenHeight / baseHeight;

    final filteredAccounts = _getFilteredAndSortedAccounts();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF121212),
            size: 20 * widthRatio,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Deleted Accounts',
          style: TextStyle(
            fontSize: 18 * widthRatio,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121212),
            fontFamily: 'Pretendard',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: const Color(0xFF5F37CF),
              size: 24 * widthRatio,
            ),
            onPressed: _loadDeletedAccounts,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats header
            Container(
              margin: EdgeInsets.all(16 * widthRatio),
              padding: EdgeInsets.all(20 * widthRatio),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * widthRatio),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    '총 삭제된 계정',
                    '${_deletedAccounts.length}',
                    Icons.delete_outline,
                    const Color(0xFFDC2626),
                    widthRatio,
                    heightRatio,
                  ),
                  Container(
                    width: 1,
                    height: 40 * heightRatio,
                    color: const Color(0xFFF0F0F0),
                  ),
                  _buildStatItem(
                    '이번 달 삭제',
                    '${_getThisMonthDeletions()}',
                    Icons.calendar_today,
                    const Color(0xFF5F37CF),
                    widthRatio,
                    heightRatio,
                  ),
                ],
              ),
            ),

            // Filter and sort controls
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16 * widthRatio),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filter dropdown
                  GestureDetector(
                    onTap: () => _showFilterDialog(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * widthRatio,
                        vertical: 8 * heightRatio,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * widthRatio),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 16 * widthRatio,
                            color: const Color(0xFF5F37CF),
                          ),
                          SizedBox(width: 4 * widthRatio),
                          Text(
                            _selectedFilterReason == 'All' ? '전체 사유' : _selectedFilterReason,
                            style: TextStyle(
                              fontSize: 12 * widthRatio,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5F37CF),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          SizedBox(width: 4 * widthRatio),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16 * widthRatio,
                            color: const Color(0xFF5F37CF),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sort dropdown
                  GestureDetector(
                    onTap: () => _showSortDialog(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * widthRatio,
                        vertical: 8 * heightRatio,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * widthRatio),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sort,
                            size: 16 * widthRatio,
                            color: const Color(0xFF8E8E8E),
                          ),
                          SizedBox(width: 4 * widthRatio),
                          Text(
                            _getSortDisplayText(),
                            style: TextStyle(
                              fontSize: 12 * widthRatio,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8E8E8E),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          SizedBox(width: 4 * widthRatio),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16 * widthRatio,
                            color: const Color(0xFF8E8E8E),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16 * heightRatio),

            // Accounts list
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(heightRatio)
                  : filteredAccounts.isEmpty
                      ? _buildEmptyState(heightRatio)
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16 * widthRatio),
                          itemCount: filteredAccounts.length,
                          separatorBuilder: (context, index) => SizedBox(height: 12 * heightRatio),
                          itemBuilder: (context, index) {
                            final account = filteredAccounts[index];
                            return _buildAccountCard(account, widthRatio, heightRatio);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    double widthRatio,
    double heightRatio,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24 * widthRatio,
        ),
        SizedBox(height: 8 * heightRatio),
        Text(
          value,
          style: TextStyle(
            fontSize: 20 * widthRatio,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Pretendard',
          ),
        ),
        SizedBox(height: 4 * heightRatio),
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * widthRatio,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8E8E8E),
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(DeletedAccountRecord account, double widthRatio, double heightRatio) {
    return Container(
      padding: EdgeInsets.all(16 * widthRatio),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * widthRatio),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with username and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  account.username,
                  style: TextStyle(
                    fontSize: 16 * widthRatio,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF121212),
                    fontFamily: 'Pretendard',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(account.deletedAt),
                style: TextStyle(
                  fontSize: 12 * widthRatio,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E8E),
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * heightRatio),

          // User info row
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 14 * widthRatio,
                color: const Color(0xFF8E8E8E),
              ),
              SizedBox(width: 4 * widthRatio),
              Expanded(
                child: Text(
                  account.email,
                  style: TextStyle(
                    fontSize: 13 * widthRatio,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E8E),
                    fontFamily: 'Pretendard',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * heightRatio),

          // Deletion reason chip
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8 * widthRatio,
              vertical: 4 * heightRatio,
            ),
            decoration: BoxDecoration(
              color: _getDeletionReasonColor(account.deletionReason).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12 * widthRatio),
            ),
            child: Text(
              account.deletionReason,
              style: TextStyle(
                fontSize: 11 * widthRatio,
                fontWeight: FontWeight.w500,
                color: _getDeletionReasonColor(account.deletionReason),
                fontFamily: 'Pretendard',
              ),
            ),
          ),

          if (account.deletionComment != null && account.deletionComment!.isNotEmpty) ...[
            SizedBox(height: 12 * heightRatio),
            Container(
              padding: EdgeInsets.all(12 * widthRatio),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8 * widthRatio),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '삭제 사유 상세:',
                    style: TextStyle(
                      fontSize: 12 * widthRatio,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  SizedBox(height: 4 * heightRatio),
                  Text(
                    account.deletionComment!,
                    style: TextStyle(
                      fontSize: 12 * widthRatio,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF4B5563),
                      fontFamily: 'Pretendard',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(double heightRatio) {
    return Padding(
      padding: EdgeInsets.all(40 * heightRatio),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5F37CF)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double heightRatio) {
    return Padding(
      padding: EdgeInsets.all(40 * heightRatio),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: Color(0xFFC7C7C7),
            ),
            SizedBox(height: 16),
            Text(
              '삭제된 계정이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E8E),
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDeletionReasonColor(String reason) {
    switch (reason) {
      case '서비스 불만족':
        return const Color(0xFFDC2626);
      case '개인정보 우려':
        return const Color(0xFF7C3AED);
      case '사용 빈도 낮음':
        return const Color(0xFF0EA5E9);
      case '기타':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B7280);
    }
  }

  int _getThisMonthDeletions() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    return _deletedAccounts
        .where((account) => account.deletedAt.isAfter(thisMonth))
        .length;
  }

  String _getSortDisplayText() {
    switch (_sortBy) {
      case 'Recent':
        return '최신순';
      case 'Oldest':
        return '오래된순';
      case 'Name':
        return '이름순';
      default:
        return '최신순';
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '삭제 사유 필터',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 20),

              // Filter options
              ...['All', '서비스 불만족', '개인정보 우려', '사용 빈도 낮음', '기타'].map(
                (reason) => _buildFilterOption(reason),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String reason) {
    final isSelected = _selectedFilterReason == reason;
    final displayText = reason == 'All' ? '전체 사유' : reason;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterReason = reason;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5F37CF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF5F37CF) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF8E8E8E),
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '정렬 순서',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 20),

              // Sort options
              _buildSortOption('최신순', 'Recent'),
              _buildSortOption('오래된순', 'Oldest'),
              _buildSortOption('이름순', 'Name'),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String displayText, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF121212) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF8E8E8E),
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }
}

// Data model for deleted account records
class DeletedAccountRecord {
  final String userId;
  final String username;
  final String email;
  final DateTime deletedAt;
  final String deletionReason;
  final String? deletionComment;
  final DateTime originalSignupDate;

  DeletedAccountRecord({
    required this.userId,
    required this.username,
    required this.email,
    required this.deletedAt,
    required this.deletionReason,
    this.deletionComment,
    required this.originalSignupDate,
  });

  factory DeletedAccountRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeletedAccountRecord(
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Unknown User',
      email: data['email'] ?? 'No email',
      deletedAt: (data['deletedAt'] as Timestamp).toDate(),
      deletionReason: data['deletionReason'] ?? '기타',
      deletionComment: data['deletionComment'],
      originalSignupDate: data['originalSignupDate'] != null 
          ? (data['originalSignupDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'deletedAt': Timestamp.fromDate(deletedAt),
      'deletionReason': deletionReason,
      'deletionComment': deletionComment,
      'originalSignupDate': Timestamp.fromDate(originalSignupDate),
    };
  }
}