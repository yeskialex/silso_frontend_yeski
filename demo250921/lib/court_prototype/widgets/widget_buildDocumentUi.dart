import 'package:flutter/material.dart';
import '../models/silso_court_pixelPattern.dart';
import 'widget_buildHeader.dart';

Widget buildDocumentUi({
  required double width,
  required double height,
  required String title,
  required Widget content,
  String pageInfo = '1/1',
}) {
    const double borderWidth = 12.0;
    const double foldSize = 50.0;

    Widget buildBorder(Widget child) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xFF79673F)),
          CustomPaint(
            painter: PixelPatternPainter(
              dotColor: Colors.black.withOpacity(0.1),
              step: 3.0,
            ),
            child: Container(),
          ),
          child,
        ],
      );
    }

    return Stack(
      children: [
        Container(color: const Color(0xFFF2E3BC)),
        CustomPaint(
          size: Size(width, height),
          painter: PixelPatternPainter(
            dotColor: Colors.black.withOpacity(0.05),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          width: foldSize,
          height: foldSize,
          child: ClipPath(
            clipper: FoldedCornerClipper(),
            child: Container(color: const Color(0xFFD4C0A1)),
          ),
        ),
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: SizedBox(width: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          right: 0, top: 0, bottom: 0,
          child: SizedBox(width: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          left: 0, top: 0, right: 0,
          child: SizedBox(height: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Positioned(
          left:  0, bottom: 0, right: 0,
          child: SizedBox(height: borderWidth, child: buildBorder(const SizedBox())),
        ),
        Padding(
          padding: const EdgeInsets.all(borderWidth + 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(title, pageInfo),
              const SizedBox(height: 15),
              Container(width: double.infinity, height: 1, color: const Color(0xFFE0C898)),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }