import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/chess_screen.dart';
import '../screens/puzzles_screen.dart';
import '../screens/learn_screen.dart';
import '../screens/more_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: const Color(0xFF22201F),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF8BC34A),
      unselectedItemColor: Colors.white70,

      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChessScreen()),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PuzzlesScreen()),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LearnScreen()),
            );
            break;

          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MoreScreen()),
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage("assets/images/chess_pawn.png")),
          label: "Chess",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.extension),
          label: "Puzzles",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: "Learn",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: "More",
        ),
      ],
    );
  }
}