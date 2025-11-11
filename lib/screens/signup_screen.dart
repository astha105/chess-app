// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _loading = false;
  bool _obscure = true;

  Future<void> _signUp() async {
    try {
      setState(() => _loading = true);
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Something went wrong.';
      if (e.code == 'weak-password') msg = 'Password should be at least 6 characters.';
      if (e.code == 'email-already-in-use') msg = 'An account already exists for this email.';
      if (e.code == 'invalid-email') msg = 'Please enter a valid email address.';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ♟️ Background Chessboard Pattern
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ChessboardBackgroundPainter(),
          ),

          // 🌕 Soft green glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 0.9,
                colors: [
                  Colors.greenAccent.withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ♟️ Transparent overlay for contrast
          Container(color: Colors.black.withOpacity(0.3)),

          // 🧩 Foreground UI
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔙 Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // ✨ Log In (emphasized without being a button)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.greenAccent,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 🧠 Title
                const Text(
                  "Join Chess.\nMake Your Move!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 40),

                // ♟️ Glowing Pawn
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.greenAccent.withOpacity(0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                    Image.asset("assets/images/chess_pawn.png", height: 130),
                  ],
                ),

                const SizedBox(height: 50),

                // 📋 Floating Card for Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.1),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ✉️ Email Field (brighter and clearer)
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.greenAccent),
                          hintText: "Email address",
                          hintStyle: const TextStyle(color: Colors.white70, fontSize: 15.5),
                          filled: true,
                          fillColor: Colors.grey[850]?.withOpacity(0.9),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.greenAccent, width: 1.4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.white, width: 1.6),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      const SizedBox(height: 18),

                      // 🔒 Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.greenAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          hintText: "Create a password",
                          hintStyle: const TextStyle(color: Colors.white70, fontSize: 15.5),
                          filled: true,
                          fillColor: Colors.grey[850]?.withOpacity(0.9),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.greenAccent, width: 1.4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.white, width: 1.6),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      const SizedBox(height: 25),

                      // 🟩 Continue
                      _loading
                          ? const CircularProgressIndicator(color: Colors.greenAccent)
                          : ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55),
                                backgroundColor: const Color(0xFF8BC34A),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 8,
                                shadowColor: Colors.greenAccent.withOpacity(0.6),
                              ),
                              child: const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "By continuing, you agree to our Terms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ♟️ Full-screen Chessboard Background
class ChessboardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 100;
    final Paint darkPaint = Paint()..color = const Color(0xFF1C1C1C);
    final Paint lightPaint = Paint()..color = const Color(0xFF2A2A2A);

    for (int row = 0; row < (size.height / squareSize).ceil(); row++) {
      for (int col = 0; col < (size.width / squareSize).ceil(); col++) {
        final paint = (row + col) % 2 == 0 ? darkPaint : lightPaint;
        final rect = Rect.fromLTWH(col * squareSize, row * squareSize, squareSize, squareSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
