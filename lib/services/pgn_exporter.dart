// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pgn_exporter_web.dart' if (dart.library.io) 'pgn_exporter_mobile.dart';

class PGNExporter {
  /// Generate PGN from analyzed moves
  static String generatePGN(List<Map<String, dynamic>> moves, {
    String? whiteName,
    String? blackName,
    String? event,
    String? site,
  }) {
    final now = DateTime.now();
    final date = "${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}";
    
    // PGN Headers
    StringBuffer pgn = StringBuffer();
    pgn.writeln('[Event "${event ?? "Casual Game"}"]');
    pgn.writeln('[Site "${site ?? "Chess App"}"]');
    pgn.writeln('[Date "$date"]');
    pgn.writeln('[Round "?"]');
    pgn.writeln('[White "${whiteName ?? "Player"}"]');
    pgn.writeln('[Black "${blackName ?? "Computer"}"]');
    pgn.writeln('[Result "*"]');
    pgn.writeln();
    
    // Moves
    StringBuffer movesStr = StringBuffer();
    for (int i = 0; i < moves.length; i++) {
      if (i % 2 == 0) {
        // White's move
        int moveNumber = (i ~/ 2) + 1;
        movesStr.write('$moveNumber. ${moves[i]["played"]} ');
      } else {
        // Black's move
        movesStr.write('${moves[i]["played"]} ');
      }
      
      // Line break every 8 moves for readability
      if ((i + 1) % 8 == 0) {
        movesStr.write('\n');
      }
    }
    
    pgn.write(movesStr.toString().trim());
    pgn.writeln(' *');
    
    return pgn.toString();
  }

  /// Show export dialog - SAME UI on ALL platforms
  static void showExportDialog(BuildContext context, List<Map<String, dynamic>> moves) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1e1e1e),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              "Export Game",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${moves.length} moves",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Option 1: Copy PGN (All platforms)
            _buildExportOption(
              context,
              icon: Icons.content_copy,
              title: "Copy PGN",
              subtitle: "Copy to clipboard",
              onTap: () {
                final pgn = generatePGN(moves);
                Clipboard.setData(ClipboardData(text: pgn));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PGN copied to clipboard!'),
                    backgroundColor: Color(0xFF67C23A),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            // Option 2: Download/Share PGN (All platforms)
            _buildExportOption(
              context,
              icon: Icons.download,
              title: kIsWeb ? "Download PGN" : "Save PGN",
              subtitle: kIsWeb ? "Download as .pgn file" : "Save or share .pgn file",
              onTap: () {
                final pgn = generatePGN(moves);
                Navigator.pop(context);
                
                try {
                  if (kIsWeb) {
                    // Web: Download (synchronous)
                    downloadPGN(context, pgn);
                  } else {
                    // Mobile: Share (synchronous - no await needed)
                    sharePGN(context, pgn);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}