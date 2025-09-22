import 'package:flutter/material.dart';

class FolderCardWidget extends StatelessWidget {
  final Color folderColor;
  final Color borderColor;
  final String title;
  final String? timeLeft;
  final String? verdict;
  final bool isCase;
  final VoidCallback onTap;

  const FolderCardWidget({
    super.key,
    required this.folderColor,
    required this.borderColor,
    required this.title,
    this.timeLeft,
    this.verdict,
    required this.isCase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 16,
              child: Container(
                width: MediaQuery.of(context).size.width - 245,
                height: 115,
                decoration: BoxDecoration(
                  color: isCase
                      ? const Color(0xFF6037D0).withOpacity(0.6)
                      : const Color.fromARGB(255, 107, 107, 107).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              child: Container(
                width: MediaQuery.of(context).size.width - 48,
                height: 122,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                height: 122,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 15),
                decoration: BoxDecoration(
                  color: folderColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (isCase && timeLeft != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(timeLeft!,
                            style: TextStyle(
                                color: borderColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    if (!isCase && verdict != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: _getVerdictColor(verdict!),
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          verdict!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: borderColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict) {
      case '반대':
        return const Color(0xFFFF3838); // Red for "Cons"
      case '찬성':
        return const Color(0xFF3146E6); // Blue for "Pros"
      default:
        return const Color(0xFFC7C7C7); // Gray for "Tie" or other cases
    }
  }
}