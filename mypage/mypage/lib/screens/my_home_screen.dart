import 'package:flutter/material.dart';

import '../widgets/my_home_app_bar.dart';
import '../widgets/pet_status_panel.dart';
import '../widgets/pet_display_area.dart';
import '../widgets/action_toolbar.dart';
import '../widgets/bottom_nav_bar.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 140 : 120),
        child: const MyHomeAppBar(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mypage/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // Top – Responsive status panel
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.04,
                      vertical: screenSize.height * 0.02,
                    ),
                    child: const PetStatusPanel(),
                  ),
                  // Center – Pet display with flexible sizing
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05,
                      ),
                      child: const PetDisplayArea(),
                    ),
                  ),
                  // Bottom – Action toolbar with responsive spacing
                  Container(
                    padding: EdgeInsets.only(
                      left: screenSize.width * 0.04,
                      right: screenSize.width * 0.04,
                      bottom: screenSize.height * 0.02,
                    ),
                    child: const ActionToolbar(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
