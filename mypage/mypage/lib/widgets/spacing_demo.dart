import 'package:flutter/material.dart';
import 'responsive_app_bar.dart';

/// Demo widget showing proper spacing usage and responsive behavior
class AppBarSpacingDemo extends StatelessWidget {
  const AppBarSpacingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyHomeAppBar(), // Use the properly spaced AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AppBar Spacing Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Display spacing values for current screen
            Builder(
              builder: (context) {
                final spacingValues = AppBarSpacing.getSpacingValues(context);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Screen Width: ${MediaQuery.of(context).size.width.toStringAsFixed(1)}px'),
                    Text('Scale Factor: ${(MediaQuery.of(context).size.width / 393.0).toStringAsFixed(3)}'),
                    const SizedBox(height: 12),
                    
                    const Text('Responsive Spacing Values:', 
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ...spacingValues.entries.map((entry) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text('${entry.key}: ${entry.value.toStringAsFixed(1)}px'),
                      ),
                    ),
                  ],
                );
              }
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Design Specifications (393px base):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Left padding: 17.0px'),
                  Text('• Logo width: 69.0px × 25.0px'),
                  Text('• Logo to text gap: 11.87px'),
                  Text('• Text: "마이홈" (22px Pretendard)'),
                  Text('• Flexible space: ~195px equivalent'),
                  Text('• Menu icon: 29.0px × 29.0px'),
                  Text('• Right padding: 14.0px'),
                  Text('• Total height: 66.0px'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}