import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/authentication/auth_service.dart';

class RemoveAccountPage extends StatefulWidget {
  const RemoveAccountPage({super.key});

  @override
  State<RemoveAccountPage> createState() => _RemoveAccountPageState();
}

class _RemoveAccountPageState extends State<RemoveAccountPage> {
  final AuthService _authService = AuthService();
  final _reasonController = TextEditingController();
  bool _isProcessing = false;
  bool _confirmationChecked = false;
  String _selectedReason = '';
  bool _permanentDelete = false;
  
  final List<String> _removalReasons = [
    '더 이상 서비스를 이용하지 않음',
    '개인정보 보호 우려',
    '다른 계정으로 이전',
    '서비스에 불만족',
    '기타'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _processAccountRemoval() async {
    if (!_confirmationChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('계정 삭제에 대한 확인이 필요합니다.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('탈퇴 사유를 선택해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show final confirmation dialog
    final confirmed = await _showFinalConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('사용자 인증 정보를 찾을 수 없습니다.');
      }

      // Process account removal
      await _removeUserAccount(user.uid);
      
      if (_permanentDelete) {
        // Hard delete: requires re-authentication but completely removes account
        await _deleteAuthAccount();
      } else {
        // Soft delete: immediate but keeps Firebase Auth account
        await _authService.signOut();
      }
      
      if (mounted) {
        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정이 성공적으로 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('계정 삭제 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showFinalConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                '최종 확인',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212),
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정말로 계정을 삭제하시겠습니까?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF121212),
                  fontFamily: 'Pretendard',
                ),
              ),
              SizedBox(height: 12),
              Text(
                '• 모든 개인 데이터가 영구적으로 삭제됩니다\n'
                '• 작성한 게시글과 댓글은 "탈퇴한 사용자"로 표시됩니다\n'
                '• 이 작업은 되돌릴 수 없습니다',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E8E),
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '삭제하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deleteAuthAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      // Try to delete directly first
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Handle re-authentication requirement with direct credential prompt
        await _reauthenticateAndDelete(user);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _reauthenticateAndDelete(User user) async {
    // Check what provider the user used to sign in
    final providerData = user.providerData;
    if (providerData.isEmpty) {
      throw Exception('로그인 제공자 정보를 찾을 수 없습니다.');
    }

    final providerId = providerData.first.providerId;
    
    if (providerId == 'password') {
      // For email/password users
      await _reauthenticateWithPassword(user);
    } else if (providerId == 'google.com') {
      // For Google users
      await _reauthenticateWithGoogle(user);
    } else if (providerId == 'phone') {
      // For phone users
      await _reauthenticateWithPhone(user);
    } else {
      // For other providers (Kakao, etc.)
      throw Exception('${providerId} 로그인 사용자는 앱을 재시작 후 다시 시도해주세요.');
    }
    
    // After successful re-authentication, delete the account
    await user.delete();
  }

  Future<void> _reauthenticateWithPassword(User user) async {
    final password = await _showPasswordDialog();
    if (password == null || password.isEmpty) {
      throw Exception('비밀번호가 필요합니다.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _reauthenticateWithGoogle(User user) async {
    try {
      // Sign in with Google again to get fresh credential
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential?.credential != null) {
        await user.reauthenticateWithCredential(userCredential!.credential!);
      }
    } catch (e) {
      throw Exception('Google 재인증에 실패했습니다. 앱을 재시작 후 다시 시도해주세요.');
    }
  }

  Future<void> _reauthenticateWithPhone(User user) async {
    final phoneNumber = user.phoneNumber;
    if (phoneNumber == null) {
      throw Exception('전화번호 정보를 찾을 수 없습니다.');
    }

    final verificationCode = await _showPhoneVerificationDialog(phoneNumber);
    if (verificationCode == null || verificationCode.isEmpty) {
      throw Exception('인증번호가 필요합니다.');
    }

    try {
      // Get the verification ID from phone confirmation page
      final verificationId = await _requestPhoneVerification(phoneNumber);
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode,
      );
      
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('전화번호 재인증에 실패했습니다: ${e.toString()}');
    }
  }

  Future<String> _requestPhoneVerification(String phoneNumber) async {
    String? verificationId;
    bool completed = false;
    
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-verification completed (rare on iOS)
        completed = true;
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('전화번호 인증 요청에 실패했습니다: ${e.message}');
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        completed = true;
      },
      codeAutoRetrievalTimeout: (String verId) {
        if (!completed) {
          verificationId = verId;
          completed = true;
        }
      },
      timeout: const Duration(seconds: 60),
    );

    // Wait for verification ID
    while (!completed && verificationId == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (verificationId == null) {
      throw Exception('인증번호 전송에 실패했습니다.');
    }

    return verificationId!;
  }

  Future<String?> _showPhoneVerificationDialog(String phoneNumber) async {
    String? verificationCode;
    
    // Responsive design calculations
    const double baseWidth = 393.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final double widthRatio = screenWidth / baseWidth;
    
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * widthRatio),
          ),
          title: Row(
            children: [
              Icon(
                Icons.phone_android,
                color: const Color(0xFF5F37CF),
                size: 24 * widthRatio,
              ),
              SizedBox(width: 8 * widthRatio),
              Text(
                '전화번호 인증',
                style: TextStyle(
                  fontSize: 18 * widthRatio,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF121212),
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$phoneNumber로 전송된\n인증번호를 입력해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * widthRatio,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                  fontFamily: 'Pretendard',
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20 * widthRatio),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                onChanged: (value) => verificationCode = value,
                decoration: InputDecoration(
                  labelText: '인증번호',
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: const Color(0xFFBBBBBB),
                    fontSize: 16 * widthRatio,
                    fontFamily: 'Pretendard',
                  ),
                  labelStyle: TextStyle(
                    color: const Color(0xFF8E8E8E),
                    fontSize: 14 * widthRatio,
                    fontFamily: 'Pretendard',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * widthRatio),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * widthRatio),
                    borderSide: const BorderSide(color: Color(0xFF5F37CF), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * widthRatio),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16 * widthRatio,
                    vertical: 16 * widthRatio,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16 * widthRatio,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                  letterSpacing: 2,
                ),
                autofocus: true,
              ),
              SizedBox(height: 12 * widthRatio),
              Text(
                '인증번호가 오지 않나요?\nSMS 수신 상태를 확인해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12 * widthRatio,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E8E),
                  fontFamily: 'Pretendard',
                  height: 1.3,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12 * widthRatio),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * widthRatio),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16 * widthRatio,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E8E8E),
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8 * widthRatio),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(verificationCode),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF5F37CF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12 * widthRatio),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * widthRatio),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16 * widthRatio,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showPasswordDialog() async {
    String? password;
    
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '비밀번호 확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121212),
              fontFamily: 'Pretendard',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '계정을 삭제하려면 현재 비밀번호를 입력해주세요.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: true,
                onChanged: (value) => password = value,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E8E),
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(password),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F37CF),
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _removeUserAccount(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    
    try {
      // 1. Disable user account
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      batch.update(userRef, {
        'settings.isActive': false,
        'settings.accountDeleted': true,
        'settings.deletedAt': FieldValue.serverTimestamp(),
        'settings.deletionReason': _selectedReason,
        'settings.customReason': _reasonController.text.trim(),
        'displayName': '알수없음',
        'NicknamePet': '알수없음',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update user's posts to show "알수없음" as author
      final postsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (var doc in postsQuery.docs) {
        batch.update(doc.reference, {
          'author': '알수없음',
          'authorName': '알수없음',
          'isDeletedUser': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Update user's comments to show "undefined" as author
      final commentsQuery = await FirebaseFirestore.instance
          .collection('comments')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (var doc in commentsQuery.docs) {
        batch.update(doc.reference, {
          'author': 'undefined',
          'authorName': 'undefined',
          'isDeletedUser': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 4. Update any community memberships
      final communitiesQuery = await FirebaseFirestore.instance
          .collection('communities')
          .where('members', arrayContains: uid)
          .get();
      
      for (var doc in communitiesQuery.docs) {
        batch.update(doc.reference, {
          'members': FieldValue.arrayRemove([uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 5. Remove user from any community admin roles
      final adminCommunitiesQuery = await FirebaseFirestore.instance
          .collection('communities')
          .where('admins', arrayContains: uid)
          .get();
      
      for (var doc in adminCommunitiesQuery.docs) {
        batch.update(doc.reference, {
          'admins': FieldValue.arrayRemove([uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Execute all updates in a batch
      await batch.commit();
      print('✅ Account removal completed for user: $uid');
      
    } catch (e) {
      print('❌ Error during account removal: $e');
      rethrow;
    }
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
          '계정 탈퇴',
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
        child: Padding(
          padding: EdgeInsets.all(20 * widthRatio),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16 * widthRatio),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12 * widthRatio),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 24 * widthRatio,
                        ),
                        SizedBox(width: 8 * widthRatio),
                        Text(
                          '주의사항',
                          style: TextStyle(
                            fontSize: 16 * widthRatio,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * heightRatio),
                    Text(
                      '• 계정 삭제 후에는 복구가 불가능합니다\n'
                      '• 모든 개인 정보가 영구적으로 삭제됩니다\n'
                      '• 작성한 게시글과 댓글은 "탈퇴한 사용자"로 표시됩니다\n'
                      '• 커뮤니티 멤버십이 모두 해제됩니다',
                      style: TextStyle(
                        fontSize: 14 * widthRatio,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                        fontFamily: 'Pretendard',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32 * heightRatio),
              
              // Reason selection
              Text(
                '탈퇴 사유',
                style: TextStyle(
                  fontSize: 16 * widthRatio,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF121212),
                  fontFamily: 'Pretendard',
                ),
              ),
              
              SizedBox(height: 16 * heightRatio),
              
              // Reason options
              ...List.generate(_removalReasons.length, (index) {
                final reason = _removalReasons[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8 * heightRatio),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedReason = reason;
                      });
                    },
                    borderRadius: BorderRadius.circular(8 * widthRatio),
                    child: Container(
                      padding: EdgeInsets.all(16 * widthRatio),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * widthRatio),
                        border: Border.all(
                          color: _selectedReason == reason
                              ? const Color(0xFF5F37CF)
                              : const Color(0xFFE0E0E0),
                          width: _selectedReason == reason ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20 * widthRatio,
                            height: 20 * widthRatio,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedReason == reason
                                    ? const Color(0xFF5F37CF)
                                    : const Color(0xFFBBBBBB),
                                width: 2,
                              ),
                              color: _selectedReason == reason
                                  ? const Color(0xFF5F37CF)
                                  : Colors.transparent,
                            ),
                            child: _selectedReason == reason
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14 * widthRatio,
                                  )
                                : null,
                          ),
                          SizedBox(width: 12 * widthRatio),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14 * widthRatio,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF121212),
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              // Custom reason text field
              if (_selectedReason == '기타') ...[
                SizedBox(height: 16 * heightRatio),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: '탈퇴 사유를 자세히 입력해주세요',
                    hintStyle: TextStyle(
                      color: const Color(0xFF8E8E8E),
                      fontSize: 14 * widthRatio,
                      fontFamily: 'Pretendard',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * widthRatio),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * widthRatio),
                      borderSide: const BorderSide(color: Color(0xFF5F37CF)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(
                    fontSize: 14 * widthRatio,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
              
              SizedBox(height: 32 * heightRatio),
              
              // Permanent delete option
              Container(
                padding: EdgeInsets.all(16 * widthRatio),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12 * widthRatio),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20 * widthRatio,
                        ),
                        SizedBox(width: 8 * widthRatio),
                        Text(
                          '삭제 옵션',
                          style: TextStyle(
                            fontSize: 14 * widthRatio,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * heightRatio),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _permanentDelete = !_permanentDelete;
                        });
                      },
                      borderRadius: BorderRadius.circular(4 * widthRatio),
                      child: Padding(
                        padding: EdgeInsets.all(4 * widthRatio),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20 * widthRatio,
                              height: 20 * widthRatio,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4 * widthRatio),
                                border: Border.all(
                                  color: _permanentDelete
                                      ? Colors.orange
                                      : const Color(0xFFBBBBBB),
                                  width: 2,
                                ),
                                color: _permanentDelete
                                    ? Colors.orange
                                    : Colors.transparent,
                              ),
                              child: _permanentDelete
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14 * widthRatio,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 8 * widthRatio),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '완전 삭제 (재인증 필요)',
                                    style: TextStyle(
                                      fontSize: 14 * widthRatio,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF121212),
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  SizedBox(height: 4 * heightRatio),
                                  Text(
                                    _permanentDelete
                                        ? '• 로그인 계정도 완전히 삭제됩니다\n• 같은 이메일/전화번호로 새 계정 생성 가능\n• 재인증이 필요합니다'
                                        : '• 로그인 계정은 유지됩니다\n• 같은 이메일/전화번호 재사용 불가\n• 즉시 처리됩니다',
                                    style: TextStyle(
                                      fontSize: 12 * widthRatio,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF666666),
                                      fontFamily: 'Pretendard',
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24 * heightRatio),
              
              // Confirmation checkbox
              InkWell(
                onTap: () {
                  setState(() {
                    _confirmationChecked = !_confirmationChecked;
                  });
                },
                borderRadius: BorderRadius.circular(4 * widthRatio),
                child: Padding(
                  padding: EdgeInsets.all(4 * widthRatio),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20 * widthRatio,
                        height: 20 * widthRatio,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4 * widthRatio),
                          border: Border.all(
                            color: _confirmationChecked
                                ? const Color(0xFF5F37CF)
                                : const Color(0xFFBBBBBB),
                            width: 2,
                          ),
                          color: _confirmationChecked
                              ? const Color(0xFF5F37CF)
                              : Colors.transparent,
                        ),
                        child: _confirmationChecked
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14 * widthRatio,
                              )
                            : null,
                      ),
                      SizedBox(width: 8 * widthRatio),
                      Expanded(
                        child: Text(
                          '위 내용을 모두 확인했으며, 계정 삭제에 동의합니다.',
                          style: TextStyle(
                            fontSize: 14 * widthRatio,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF121212),
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40 * heightRatio),
              
              // Delete button
              SizedBox(
                width: double.infinity,
                height: 52 * heightRatio,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processAccountRemoval,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * widthRatio),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          '계정 탈퇴하기',
                          style: TextStyle(
                            fontSize: 16 * widthRatio,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 20 * heightRatio),
            ],
          ),
        ),
      ),
    );
  }
}