// Mobile-specific implementation - Simple synchronous clipboard
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Download PGN on Mobile (copies to clipboard with instructions)
void downloadPGN(BuildContext context, String pgn) {
  Clipboard.setData(ClipboardData(text: pgn));
  
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PGN copied to clipboard!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '📋 Paste into Notes or Files app',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '💾 Save as .pgn file',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Color(0xFF67C23A),
        duration: Duration(seconds: 4),
      ),
    );
  }
}

/// Share PGN on Mobile (same as download - synchronous)
void sharePGN(BuildContext context, String pgn) {
  downloadPGN(context, pgn);
}