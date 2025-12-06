// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  final Future<Map<String, dynamic>> result;

  const AnalysisScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d0d),
      appBar: AppBar(
        title: const Text(
          "Game Review",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: result,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.greenAccent),
                  SizedBox(height: 20),
                  Text(
                    "Analyzing your game...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final data = snapshot.data ?? {};
          List moves = data["moves"] ?? [];
          int whiteAcc = data["whiteAccuracy"] ?? 0;
          int blackAcc = data["blackAccuracy"] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ACCURACY CARDS
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "White Accuracy",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "$whiteAcc%",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Black Accuracy",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "$blackAcc%",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Move-by-Move Analysis",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: moves.length,
                    itemBuilder: (_, i) {
                      final m = moves[i];

                      Color tagColor = m["tag"] == "Blunder"
                          ? Colors.redAccent
                          : m["tag"] == "Mistake"
                              ? Colors.orange
                              : m["tag"] == "Inaccuracy"
                                  ? Colors.yellow
                                  : Colors.greenAccent;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${m['moveNumber']}.",
                              style: const TextStyle(color: Colors.white60),
                            ),
                            const SizedBox(width: 10),

                            // MOVE INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Played: ${m['played']}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    "Best: ${m['best']} • Eval: ${m['eval'].toStringAsFixed(1)}",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                m["tag"],
                                style: TextStyle(
                                  color: tagColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}