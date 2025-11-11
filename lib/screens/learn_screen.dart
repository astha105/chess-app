// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // ♟️ Background Chessboard Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Color(0xFF1E1E1E),
                  Color(0xFF121212),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌕 Subtle glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.6),
                radius: 1.2,
                colors: [
                  Colors.greenAccent.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 🧠 Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 Top title
                  const Text(
                    "Learn Chess. Level Up.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Play smarter every day with guided lessons and tips.",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // 🧩 Play with Coach Card
                  _buildCard(
                    context,
                    title: "Play with Coach",
                    subtitle:
                        "Practice with an AI coach that gives move-by-move guidance.",
                    icon: Icons.psychology,
                    gradientColors: [
                      Colors.greenAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  // ♞ Learn an Opening
                  _buildCard(
                    context,
                    title: "Learn an Opening",
                    subtitle:
                        "Master iconic openings like Sicilian Defense or Queen’s Gambit.",
                    icon: Icons.auto_stories_outlined,
                    gradientColors: [
                      Colors.tealAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  // 📚 Lesson Library
                  _buildCard(
                    context,
                    title: "Lesson Library",
                    subtitle:
                        "From beginner to grandmaster, unlock structured lessons.",
                    icon: Icons.menu_book_rounded,
                    gradientColors: [
                      Colors.blueAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  // 🔥 Daily Lesson
                  _buildCard(
                    context,
                    title: "Daily Lesson",
                    subtitle:
                        "New short lessons every day. Stay sharp and learn fast.",
                    icon: Icons.bolt_rounded,
                    gradientColors: [
                      Colors.orangeAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 30),

                  // 📈 Progress tracker
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Progress",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Stack(
                          children: [
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              height: 10,
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.greenAccent,
                                    Colors.lightGreen,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Pawn → Knight (45% Complete)",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ♟️ Bottom Navigation
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // 📦 Card Builder
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF1F1F1F),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first,
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1F1F1F),
              gradientColors.first.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    gradientColors.first.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  radius: 1.2,
                ),
              ),
              child: Icon(icon, color: Colors.greenAccent, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}
