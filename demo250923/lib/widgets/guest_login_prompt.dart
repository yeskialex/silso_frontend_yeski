import 'package:flutter/material.dart';

class GuestLoginPrompt {
  static Future<void> show(BuildContext context) async {
    final double widthRatio = MediaQuery.of(context).size.width / 393.0;
    final double heightRatio = MediaQuery.of(context).size.height / 852.0;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * widthRatio),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(24 * widthRatio),
          content: SizedBox(
            width: 280 * widthRatio,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 56 * widthRatio,
                  height: 56 * widthRatio,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F37CF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28 * widthRatio),
                  ),
                  child: Icon(
                    Icons.login_outlined,
                    color: const Color(0xFF5F37CF),
                    size: 28 * widthRatio,
                  ),
                ),
                
                SizedBox(height: 20 * heightRatio),
                
                // Title
                Text(
                  '로그인이 필요한 기능입니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18 * widthRatio,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF121212),
                    fontFamily: 'Pretendard',
                  ),
                ),
                
                SizedBox(height: 12 * heightRatio),
                
                // Message
                Text(
                  '이 기능을 사용하려면 먼저 로그인해 주세요.\n실소의 다양한 기능을 마음껏 이용해 보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * widthRatio,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E8E),
                    fontFamily: 'Pretendard',
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: 24 * heightRatio),
                
                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: Container(
                        height: 44 * heightRatio,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF8F9FA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8 * widthRatio),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 14 * widthRatio,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C757D),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12 * widthRatio),
                    
                    // Login button
                    Expanded(
                      child: Container(
                        height: 44 * heightRatio,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to login screen
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5F37CF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8 * widthRatio),
                            ),
                          ),
                          child: Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 14 * widthRatio,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}