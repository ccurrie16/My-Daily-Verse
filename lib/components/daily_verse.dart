import 'package:flutter/material.dart';
import 'package:bible/pages/home_screen.dart';
import 'package:bible/models/verse.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';


class DailyVerse extends StatefulWidget {
  final Verse verse;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const DailyVerse({
    super.key,
    required this.verse,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  State<DailyVerse> createState() => _DailyVerseState();
}

class _DailyVerseState extends State<DailyVerse> {
  final _shareButtonKey = GlobalKey();

  void _handleShare() {
    final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    Share.share(
      '"${widget.verse.text}"\n— ${widget.verse.reference}',
      sharePositionOrigin: rect,
    );
  }

  // Widget for daily verse card with save/unsave function
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkgold.withOpacity(0.3)
                : AppColors.softgold,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: AppColors.darkgold.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Column layout for verse text, reference, and save button
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Share button
                IconButton(
                  key: _shareButtonKey,
                  onPressed: _handleShare,
                  icon: const Icon(Icons.share),
                  color: AppColors.darkgold,
                  iconSize: 28,
                  tooltip: "Share",
                ),
                // Save/Unsave button at the top right corner
                IconButton(
                  onPressed: widget.onToggleSave,
                  // AnimatedSwitcher for smooth icon transition
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      key: ValueKey<bool>(widget.isSaved),
                    ),
                  ),
                  color: AppColors.darkgold,
                  iconSize: 28,
                  tooltip: widget.isSaved ? "Unsave" : "Save",
                ),
              ],
            ),

            const SizedBox(height: 8),
          // Verse text in the center of Daily Verse card
            Expanded(
              child: Center(
                child: Text(
                  widget.verse.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    color: AppColors.getPrimaryText(context),
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Verse reference at the bottom of Daily Verse card
            Text(
              widget.verse.reference,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                color: AppColors.getSecondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
