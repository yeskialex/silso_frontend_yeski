import 'package:flutter/material.dart';
import 'views/loading_screen_view.dart';
import 'pages/category_selection_page.dart'; 
/// MVC 패턴을 적용한 Flutter 앱의 메인 엔트리 포인트
void main() {
  runApp(const MyApp());
}

/// 앱의 루트 위젯 - MaterialApp 설정을 담당
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실소 커뮤니티',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: CategorySelectionPage(),
      //const LoadingScreenView(),
    );
  }
}