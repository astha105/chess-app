// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

          // Light green radial glow
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
            child: Column(
              children: [
                // AppBar content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔘 Log In (left)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // Center Logo (Pawn + "Chess")
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/chess_pawn.png',
                            height: 26,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Chess",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      // Sign Up (right)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Body Section
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      const SizedBox(height: 8),

                      // 5 Feature Cards
                      _buildFeatureCard(
                        context,
                        title: "Solve Puzzles",
                        subtitle: "Find the right move!",
                        image: "assets/images/sample_board.png",
                        icon: "assets/images/puzzle_icon.png",
                        gradientColors: [
                          Colors.greenAccent.withOpacity(0.25),
                          Colors.transparent
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        title: "Daily Puzzle",
                        subtitle: "Solved by 5,39,998 players",
                        image: "assets/images/sample_board.png",
                        icon: "assets/images/daily_puzzle_icon.png",
                        gradientColors: [
                          Colors.tealAccent.withOpacity(0.25),
                          Colors.transparent
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        title: "Play Bots",
                        subtitle: "Bentnoze and Wartface – Friendly",
                        image: "assets/images/sample_board.png",
                        icon: "assets/images/bot_icon.png",
                        gradientColors: [
                          Colors.blueAccent.withOpacity(0.25),
                          Colors.transparent
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        title: "Play Coach",
                        subtitle: "Coach Mario's Lessons",
                        image: "assets/images/sample_board.png",
                        icon: "assets/images/coach_icon.png",
                        gradientColors: [
                          Colors.orangeAccent.withOpacity(0.25),
                          Colors.transparent
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        title: "Next Lesson",
                        subtitle: "Learn something new today!",
                        image: "assets/images/sample_board.png",
                        icon: "assets/images/lesson_icon.png",
                        gradientColors: [
                          Colors.purpleAccent.withOpacity(0.25),
                          Colors.transparent
                        ],
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // Play Button (fixed bottom)
                Container(
                  margin: const EdgeInsets.all(16),
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Play",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ⭐ IMPORTANT FIX
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // Feature Card Builder Widget
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String image,
    required String icon,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () {},
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
            // Chess board thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
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

            const SizedBox(width: 12),
            Image.asset(icon, height: 32),
          ],
        ),
      ),
    );
  }
}
