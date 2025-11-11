// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Background Chessboard Gradient
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
                  const Text(
                    "More",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Manage your profile, settings, and app preferences.",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 35),

                  // Profile & Account
                  _buildSectionHeader("Profile & Account"),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "My Profile",
                    subtitle: "View stats, rating history, and achievements",
                    icon: Icons.person,
                    gradientColors: [
                      Colors.greenAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Account Settings",
                    subtitle: "Update username, email, password, and notifications",
                    icon: Icons.settings,
                    gradientColors: [
                      Colors.blueAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  // Game Management
                  _buildSectionHeader("Game Management"),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Game History",
                    subtitle: "Review and analyze all your past games",
                    icon: Icons.history,
                    gradientColors: [
                      Colors.tealAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Import/Export Games",
                    subtitle: "PGN file support for game sharing",
                    icon: Icons.import_export,
                    gradientColors: [
                      Colors.limeAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  // Social & Community
                  _buildSectionHeader("Social & Community"),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Friends & Messages",
                    subtitle: "Connect and chat with other players",
                    icon: Icons.people,
                    gradientColors: [
                      Colors.pinkAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Leaderboards",
                    subtitle: "Global and friend rankings",
                    icon: Icons.leaderboard,
                    gradientColors: [
                      Colors.amberAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  // Customization
                  _buildSectionHeader("Customization"),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Board & Pieces Theme",
                    subtitle: "Customize board appearance and sounds",
                    icon: Icons.palette,
                    gradientColors: [
                      Colors.orangeAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  // Play & Learn
                  _buildSectionHeader("Play & Learn"),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Tournaments",
                    subtitle: "Join or create tournaments",
                    icon: Icons.emoji_events,
                    gradientColors: [
                      Colors.yellowAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Opening Explorer",
                    subtitle: "Study opening moves and statistics",
                    icon: Icons.explore,
                    gradientColors: [
                      Colors.cyanAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Daily Challenges",
                    subtitle: "Special daily chess tasks and puzzles",
                    icon: Icons.calendar_today,
                    gradientColors: [
                      Colors.greenAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  // Premium Section
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withOpacity(0.2),
                            Colors.orange.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                                radius: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              color: Colors.amber,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Go Premium",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Unlock advanced features and ad-free experience",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Help & Support
                  _buildSectionHeader("Help & Support"),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Help Center",
                    subtitle: "FAQs, tutorials, and support",
                    icon: Icons.help_outline,
                    gradientColors: [
                      Colors.cyanAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Report a Bug",
                    subtitle: "Help us improve by reporting issues",
                    icon: Icons.bug_report_outlined,
                    gradientColors: [
                      Colors.redAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  // App Information
                  _buildSectionHeader("App Information"),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "About",
                    subtitle: "App version, terms, and privacy policy",
                    icon: Icons.info_outline,
                    gradientColors: [
                      Colors.grey.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    context,
                    title: "Rate & Share",
                    subtitle: "Leave a review and invite friends",
                    icon: Icons.star_rate,
                    gradientColors: [
                      Colors.yellowAccent.withOpacity(0.25),
                      Colors.transparent
                    ],
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  // Logout Button
                  GestureDetector(
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xFF1F1F1F),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.15),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "About Chess App",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Version: 1.0.0",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "A comprehensive chess learning and playing platform with advanced features.",
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            SizedBox(height: 15),
            Text(
              "© 2025 Chess App. All rights reserved.",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout action
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}