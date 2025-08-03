import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';


/// Responsive pet display that matches the hardcoded design layout
/// Transforms fixed positions (88,347 - 216x324) into flexible design
class ResponsivePetDisplay extends StatelessWidget {
  final double scale;
  
  const ResponsivePetDisplay({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: 400 * scale, // Flexible height based on design
      child: Stack(
        children: [
          // Main pet nest area (originally 88,347 216x324) - moved down by 50px
          Positioned(
            left: (screenSize.width - 216 * scale) / 2, // Center horizontally
            top: 100 * scale, // Moved down by 50 pixels
            child: Container(
              width: 216 * scale,
              height: 324 * scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pet;  
                  // Positioned 대신 Center 위젯 사용
                  Center(
                    child: Image.asset(
                      'assets/mypage/pet/pet.png',
                      width: 17.5 * 90 * scale,
                      height: 17.5 * 100 * scale,
                      fit: BoxFit.contain,
                    ),
                  ),


                ],
              ),
            ),
          ),
          
          // Message box (originally 213,309 155x118)
          Positioned(
            right: 40 * scale,
            top: 30 * scale,
            child: Container(
              width: 155 * scale,
              height: 118 * scale,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/mypage/pet/interation_message_box.png',
                    width: 155 * scale,
                    height: 118 * scale,
                    fit: BoxFit.contain,
                  ),
                  // Message text (originally 260,349)
                  Positioned(
                    left: 47 * scale,
                    top: 40 * scale,
                    child: Text(
                      '나한테\n냄새나..',
                      style: TextStyle(
                        color: const Color(0xFF121212),
                        fontSize: 16 * scale,
                        fontFamily: 'DungGeunMo',
                        fontWeight: FontWeight.w400,
                        height: 1.12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Pet name tag (originally 147,580 102x29)
          Positioned(
            bottom: 50 * scale,
            left: (screenSize.width - 102 * scale) / 2, // Center horizontally
            child: Container(
              width: 102 * scale,
              height: 29 * scale,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: const Color(0xFFAE6ACD),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2 * scale,
                    color: const Color(0xFF121212),
                  ),
                  borderRadius: BorderRadius.circular(400),
                ),
              ),
              child: Center(
                child: Text(
                  '알순이',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFFAFAFA),
                    fontSize: 14 * scale,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.29,
                  ),
                ),
              ),
            ),
          ),
          
          // Pet name input field (responsive)
          Positioned(
            bottom: 10 * scale,
            left: (screenSize.width - 200 * scale) / 2,
            child: Container(
              width: 200 * scale,
              height: 35 * scale,
              // child: TextField(
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 14 * scale,
              //     fontFamily: 'DungGeunMo',
              //   ),
              //   // decoration: InputDecoration(
              //   //   border: OutlineInputBorder(
              //   //     borderRadius: BorderRadius.circular(20 * scale),
              //   //     borderSide: BorderSide(
              //   //       color: const Color(0xFF121212),
              //   //       width: 1.5 * scale,
              //   //     ),
              //   //   ),
              //   //   // hintText: 'my pet name',
              //   //   // hintStyle: TextStyle(
              //   //   //   fontSize: 12 * scale,
              //   //   //   color: Colors.grey,
              //   //   // ),
              //   //   contentPadding: EdgeInsets.symmetric(
              //   //     horizontal: 12 * scale,
              //   //     vertical: 8 * scale,
              //   //   ),
              //   // ),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive status panel that matches the hardcoded design
class ResponsiveStatusPanel extends StatelessWidget {
  final double scale;
  
  const ResponsiveStatusPanel({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().pet;
    
    return Container(
      height: 70 * scale,
      padding: EdgeInsets.symmetric(horizontal: 25 * scale),
      child: Row(
        children: [
          // Status labels and bars (left side)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 청결 (originally 25,137)
                _buildStatusRow('청결', pet.cleanliness, const Color(0xFF4CEB30), scale),
                // 행복 (originally 25,158)  
                _buildStatusRow('행복', pet.happiness, const Color(0xFFFFDD38), scale),
                // 배고픔 (originally 16,178)
                _buildStatusRow('배고픔', 100 - pet.hunger, const Color(0xFFE8555F), scale),
              ],
            ),
          ),
          
          SizedBox(width: 20 * scale),
          
          // Level display (right side, originally 336-375,138-185)
          Expanded(
            flex: 1,
            child: _buildLevelDisplay(pet, scale),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int value, Color barColor, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * scale),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 50 * scale,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF121212),
                fontSize: 12 * scale,
                fontFamily: 'DungGeunMo',
                fontWeight: FontWeight.w400,
                height: 1.44,
              ),
            ),
          ),
          // Status bar (originally 57,140-182 width:140 height:11)
          Expanded(
            child: Container(
              height: 11 * scale,
              decoration: ShapeDecoration(
                color: const Color(0xFFFAFAFA),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2 * scale,
                    color: const Color(0xFF121212),
                  ),
                  borderRadius: BorderRadius.circular(400),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 2 * scale,
                    top: 2 * scale,
                    child: Container(
                      width: (136 * scale) * (value / 100), // 140-4 for borders
                      height: 7 * scale,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelDisplay(pet, double scale) {
    return Container(
      width: 39 * scale,
      height: 50 * scale,
      child: Stack(
        children: [
          // Level gauge bars (originally multiple positioned containers)
          ...List.generate(10, (index) {
            final isActive = index < (pet.xpPercent * 10).floor();
            return Positioned(
              left: 5 * scale,
              top: (45 - index * 4.5) * scale,
              child: Container(
                width: 28 * scale,
                height: 3 * scale,
                decoration: BoxDecoration(
                  color: isActive 
                    ? const Color(0xFF5F37CF)
                    : Colors.white.withValues(alpha: 0.40),
                ),
              ),
            );
          }),
          
          // Level text (originally 352,155)
          Positioned(
            bottom: 5 * scale,
            left: 0,
            right: 0,
            child: Text(
              '${pet.level}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFFAFAFA),
                fontSize: 15 * scale,
                fontFamily: 'DungGeunMo',
                fontWeight: FontWeight.w400,
                height: 1.24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}