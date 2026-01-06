// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class PuzzlesScreen extends StatefulWidget {
  const PuzzlesScreen({super.key});

  @override
  State<PuzzlesScreen> createState() => _PuzzlesScreenState();
}

class _PuzzlesScreenState extends State<PuzzlesScreen> {
  final List<String> chessQuotes = [
    "Never skip Puzzle day!",
    "Every move counts — think twice, move once.",
    "Tactics flow from a superior position.",
    "A bad plan is better than no plan at all.",
    "Play the board, not the opponent.",
  ];

  int _currentQuoteIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % chessQuotes.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

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
          // Subtle glow
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
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/puzzle_icon.png', height: 26),
                      const SizedBox(width: 8),
                      const Text(
                        "Puzzles",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Coach + Animated Tip Box
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/coach_icon.png', height: 68),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 72,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.15),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 700),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              final fadeAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );
                              final slideAnimation = Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(fadeAnimation);
                              return FadeTransition(
                                opacity: fadeAnimation,
                                child: SlideTransition(
                                  position: slideAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: Align(
                              key: ValueKey<String>(
                                  chessQuotes[_currentQuoteIndex]),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                chessQuotes[_currentQuoteIndex],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Chessboard Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/sample_board.png',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        ),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Puzzle Score Bar
                  Row(
                    children: [
                      const Text(
                        "0",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 0,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.greenAccent,
                                      Colors.lightGreen,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset('assets/images/puzzle_icon.png', height: 22),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // "Solve Puzzles" Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Solve Puzzles",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Puzzle Rush Card
                  _buildCard(
                    context,
                    title: "Puzzle Rush",
                    subtitle: "Solve as many puzzles as you can in 5 minutes.",
                    icon: Icons.flash_on,
                    gradientColors: [
                      Colors.greenAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),

                  //Daily Puzzle
                  _buildCard(
                    context,
                    title: "Daily Puzzle",
                    subtitle:
                        "A new hand-picked puzzle every day to challenge your mind.",
                    icon: Icons.calendar_today,
                    gradientColors: [
                      Colors.tealAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),

                  // Puzzle Battle
                  _buildCard(
                    context,
                    title: "Puzzle Battle",
                    subtitle:
                        "Compete against other players in real-time puzzle duels.",
                    icon: Icons.sports_esports,
                    gradientColors: [
                      Colors.blueAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),

                  // Custom Puzzles
                  _buildCard(
                    context,
                    title: "Custom",
                    subtitle:
                        "Create your own puzzle collection or practice specific themes.",
                    icon: Icons.tune,
                    gradientColors: [
                      Colors.orangeAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // Card Builder Widget
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