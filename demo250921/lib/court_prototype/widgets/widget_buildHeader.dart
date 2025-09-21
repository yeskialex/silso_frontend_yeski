import 'package:flutter/material.dart';

Widget buildHeader(String title, String pageInfo) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40), // Spacer for centering title
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF5E4E2C), fontSize: 24, fontFamily: 'Pretendard', fontWeight: FontWeight.w700)
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(pageInfo, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFFA68A54), fontSize: 16, fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}