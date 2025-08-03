import 'package:flutter/material.dart';

/// Simple bottom navigation bar placeholder.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  final _items = const <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Pet'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: _items,
      currentIndex: 0,
      onTap: (i) {},
      selectedFontSize: 12,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
    );
  }
}
