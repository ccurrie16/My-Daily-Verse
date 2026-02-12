import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bible/models/verse.dart';
import 'package:bible/services/saved_verses_service.dart';
import 'package:bible/services/cloud_saved_verses_service.dart';

/// Widget to display and manage deleted verses for recovery
class DeletedVersesRecoveryWidget extends StatefulWidget {
  const DeletedVersesRecoveryWidget({super.key});

  @override
  State<DeletedVersesRecoveryWidget> createState() =>
      _DeletedVersesRecoveryWidgetState();
}

class _DeletedVersesRecoveryWidgetState
    extends State<DeletedVersesRecoveryWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFBF8);
    const darkgold = Color(0xFFE0C869);
    final textSecondary =
        isDark ? const Color(0xFFB0B0B0) : const Color(0xFF7A7A7A);
    final containerColor = isDark ? const Color(0xFF2B2B2B) : Colors.white;

    return ValueListenableBuilder<List<Verse>>(
      valueListenable: CloudSavedVersesService.deletedVerses,
      builder: (context, deletedVerses, _) {
        if (deletedVerses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No deleted verses to recover',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deletedVerses.length,
          itemBuilder: (context, index) {
            final verse = deletedVerses[index];
            final deletedDate = verse.deletedAt ?? DateTime.now();
            final daysAgo = DateTime.now().difference(deletedDate).inDays;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse reference and deleted info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                verse.reference,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: darkgold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                daysAgo == 0
                                    ? 'Deleted today'
                                    : 'Deleted $daysAgo day${daysAgo > 1 ? 's' : ''} ago',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Verse text
                    Text(
                      verse.text,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Recover button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await SavedVersesService.recover(verse);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${verse.reference} recovered',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkgold,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.restore, size: 18),
                          label: const Text('Recover'),
                        ),

                        // Permanently delete button
                        OutlinedButton.icon(
                          onPressed: () {
                            _showDeleteConfirmation(context, verse, isDark,
                                darkgold, textSecondary, containerColor);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.delete_forever, size: 18),
                          label: const Text('Permanently Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Verse verse,
    bool isDark,
    Color darkgold,
    Color textSecondary,
    Color containerColor,
  ) {
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFBF8);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(
          'Permanently Delete?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'This will permanently remove ${verse.reference} from all your devices. This action cannot be undone.',
          style: TextStyle(
            color: textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await SavedVersesService.hardDelete(verse);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Verse permanently deleted'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Permanently Delete'),
          ),
        ],
      ),
    );
  }
}
