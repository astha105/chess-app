import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/puzzles_screen.dart';
import '../screens/learn_screen.dart'; // ✅ Learn screen now active
import '../screens/more_screen.dart';
// import '../screens/watch_screen.dart'; // 👀 Temporarily commented out

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
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PuzzlesScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LearnScreen()),
          );
        } else if (index == 3) { // ✅ Added this block
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MoreScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.extension),
          label: "Puzzles",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: "Learn",
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.visibility),
        //   label: "Watch",
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: "More",
        ),
      ],
    );
  }
}
