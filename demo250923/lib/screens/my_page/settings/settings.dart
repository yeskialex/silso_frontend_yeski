import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/authentication/auth_service.dart';
import 'change_pw.dart';
import 'blocked_users.dart';
import 'usage_limit_history.dart';
import 'faq.dart';
import 'announcements.dart';
import 'remove_account.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  bool _isSigningOut = false;
  String _userId = '로딩 중...'; // State variable to store user ID
  bool _isLoadingUserId = true;
  
  // Toggle states for notifications
  bool _publicPostsNotification = true;
  bool _chatNotification = true;
  bool _generalNotification = true;
  bool _sosNotification = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// Load user's actual ID from Firestore
  Future<void> _loadUserInfo() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _userId = '로그인 필요';
          _isLoadingUserId = false;
        });
        return;
      }

      // Get user document from Firestore to retrieve the user's ID
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (userDoc.exists && mounted) {
        final data = userDoc.data();
        // Try to get the authentication ID first, fallback to email
        String displayId = data?['authentication']?['id'] ?? 
                          user.email?.split('@')[0] ?? 
                          '사용자${user.uid.substring(0, 8)}';
        
        // Remove @silso.com if it exists in the ID
        if (displayId.contains('@silso.com')) {
          displayId = displayId.split('@')[0];
        }
        
        setState(() {
          _userId = displayId;
          _isLoadingUserId = false;
        });
      } else {
        // Fallback to email or UID if no Firestore document
        String displayId = user.email?.split('@')[0] ?? '사용자${user.uid.substring(0, 8)}';
        
        // Remove @silso.com if it exists in the ID
        if (displayId.contains('@silso.com')) {
          displayId = displayId.split('@')[0];
        }
        
        setState(() {
          _userId = displayId;
          _isLoadingUserId = false;
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
      if (mounted) {
        setState(() {
          _userId = '정보 로드 실패';
          _isLoadingUserId = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);

    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSigningOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAppVersionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5F37CF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF5F37CF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '앱 버전',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212),
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF5F37CF).withValues(alpha: 0.05),
                        const Color(0xFF5F37CF).withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF5F37CF).withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '실소 (Silso)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5F37CF),
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5F37CF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BETA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '1.0.0',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF121212),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '베타 테스트 버전입니다.\n새로운 기능과 개선사항을 체험해보세요!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          fontFamily: 'Pretendard',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F37CF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
          'MY설정',
          style: TextStyle(
            fontSize: 18 * widthRatio,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121212),
            fontFamily: 'Pretendard',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24 * heightRatio),
            
            // Account Section
            _buildSectionHeader('계정', widthRatio, heightRatio),
            _buildMenuItem('아이디', _userId, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('비밀번호 변경', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('계정인증', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('회원 탈퇴', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('차단된 계정', null, null, widthRatio, heightRatio),
            
            SizedBox(height: 32 * heightRatio),
            
            // Notifications Section
            _buildSectionHeader('알림', widthRatio, heightRatio),
            _buildToggleMenuItem('공지 알림', _publicPostsNotification, (value) {
              setState(() => _publicPostsNotification = value);
            }, widthRatio, heightRatio),
            _buildDivider(),
            _buildToggleMenuItem('댓글 알림', _chatNotification, (value) {
              setState(() => _chatNotification = value);
            }, widthRatio, heightRatio),
            _buildDivider(),
            _buildToggleMenuItem('채팅 알림', _generalNotification, (value) {
              setState(() => _generalNotification = value);
            }, widthRatio, heightRatio),
            _buildDivider(),
            _buildToggleMenuItem('실소 소식 알림', _sosNotification, (value) {
              setState(() => _sosNotification = value);
            }, widthRatio, heightRatio),
            
            SizedBox(height: 32 * heightRatio),
            
            // Other Section
            _buildSectionHeader('이용약관', widthRatio, heightRatio),
            _buildMenuItem('이용 제한 내역', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('문의하기', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('공지사항', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('서비스 이용약관 및 정책', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('오픈 소스 라이선스', null, null, widthRatio, heightRatio),
            
            SizedBox(height: 32 * heightRatio),
            
            // App Info Section
            _buildMenuItem('정보 동의', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('앱 버전', null, null, widthRatio, heightRatio),
            _buildDivider(),
            _buildMenuItem('로그아웃', null, null, widthRatio, heightRatio),
            
            SizedBox(height: 40 * heightRatio),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title, double widthRatio, double heightRatio) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * widthRatio, vertical: 8 * heightRatio),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14 * widthRatio,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8E8E8E),
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
    );
  }

  Widget _buildMenuItem(String title, String? subtitle, String? trailing, double widthRatio, double heightRatio) {
    return InkWell(
      onTap: () {
        if (title == '로그아웃') {
          _signOut();
        } else if (title == '앱 버전') {
          _showAppVersionDialog();
        } else if (title == '비밀번호 변경') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChangePasswordPage(),
            ),
          );
        } else if (title == '차단된 계정') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BlockedUsersPage(),
            ),
          );
        } else if (title == '이용 제한 내역') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UsageLimitHistoryPage(),
            ),
          );
        } else if (title == '문의하기') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FAQPage(),
            ),
          );
        } else if (title == '공지사항') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AnnouncementsPage(),
            ),
          );
        } else if (title == '회원 탈퇴') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RemoveAccountPage(),
            ),
          );
        } else {
          // TODO: Add navigation functionality for other menu items
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * widthRatio,
          vertical: 16 * heightRatio,
        ),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16 * widthRatio,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF121212),
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2 * heightRatio),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14 * widthRatio,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E8E),
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14 * widthRatio,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E8E),
                  fontFamily: 'Pretendard',
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16 * widthRatio,
                color: const Color(0xFF8E8E8E),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem(String title, bool value, ValueChanged<bool> onChanged, double widthRatio, double heightRatio) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthRatio,
        vertical: 16 * heightRatio,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16 * widthRatio,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF121212),
              fontFamily: 'Pretendard',
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF5F37CF),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE0E0E0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}