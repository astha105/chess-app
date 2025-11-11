import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/bottom_nav_bar.dart';

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2928),

      // Top App Bar
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2928),
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              "Watch",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // Main Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EVENTS SECTION
            _sectionCard(
              title: "Events Today",
              icon: Icons.emoji_events,
              color: Colors.amber,
              child: Column(
                children: [
                  _eventCard(
                    "FIDE World Cup 2025",
                    "1 Nov 2025 - 27 Nov 2025",
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Chess_board_opening_staunton.jpg/640px-Chess_board_opening_staunton.jpg",
                  ),
                  _eventCard(
                    "Collegiate Chess League: Fall 2025",
                    "28 Sep 2025 - 24 Nov 2025",
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Chess_piece_-_Black_Rook.jpg/480px-Chess_piece_-_Black_Rook.jpg",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NEWS SECTION
            _sectionCard(
              title: "News",
              icon: Icons.article,
              color: Colors.white,
              child: Column(
                children: [
                  _newsCard(
                    context,
                    imageUrl:
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Magnus_Carlsen_World_Chess_Championship_2021.jpg/640px-Magnus_Carlsen_World_Chess_Championship_2021.jpg",
                    title:
                        "Magnus Carlsen Wins Speed Chess Championship 2024",
                    author: "Chess.com Staff",
                    description:
                        "Magnus Carlsen defeats Hikaru Nakamura in the Speed Chess Championship final...",
                    articleUrl:
                        "https://www.chess.com/news/view/2024-speed-chess-championship-carlsen-nakamura",
                  ),
                  _newsCard(
                    context,
                    imageUrl:
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Maxime_Vachier-Lagrave_Chess_World_Cup_2013.jpg/640px-Maxime_Vachier-Lagrave_Chess_World_Cup_2013.jpg",
                    title: "FIDE World Cup 2023 Final Results",
                    author: "Chess.com Staff",
                    description:
                        "Magnus Carlsen wins the FIDE World Cup after defeating Praggnanandhaa...",
                    articleUrl:
                        "https://www.chess.com/news/view/2023-fide-world-cup-final-carlsen-praggnanandhaa",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STREAMERS SECTION
            _sectionCard(
              title: "Streamers",
              icon: Icons.mic,
              color: Colors.purpleAccent,
              child: Column(
                children: [
                  _streamerTile("akhistarYT",
                      "https://i.pravatar.cc/150?img=3", true),
                  _streamerTile("TheMagician",
                      "https://i.pravatar.cc/150?img=10", false),
                  _streamerTile("wonderfultime",
                      "https://i.pravatar.cc/150?img=14", true),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // Helper: Section Card
  static Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3836),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Helper: Event card
  static Widget _eventCard(String title, String date, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              imageUrl,
              height: 40,
              width: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.white54),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: News card (Clickable)
  static Widget _newsCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String author,
    required String description,
    required String articleUrl,
  }) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(articleUrl);
        try {
          // Directly launch URL without canLaunchUrl check
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          // Show error message if launch fails
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open article: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: const Color(0xFF4A4846),
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white54, size: 40),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 160,
                    color: const Color(0xFF4A4846),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              author,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Streamer tile
  static Widget _streamerTile(String name, String avatarUrl, bool live) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              avatarUrl,
              height: 36,
              width: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, color: Colors.white54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          if (live)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.wifi_tethering,
                  color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}