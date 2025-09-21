import 'package:flutter/material.dart';
import '../screens/community/community_main.dart';
import '../screens/contents_page/contents_main.dart';
import '../screens/my_page/my_page_main.dart';
import '../services/authentication/auth_service.dart';
import 'guest_login_prompt.dart';

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key});

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CommunityMainTabScreenMycom(), // Community 
    const ContentsMainPage(), // Contents
    const MyPageMain(), // Profile 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF5F37CF),
        unselectedItemColor: Colors.grey,
        elevation: 8,
        currentIndex: _currentIndex,
        onTap: (index) async {
          final authService = AuthService();
          print('🔍 Navigation tap: index=$index, isGuest=${authService.isGuest}');
          
          switch (index) {
            case 0:
              // Community tab
              setState(() => _currentIndex = 0);
              break;
            case 1:
              // Contents 페이지로 이동 - guests can access
              setState(() => _currentIndex = 1);
              Navigator.pushNamed(context, '/contents-main');
              break;
            case 2:
              // Profile 페이지 - block guests
              print('🔍 MyPage tap: isGuest=${authService.isGuest}');
              if (authService.isGuest) {
                print('🚫 Blocking guest access to MyPage');
                // Don't change tab index for guests - stay on current tab
                await GuestLoginPrompt.show(context);
                return;
              }
              print('✅ Allowing authenticated user to MyPage');
              setState(() => _currentIndex = 2);
              Navigator.pushNamed(context, '/my-page');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_none),
            activeIcon: Icon(Icons.filter_none),
            label: 'Contents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
