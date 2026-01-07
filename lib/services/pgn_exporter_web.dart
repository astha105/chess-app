// Web-specific implementation
// ignore_for_file: avoid_web_libraries_in_flutter, unused_local_variable
// ignore_for_file: deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';

/// Download PGN file on Web using HTML anchor
void downloadPGN(BuildContext context, String pgn) {
  try {
    final now = DateTime.now();
    final fileName = 'chess_game_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.pgn';
    
    // Create blob with PGN content
    final bytes = utf8.encode(pgn);
    final blob = html.Blob([bytes], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create anchor element and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    
    // Clean up
    html.Url.revokeObjectUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloaded $fileName'),
        backgroundColor: const Color(0xFF67C23A),
        duration: const Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error downloading: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Share PGN on Web (just copies to clipboard)
void sharePGN(BuildContext context, String pgn) {
  // On web, sharing = downloading
  downloadPGN(context, pgn);
}